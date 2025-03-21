import 'dart:async';
import 'dart:convert';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';

import 'constants.dart';
import 'dto/dto.dart';
import 'helpers.dart';

/// The EntrypointBuilder scans the files for @GenerateServiceProvider
/// annotations. The result is stored in *entrypoint.json files.
class EntrypointBuilder implements Builder {
  @override
  final Map<String, List<String>> buildExtensions = {
    r'$lib$': [],
    '.dart': [entrypointExtension],
  };

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

    var constantValue = annotation.computeConstantValue()!;
    var providerClassName =
        constantValue.getField('providerClassName')!.toStringValue()!;
    var includePackageDependencies =
        constantValue.getField('includePackageDependencies')!.toBoolValue()!;

    buildStep.writeAsString(
      buildStep.inputId.changeExtension(entrypointExtension),
      jsonEncode(Entrypoint(
        providerClassName: providerClassName,
        includePackageDependencies: includePackageDependencies,
        assetId: buildStep.inputId.uri,
      ).toJson()),
    );
  }
}
