import 'dart:io';

import 'package:yaml/yaml.dart';
import 'package:zuq_cli/core/config/project_config.dart';

class ConfigParser {
  const ConfigParser();

  static const String configFileName = 'zuq.yaml';

  ProjectConfig? readConfig({required String fallbackProjectName}) {
    final configFile = File(configFileName);

    if (!configFile.existsSync()) return null;

    try {
      final content = configFile.readAsStringSync();
      final yamlMap = loadYaml(content) as YamlMap;

      return ProjectConfig.fromMap(
        yamlMap.cast<String, dynamic>(),
        defaultName: fallbackProjectName,
      );
    } catch (e) {
      print(
        'Warning: Failed to parse $configFileName. Falling back to command-line flags. Error: $e',
      );
      return null;
    }
  }
}
