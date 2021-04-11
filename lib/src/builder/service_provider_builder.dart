import 'dart:async';
import 'dart:convert';

import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as p;

import 'dto/dto.dart';
import 'generator/service_provider.tpl.dart';

/// The ServiceProviderBuilder creates a service provider from the resulting
/// .preflight.json files.
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
    var preflightFiles = Glob('**/*.preflight.json');
    final parts = <PreflightPart>[];
    final services = <ExtractedService>[];
    await for (final input in buildStep.findAssets(preflightFiles)) {
      log.info('Read json from ${input.path}');
      var jsonContent = await buildStep.readAsString(input);
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
// ignore_for_file: prefer_relative_imports, public_member_api_docs
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
