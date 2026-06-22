import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';
import 'package:zuq_cli/commands/init_command.dart';

class MockLogger extends Logger {
  final List<String> errorMessages = [];
  final List<String> infoMessages = [];
  final List<String> successMessages = [];
  bool confirmResponse = true;

  @override
  void err(String? message, {LogStyle? style}) {
    if (message != null) errorMessages.add(message);
  }

  @override
  void info(String? message, {LogStyle? style}) {
    if (message != null) infoMessages.add(message);
  }

  @override
  void success(String? message, {LogStyle? style}) {
    if (message != null) successMessages.add(message);
  }

  @override
  bool confirm(String? message, {bool defaultValue = false}) => confirmResponse;
}

void main() {
  group('InitCommand', () {
    late Directory tempDir;
    late Directory originalDir;
    late MockLogger logger;
    late CommandRunner<int> runner;

    setUp(() {
      originalDir = Directory.current;
      tempDir = Directory.systemTemp.createTempSync('zuq_init_test_');
      Directory.current = tempDir;

      logger = MockLogger();
      runner = CommandRunner<int>('zuq', 'test runner')
        ..addCommand(InitCommand(logger: logger, hasTerminal: true));
    });

    tearDown(() {
      Directory.current = originalDir;
      try {
        tempDir.deleteSync(recursive: true);
      } catch (_) {}
    });

    test('should fail if pubspec.yaml does not exist', () async {
      final exitCode = await runner.run(['init']);

      expect(exitCode, equals(1));
      expect(
        logger.errorMessages.first,
        contains('No pubspec.yaml found in the current directory'),
      );
    });

    test(
      'should detect project configuration from pubspec.yaml and generate zuq.yaml',
      () async {
        final pubspecFile = File('pubspec.yaml');
        pubspecFile.writeAsStringSync('''
name: my_test_project
dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^8.1.3
  go_router: ^12.1.3
''');

        final exitCode = await runner.run(['init']);
        expect(exitCode, equals(0));

        final zuqYamlFile = File('zuq.yaml');
        expect(zuqYamlFile.existsSync(), isTrue);

        final yamlContent = zuqYamlFile.readAsStringSync();
        final doc = loadYaml(yamlContent) as Map;

        expect(doc['name'], equals('my_test_project'));
        expect(doc['state_management'], equals('bloc'));
        expect(doc['router'], equals('go_router'));
        expect(doc['preset'], equals('default'));
        expect(doc['modules'], isEmpty);
      },
    );

    test('should fall back to none if no state or router is present', () async {
      final pubspecFile = File('pubspec.yaml');
      pubspecFile.writeAsStringSync('''
name: plain_project
dependencies:
  flutter:
    sdk: flutter
''');

      final exitCode = await runner.run(['init']);
      expect(exitCode, equals(0));

      final zuqYamlFile = File('zuq.yaml');
      final doc = loadYaml(zuqYamlFile.readAsStringSync()) as Map;

      expect(doc['name'], equals('plain_project'));
      expect(doc['state_management'], equals('none'));
      expect(doc['router'], equals('none'));
    });

    test('should overwrite existing zuq.yaml if force is passed', () async {
      final pubspecFile = File('pubspec.yaml');
      pubspecFile.writeAsStringSync('name: updated_project\ndependencies:\n');

      final zuqYamlFile = File('zuq.yaml');
      zuqYamlFile.writeAsStringSync('old config');

      final exitCode = await runner.run(['init', '--force']);
      expect(exitCode, equals(0));

      final doc = loadYaml(zuqYamlFile.readAsStringSync()) as Map;
      expect(doc['name'], equals('updated_project'));
    });

    test(
      'should abort overwriting if confirm is false and force is not passed',
      () async {
        final pubspecFile = File('pubspec.yaml');
        pubspecFile.writeAsStringSync('name: updated_project\ndependencies:\n');

        final zuqYamlFile = File('zuq.yaml');
        zuqYamlFile.writeAsStringSync('old config');

        logger.confirmResponse = false;

        final exitCode = await runner.run(['init']);
        expect(exitCode, equals(0));
        expect(zuqYamlFile.readAsStringSync(), equals('old config'));
        expect(logger.infoMessages, contains('Initialization aborted.'));
      },
    );

    test(
      'should fail in non-interactive environment when overwriting without force',
      () async {
        final pubspecFile = File('pubspec.yaml');
        pubspecFile.writeAsStringSync('name: updated_project\ndependencies:\n');

        final zuqYamlFile = File('zuq.yaml');
        zuqYamlFile.writeAsStringSync('old config');

        final localRunner = CommandRunner<int>('zuq', 'test runner')
          ..addCommand(InitCommand(logger: logger, hasTerminal: false));

        final exitCode = await localRunner.run(['init']);
        expect(exitCode, equals(1));
        expect(zuqYamlFile.readAsStringSync(), equals('old config'));
        expect(
          logger.errorMessages.first,
          contains(
            'Error: A zuq.yaml file already exists in this directory. Use --force to overwrite.',
          ),
        );
      },
    );
  });
}
