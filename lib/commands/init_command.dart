import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:yaml/yaml.dart';

class InitCommand extends Command<int> {
  final Logger _logger;
  final bool _hasTerminal;

  InitCommand({Logger? logger, bool? hasTerminal})
    : _logger = logger ?? Logger(),
      _hasTerminal = hasTerminal ?? stdin.hasTerminal {
    argParser.addFlag(
      'force',
      abbr: 'f',
      help: 'Force overwrite existing zuq.yaml without prompting.',
      negatable: false,
    );
  }

  @override
  final String name = 'init';

  @override
  final String description =
      'Initialize zuq configuration for an existing project by auto-detecting settings.';

  @override
  Future<int> run() async {
    final pubspecFile = File('pubspec.yaml');
    if (!pubspecFile.existsSync()) {
      _logger.err('Error: No pubspec.yaml found in the current directory.');
      _logger.info(
        'Please run this command at the root of your Flutter/Dart project.',
      );
      return 1;
    }

    final String pubspecContent;
    try {
      pubspecContent = pubspecFile.readAsStringSync();
    } catch (e) {
      _logger.err('Failed to read pubspec.yaml: $e');
      return 1;
    }

    final dynamic yamlDoc;
    try {
      yamlDoc = loadYaml(pubspecContent);
    } catch (e) {
      _logger.err('Failed to parse pubspec.yaml: $e');
      return 1;
    }

    if (yamlDoc is! Map) {
      _logger.err('Error: Failed to parse pubspec.yaml as a YAML Map.');
      return 1;
    }

    final projectName = yamlDoc['name'] as String? ?? 'app';

    final dependencies = yamlDoc['dependencies'] as Map? ?? {};

    // Detect state management solution
    String stateManagement = 'none';
    if (dependencies.containsKey('flutter_bloc') ||
        dependencies.containsKey('bloc')) {
      stateManagement = 'bloc';
    } else if (dependencies.containsKey('flutter_riverpod') ||
        dependencies.containsKey('riverpod') ||
        dependencies.containsKey('hooks_riverpod')) {
      stateManagement = 'riverpod';
    } else if (dependencies.containsKey('provider')) {
      stateManagement = 'provider';
    }

    // Detect routing solution
    String router = 'none';
    if (dependencies.containsKey('go_router')) {
      router = 'go_router';
    } else if (dependencies.containsKey('auto_route')) {
      router = 'auto_route';
    }

    final zuqYamlFile = File('zuq.yaml');
    bool overwrite = argResults?['force'] as bool? ?? false;

    if (zuqYamlFile.existsSync() && !overwrite) {
      if (_hasTerminal) {
        overwrite = _logger.confirm(
          'A zuq.yaml file already exists in this directory. Do you want to overwrite it?',
          defaultValue: false,
        );
        if (!overwrite) {
          _logger.info('Initialization aborted.');
          return 0;
        }
      } else {
        _logger.err(
          'Error: A zuq.yaml file already exists in this directory. Use --force to overwrite.',
        );
        return 1;
      }
    }

    try {
      zuqYamlFile.writeAsStringSync('''
name: $projectName
state_management: $stateManagement
router: $router
preset: default
modules: []
''');
    } catch (e) {
      _logger.err('Failed to write zuq.yaml: $e');
      return 1;
    }

    _logger.success(
      '✓ Successfully initialized zuq configuration in zuq.yaml!',
    );
    _logger.info('Detected configuration:');
    _logger.info('  - Name: $projectName');
    _logger.info('  - State Management: $stateManagement');
    _logger.info('  - Router: $router');

    final featuresDir = Directory('lib/features');
    if (!featuresDir.existsSync()) {
      _logger.info('\nNext steps:');
      _logger.info(
        '  Run `zuq add feature <feature_name>` to start scaffolding your clean-architecture features.',
      );
    } else {
      _logger.info(
        '\nFound existing lib/features directory. You can run `zuq doctor` to audit layer boundaries.',
      );
    }

    return 0;
  }
}
