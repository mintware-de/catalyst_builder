import 'dart:async';
import 'dart:convert';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:catalyst_builder/src/builder/helpers.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:glob/glob.dart';

import 'constants.dart';
import 'dto/dto.dart';
import 'generator/service_provider/service_provider.dart';

/// The ServiceProviderBuilder creates a service provider from the resulting
/// preflight .json files.
class ServiceProviderBuilder implements Builder {
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

    var annotation = libraryElement.topLevelElements
        .map((el) => el.metadata
            .where((m) => m.isLibraryAnnotation('GenerateServiceProvider')))
        .fold(<ElementAnnotation>[], (prev, e) => [...prev, ...e]).firstOrNull;

    var isEntryPoint = annotation != null;
    if (!isEntryPoint) {
      return;
    }

      await outFile.writeAsString(content);
    }
    var constantValue = annotation.computeConstantValue()!;
    var providerClassName =
        constantValue.getField('providerClassName')!.toStringValue()!;

    final entrypoint = Entrypoint(
      providerClassName: providerClassName,
      assetId: buildStep.inputId.uri,
    );

    var content = await _generateCode(buildStep, entrypoint);
    await buildStep.writeAsString(
      buildStep.inputId.changeExtension(serviceProviderExtension),
      content,
    );
  }

  Future<String> _generateCode(
      BuildStep buildStep, Entrypoint entrypoint) async {
    final parts = <PreflightPart>[];
    final services = <ExtractedService>[];

    await for (final input
        in buildStep.findAssets(Glob('**/**$preflightExtension'))) {
      final jsonContent = await buildStep.readAsString(input);
      final part = PreflightPart.fromJson(
        jsonDecode(jsonContent) as Map<String, dynamic>,
      );
      parts.add(part);
      services.addAll(part.services);
    }

    final emitter = DartEmitter.scoped(
      orderDirectives: true,
      useNullSafetySyntax: true,
    );

    final rawOutput = Library(
      (l) => l.body.addAll(
          [buildServiceProviderClass(entrypoint.providerClassName, services)]),
    ).accept(emitter).toString();

    final content =
        DartFormatter(languageVersion: DartFormatter.latestLanguageVersion)
            .format('''
// ignore_for_file: prefer_relative_imports, public_member_api_docs, implementation_imports
    $rawOutput
    ''');
    return content;
  }

  @override
  Map<String, List<String>> get buildExtensions => {
        r'$lib$': [],
        r'.dart': [serviceProviderExtension],
      };
}
