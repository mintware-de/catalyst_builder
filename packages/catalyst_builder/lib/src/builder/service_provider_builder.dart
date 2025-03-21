import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';

import '../cache_helper.dart';
import 'constants.dart';
import 'dto/dto.dart';
import 'generator/service_provider/service_provider.dart';

/// The ServiceProviderBuilder creates a service provider from the resulting
/// preflight .json files.
class ServiceProviderBuilder implements PostProcessBuilder {
  final CacheHelper _cacheHelper = CacheHelper();

  @override
  FutureOr<void> build(PostProcessBuildStep buildStep) async {
    await for (final input in _cacheHelper.entrypointFiles) {
      log.info('Generating entrypoint ${input.path}');
      final entrypointFile = File(input.path);

      var entrypoint = Entrypoint.fromJson(
        jsonDecode(
          await entrypointFile.readAsString(),
        ) as Map<String, dynamic>,
      );

      var content = await _generateCode(entrypoint);
      var outFileName = AssetId.resolve(entrypoint.assetId)
          .changeExtension(serviceProviderExtension)
          .path;
      var outFile = File(outFileName);
      if (!outFile.existsSync()) {
        outFile.createSync(recursive: true);
      }

      await outFile.writeAsString(content);
    }
  }

  Future<String> _generateCode(Entrypoint entrypoint) async {
    final parts = <PreflightPart>[];
    final services = <ExtractedService>[];

    final source = entrypoint.includePackageDependencies
        ? _cacheHelper.preflightFiles
        : _cacheHelper.getPreflightFilesForPackage(
            entrypoint.assetId.pathSegments.first,
          );

    await for (final input in source) {
      final jsonContent = await File(input.path).readAsString();
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
  Iterable<String> get inputExtensions =>
      [entrypointExtension, preflightExtension];
}
