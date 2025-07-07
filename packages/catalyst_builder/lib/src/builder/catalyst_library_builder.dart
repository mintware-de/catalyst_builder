import 'dart:async';
import 'dart:convert';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:glob/glob.dart';

import 'constants.dart';
import 'dto/dto.dart';
import 'generator/service_library/service_library.dart';
import 'helpers.dart';

/// The CatalystLibraryBuilder creates a library file that exports
/// all services in the current package as a Map.
class CatalystLibraryBuilder implements Builder {
  @override
  FutureOr<void> build(BuildStep buildStep) async {
    if (!await buildStep.resolver.isLibrary(buildStep.inputId)) {
      return;
    }
    LibraryElement libraryElement;
    try {
      libraryElement = (await buildStep.inputLibrary);
    } catch (e) {
      log.warning('Error while processing input library. Skip for now.', e);
      return;
    }

    var annotation = libraryElement.metadata
        .where((m) => m.isLibraryAnnotation('GenerateCatalystLibrary'))
        .firstOrNull;

    var isEntryPoint = annotation != null;
    if (!isEntryPoint) {
      return;
    }

    var constantValue = annotation.computeConstantValue()!;
    var libraryName =
        constantValue.getField('libraryName')?.toStringValue() ?? 'catalystServices';
    var includeDependencies =
        constantValue.getField('includeDependencies')?.toBoolValue() ?? false;

    var content = await _generateCode(buildStep, libraryName, includeDependencies);
    await buildStep.writeAsString(
      buildStep.inputId.changeExtension(catalystLibraryExtension),
      content,
    );
  }

  Future<String> _generateCode(
      BuildStep buildStep, String libraryName, bool includeDependencies) async {
    final parts = <PreflightPart>[];
    final services = <ExtractedService>[];

    await for (final input
        in buildStep.findAssets(Glob('**/**$preflightExtension'))) {
      final jsonContent = await buildStep.readAsString(input);
      final part = PreflightPart.fromJson(
        jsonDecode(jsonContent) as Map<String, dynamic>,
      );
      parts.add(part);
      
      // If includeDependencies is false, only include services from current package
      if (!includeDependencies) {
        final currentPackage = buildStep.inputId.package;
        final packageServices = part.services.where((service) {
          return service.service.library?.startsWith('package:$currentPackage/') == true;
        }).toList();
        services.addAll(packageServices);
      } else {
        services.addAll(part.services);
      }
    }

    final emitter = DartEmitter.scoped(
      orderDirectives: true,
      useNullSafetySyntax: true,
    );

    final rawOutput = Library(
      (l) => l.body.addAll([
        buildServicesMap(libraryName, services),
      ]),
    ).accept(emitter).toString();

    var content =
        DartFormatter(languageVersion: DartFormatter.latestLanguageVersion)
            .format('''
// ignore_for_file: prefer_relative_imports, public_member_api_docs, implementation_imports
    $rawOutput
    ''');
    
    // Replace final with const and remove const from Service instances
    content = content
        .replaceAll('final Map<Type, _i1.Service> $libraryName', 'const Map<Type, _i1.Service> $libraryName')
        .replaceAll('const _i1.Service()', '_i1.Service()');
    
    return content;
  }

  @override
  Map<String, List<String>> get buildExtensions => {
        r'$lib$': [],
        r'.dart': [catalystLibraryExtension],
      };
}