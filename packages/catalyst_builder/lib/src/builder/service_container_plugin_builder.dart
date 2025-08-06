import 'dart:async';
import 'dart:convert';

import 'package:analyzer/dart/element/element2.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:glob/glob.dart';

import 'constants.dart';
import 'dto/dto.dart';
import 'generator/service_container/service_container_plugin.dart';
import 'helpers.dart';

/// The ServiceContainerPluginBuilder creates a plugin from the resulting
/// preflight .json files.
class ServiceContainerPluginBuilder implements Builder {
  @override
  FutureOr<void> build(BuildStep buildStep) async {
    if (!await buildStep.resolver.isLibrary(buildStep.inputId)) {
      return;
    }
    LibraryElement2 libraryElement;
    try {
      libraryElement = (await buildStep.inputLibrary);
    } catch (e) {
      log.warning('Error while processing input library. Skip for now.', e);
      return;
    }

    var annotation = libraryElement.children2
        .whereType<Annotatable>()
        .map((el) => el.metadata2.annotations.where(
            (m) => m.isLibraryAnnotation('GenerateServiceContainerPlugin')))
        .fold(<ElementAnnotation>[], (prev, e) => [...prev, ...e]).firstOrNull;

    var isEntryPoint = annotation != null;
    if (!isEntryPoint) {
      return;
    }

    var constantValue = annotation.computeConstantValue()!;
    var pluginClassName =
        constantValue.getField('pluginClassName')!.toStringValue()!;

    var content = await _generateCode(buildStep, pluginClassName);
    await buildStep.writeAsString(
      buildStep.inputId.changeExtension(serviceContainerPluginExtension),
      content,
    );
  }

  Future<String> _generateCode(
      BuildStep buildStep, String pluginClassName) async {
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
      (l) => l.body.addAll([
        buildServiceContainerPluginClass(pluginClassName, services),
        buildExtension(pluginClassName),
      ]),
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
        r'.dart': [serviceContainerPluginExtension],
      };
}
