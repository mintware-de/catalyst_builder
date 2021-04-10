import 'dart:async';
import 'dart:io' show stdout;

import 'package:build/build.dart';
import 'package:di_experimental/src/builder/preflight_storage.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:analyzer/dart/element/element.dart';

import 'generator/service_container.tpl.dart';

class ContainerBuilder implements Builder {
  bool _containerBuild = false;

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    stdout.writeln('Build: ${buildStep.inputId}');
    if (!await buildStep.resolver.isLibrary(buildStep.inputId)) return;

    final storage = await buildStep.fetchResource(preflightResource);

    final entryLib = await buildStep.inputLibrary;
    if (_containerBuild) {
      return;
    }

    var isContainerRoot = false;
    for (var el in entryLib.topLevelElements) {
      for (var annotation in el.metadata) {
        var annotationName = annotation.element?.enclosingElement?.name;
        if (annotationName == 'ContainerRoot') {
          isContainerRoot = true;
          break;
        }
      }
    }

    if (!isContainerRoot) {
      return;
    }
    _containerBuild = true;

    final containerLibraryAsset =
        buildStep.inputId.changeExtension('.container.dart');

    final emitter = DartEmitter.scoped(
      orderDirectives: true,
      useNullSafetySyntax: true,
    );

    final rawOutput = Library((l) => l.body.addAll([
          buildServiceContainerTemplate(emitter, storage),
        ])).accept(emitter).toString();
    final content = DartFormatter().format('''
// ignore_for_file: prefer_relative_imports, public_member_api_docs
$rawOutput
''');
    await buildStep.writeAsString(containerLibraryAsset, content);
  }

  @override
  Map<String, List<String>> get buildExtensions => const {
        '.dart': ['.container.dart'],
      };
}

Builder buildContainer(BuilderOptions options) => ContainerBuilder();
