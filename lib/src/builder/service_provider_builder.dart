import 'dart:async';
import 'dart:convert';

import 'package:build/build.dart';
import 'package:build_runner_core/build_runner_core.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as p;

import 'dto/dto.dart';
import 'generator/service_provider/service_provider.dart';

/// The ServiceProviderBuilder creates a service provider from the resulting
/// preflight .json files.
class ServiceProviderBuilder implements Builder {
  /// The builder configuration.
  final Map<String, dynamic> config;

  /// Creates a new ServiceProviderBuilder.
  ServiceProviderBuilder(this.config);

  AssetId _outputAsset(BuildStep buildStep) {
    return AssetId(
      buildStep.inputId.package,
      p.join('lib', config['outputName']),
    );
  }

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    var preflightFiles = Glob(
      '**/*${config['preflightExtension']}',
      recursive: true,
    );

    final parts = <PreflightPart>[];
    final services = <ExtractedService>[];

    AssetReader assetReader = buildStep;
    if (config['includePackageDependencies']) {
      assetReader = FileBasedAssetReader(await PackageGraph.forThisPackage());
    }

    await for (final input in assetReader.findAssets(preflightFiles)) {
      log.info('Read json from ${input.path}');
      var jsonContent = await assetReader.readAsString(input);
      var part = PreflightPart.fromJson(
        jsonDecode(jsonContent),
      );
      parts.add(part);
      services.addAll(part.services);
    }

    final emitter = DartEmitter.scoped(
      orderDirectives: true,
      useNullSafetySyntax: true,
    );

    final rawOutput = Library((l) => l.body.addAll([
          buildServiceProviderClass(config, services),
        ])).accept(emitter).toString();
    final content = DartFormatter().format('''
// ignore_for_file: prefer_relative_imports, public_member_api_docs, implementation_imports, no_leading_underscores_for_library_prefixes
$rawOutput
''');
    await buildStep.writeAsString(_outputAsset(buildStep), content);
  }

  @override
  Map<String, List<String>> get buildExtensions => {
        r'$lib$': [config['outputName']],
      };
}

/// Builds the service provider
Builder buildServiceProvider(BuilderOptions options) =>
    ServiceProviderBuilder(options.config);
