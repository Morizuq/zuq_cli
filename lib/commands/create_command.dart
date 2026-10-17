import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as p;
import 'package:zuq_cli/core/config/config_parser.dart';
import 'package:zuq_cli/core/config/project_name_resolver.dart';
import 'package:zuq_cli/generator/project_generator.dart';

class CreateCommand extends Command<int> {
  final ProjectGenerator _projectGenerator;
  final ConfigParser _configParser;
  final ProjectNameResolver _projectNameResolver;
  final Logger _logger;

  CreateCommand({
    ProjectGenerator? projectGenerator,
    ConfigParser configParser = const ConfigParser(),
    ProjectNameResolver projectNameResolver = const ProjectNameResolver(),
    Logger? logger,
  }) : _projectGenerator =
           projectGenerator ?? ProjectGenerator(logger: Logger()),
       _configParser = configParser,
       _projectNameResolver = projectNameResolver,
       _logger = logger ?? Logger() {
    argParser.addOption(
      'name',
      abbr: 'n',
      help: 'The Dart package name for the project (defaults to folder name when creating in current directory).',
    );

    argParser.addOption(
      'state',
      abbr: 's',
      help: 'The state management solution to use',
      allowed: ['riverpod', 'bloc', 'provider', 'none'],
      defaultsTo: 'none',
    );

    argParser.addOption(
      'router',
      abbr: 'r',
      help: 'The routing solution to use',
      allowed: ['go_router', 'auto_route', 'none'],
      defaultsTo: 'go_router',
    );

    argParser.addOption(
      'preset',
      abbr: 'p',
      help: 'The preset architecture template to scaffold',
      allowed: ['default', 'fintech', 'ecommerce'],
      defaultsTo: 'default',
    );

    argParser.addMultiOption(
      'platforms',
      help: 'The platforms supported by this project.',
      allowed: ['android', 'ios', 'web', 'macos', 'linux', 'windows'],
    );
  }

  @override
  String get description => 'Create a new flutter application skeleton';

  @override
  String get name => 'create';

  @override
  Future<int> run() async {
    if (argResults == null || argResults!.rest.isEmpty) {
      _logger.err('Error: Please specify project name or directory target (e.g. zuq create my_app or zuq create .)');
      _logger.info('Usage: zuq create <project_name_or_target_directory>');
      return 1;
    }

    final rawTarget = argResults!.rest.first;
    final explicitName = argResults?['name'] as String?;

    final isCurrentDirectory = rawTarget == '.' || rawTarget.trim().isEmpty;
    final targetPath = isCurrentDirectory
        ? Directory.current.path
        : p.normalize(p.join(Directory.current.path, rawTarget));

    final resolvedProjectName = _projectNameResolver.resolve(
      rawTarget: rawTarget,
      overrideName: explicitName,
      currentDirectory: Directory(targetPath),
    );

    final fileConfig = _configParser.readConfig(
      fallbackProjectName: resolvedProjectName,
    );

    final String finalState;
    final String finalRouter;
    final String finalPreset;
    final String finalName;

    if (fileConfig != null) {
      _logger.info('Using configuration from zuq.yaml');
      finalName = fileConfig.projectName;
      finalState = fileConfig.stateManagement;
      finalRouter = fileConfig.router;
      finalPreset = fileConfig.preset;
    } else {
      _logger.info(
        'No configuration file found. Using command line arguments.',
      );
      finalName = resolvedProjectName;

      final results = argResults;
      if (results != null) {
        if (results.wasParsed('state')) {
          finalState = results['state'] as String;
        } else if (stdin.hasTerminal) {
          finalState = _logger.chooseOne(
            'Select state management solution:',
            choices: ['riverpod', 'bloc', 'provider', 'none'],
            defaultValue: 'none',
          );
        } else {
          finalState = results['state'] as String;
        }

        if (results.wasParsed('router')) {
          finalRouter = results['router'] as String;
        } else if (stdin.hasTerminal) {
          finalRouter = _logger.chooseOne(
            'Select routing solution:',
            choices: ['go_router', 'auto_route', 'none'],
            defaultValue: 'go_router',
          );
        } else {
          finalRouter = results['router'] as String;
        }

        if (results.wasParsed('preset')) {
          finalPreset = results['preset'] as String;
        } else if (stdin.hasTerminal) {
          finalPreset = _logger.chooseOne(
            'Select preset architecture template:',
            choices: ['default', 'fintech', 'ecommerce'],
            defaultValue: 'default',
          );
        } else {
          finalPreset = results['preset'] as String;
        }
      } else {
        finalState = 'none';
        finalRouter = 'go_router';
        finalPreset = 'default';
      }
    }

    List<String> finalPlatforms =
        argResults?['platforms'] as List<String>? ?? [];
    if (finalPlatforms.isEmpty) {
      if (stdin.hasTerminal) {
        finalPlatforms = _logger.chooseAny(
          'Select target platforms (use Space to select, Enter to confirm):',
          choices: ['android', 'ios', 'web', 'macos', 'linux', 'windows'],
          defaultValues: ['android', 'ios'],
        );
      } else {
        finalPlatforms = ['android', 'ios', 'web', 'macos', 'linux', 'windows'];
      }
    }

    return await _projectGenerator.generate(
      projectName: finalName,
      targetPath: targetPath,
      stateManagement: finalState,
      router: finalRouter,
      preset: finalPreset,
      platforms: finalPlatforms,
    );
  }
}
