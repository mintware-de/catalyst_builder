import 'dart:async';
import 'dart:convert';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:glob/glob.dart';

import 'constants.dart';
import 'dto/dto.dart';
import 'generator/service_container/service_container_plugin.dart';
import 'helpers.dart';
import 'validation/service_graph_validator.dart';

/// The ServiceContainerPluginBuilder creates a plugin from the resulting
/// preflight .json files.
class ServiceContainerPluginBuilder implements Builder {
  /// How the collected messages of the service graph validation are
  /// treated.
  final ValidationMode validation;

  /// Creates a new [ServiceContainerPluginBuilder].
  ServiceContainerPluginBuilder({this.validation = ValidationMode.warn});

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

    var annotation = libraryElement.children
        .whereType<Element>()
        .map((el) => el.metadata.annotations.where(
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

  /// Validates the service graph and reports the messages according to
  /// [validation].
  ///
  /// In [ValidationMode.warn] (the default) errors abort the build and
  /// warnings are logged. [ValidationMode.strict] aborts the build for
  /// errors and warnings, [ValidationMode.off] does nothing.
  void _validate(List<ExtractedService> services) {
    if (validation == ValidationMode.off) {
      return;
    }

    var messages = validateServiceGraph(services);
    if (messages.isEmpty) {
      return;
    }

    var errors =
        messages.where((m) => m.severity == ValidationSeverity.error).toList();
    var warnings = messages
        .where((m) => m.severity == ValidationSeverity.warning)
        .toList();

    if (validation == ValidationMode.strict) {
      if (messages.isNotEmpty) {
        throw StateError(
          'catalyst_builder found problems in the service graph:\n'
          '${messages.map((m) => '  - $m').join('\n')}',
        );
      }
      return;
    }

    for (var warning in warnings) {
      log.warning(warning.message);
    }
    if (errors.isNotEmpty) {
      throw StateError(
        'catalyst_builder found problems in the service graph:\n'
        '${errors.map((m) => '  - $m').join('\n')}',
      );
    }
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

    _validate(services);

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
