import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import '../constants.dart' as c;

/// Represents the config file for advanced configuration
class Config {
  /// The directory for the builder cache.
  /// This could be an relative or absolute path.
  String cacheDir;

  /// Creates the config object
  Config({
    this.cacheDir = c.cacheDir,
  });

  /// Load the configuration from [configFileName] or fallback to the default.
  factory Config.load() {
    var configFile = File(p.join(p.current, 'pubspec.yaml'));

    if (configFile.existsSync()) {
      var content = loadYaml(configFile.readAsStringSync()) as YamlMap;
      if (content.containsKey('catalyst_builder')) {
        var yamlJson = jsonEncode(content['catalyst_builder']);
        var configFromYaml = jsonDecode(yamlJson) as Map;
        return Config.fromJson(configFromYaml.cast());
      }
    }

    return Config();
  }

  /// Creates a new instance from the result of [toJson].
  factory Config.fromJson(Map<String, dynamic> json) {
    return Config(
      cacheDir: json['cacheDir']?.toString() ?? c.cacheDir,
    );
  }
}
