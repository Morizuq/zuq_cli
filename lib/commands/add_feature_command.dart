import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:mason/mason.dart';
import 'package:mason_logger/mason_logger.dart' as ml;
import 'package:zuq_cli/core/config/config_parser.dart';
import 'package:path/path.dart' as p;
import 'package:zuq_cli/core/utils/templates_locator.dart';

class AddFeatureCommand extends Command<int> {
  final ConfigParser _configParser;
  final ml.Logger _logger;

  @override
  final String name = 'feature';

  @override
  final String description = 'Add a new feature structure to the project.';

  AddFeatureCommand({
    ConfigParser configParser = const ConfigParser(),
    ml.Logger? logger,
  }) : _configParser = configParser,
       _logger = logger ?? ml.Logger();

  @override
  Future<int> run() async {
    if (argResults == null || argResults!.rest.isEmpty) {
      _logger.err('Error: Please specify the feature name to add.');
      _logger.info('Usage: zuq add feature <feature_name>');
      return 1;
    }

    final featureName = argResults!.rest.first;

    final projectConfig = _configParser.readConfig(fallbackProjectName: '');
    if (projectConfig == null) {
      _logger.err('Error: No zuq.yaml configuration found in this directory.');
      _logger.err('Make sure you are at the root of a zuq project.');
      return 1;
    }

    final projectPath = Directory.current.path;
    final featuresPath = p.join(projectPath, projectConfig.featuresPath);

    final progress = _logger.progress('Scaffolding feature $featureName...');

    try {
      final templatesPath = TemplatesLocator.getTemplatesPath();
      final brickPath = p.join(templatesPath, 'feature');
      final brick = Brick.path(brickPath);
      final generator = await MasonGenerator.fromBrick(brick);

      final variables = <String, dynamic>{
        'name': featureName,
        'isRiverpod': projectConfig.stateManagement == 'riverpod',
        'isBloc': projectConfig.stateManagement == 'bloc',
        'isProvider': projectConfig.stateManagement == 'provider',
        'isNone': projectConfig.stateManagement == 'none',
      };

      // Target lib/features folder
      final target = DirectoryGeneratorTarget(Directory(featuresPath));
      await generator.generate(target, vars: variables, logger: Logger());
      
      progress.complete('Feature $featureName files generated.');
    } catch (e) {
      progress.fail('Failed to generate feature $featureName: $e');
      return 1;
    }

    _logger.success('Successfully added feature $featureName under ${projectConfig.featuresPath}!');
    return 0;
  }
}
