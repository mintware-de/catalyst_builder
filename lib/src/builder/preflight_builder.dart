import 'dart:async';
import 'dart:io' show stdout;

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:di_experimental/src/builder/preflight_storage.dart';

class PreflightBuilder implements Builder {
  PreflightBuilder();

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    if (!await buildStep.resolver.isLibrary(buildStep.inputId)) return;

    final resource = await buildStep.fetchResource(preflightResource);

    final entryLib = await buildStep.inputLibrary;
    _extractAnnotations(entryLib, resource);
  }

  @override
  Map<String, List<String>> get buildExtensions => const {
        '.dart': ['.preflight.dart'],
      };

  void _extractAnnotations(LibraryElement entryLib, PreflightStorage storage) {
    for (var el in entryLib.topLevelElements) {
      for (var annotation in el.metadata) {
        var annotationName = annotation.element?.enclosingElement?.name;
        if (annotationName == 'ContainerRoot') {
          if (storage.containerRoot != null) {
            throw Exception('Could not have multiple ContainerRoots');
          }
          storage.containerRoot = annotation;
        } else if (annotationName == 'Service' && el is ClassElement) {
          storage.services.add(ServiceElementPair(annotation, el));
        }
      }
    }
  }
}

Builder runPreflight(BuilderOptions options) => PreflightBuilder();
