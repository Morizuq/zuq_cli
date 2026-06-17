import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:zuq_cli/core/config/config_parser.dart';
import 'package:zuq_cli/core/module/base/module.dart';
import 'package:zuq_cli/core/module/base/project_context.dart';
import 'package:zuq_cli/core/module/networking_module.dart';
import 'package:zuq_cli/core/module/routing_module.dart';
import 'package:zuq_cli/core/module/storage_module.dart';
import 'package:zuq_cli/core/module/theme_module.dart';
import 'package:zuq_cli/core/module/l10n_module.dart';
import 'package:zuq_cli/core/module/analytics_module.dart';
import 'package:zuq_cli/core/process_runner.dart';

class AddModuleCommand extends Command<int> {
  final ConfigParser _configParser;
  final ProcessRunner _processRunner;
  final Logger _logger;

  @override
  final String name = 'module';

  @override
  final String description = 'Add an installable module to the current project.';

  final Map<String, Module> _modules = {
    'networking': NetworkingModule(),
    'routing': RoutingModule(),
    'storage': StorageModule(),
    'theme': ThemeModule(),
    'l10n': L10nModule(),
    'analytics': AnalyticsModule(),
  };

  AddModuleCommand({
    ConfigParser configParser = const ConfigParser(),
    ProcessRunner processRunner = const ProcessRunner(),
    Logger? logger,
  }) : _configParser = configParser,
       _processRunner = processRunner,
       _logger = logger ?? Logger();

  @override
  Future<int> run() async {
    if (argResults == null || argResults!.rest.isEmpty) {
      _logger.err('Error: Please specify the module name to add.');
      _logger.info('Usage: zuq add module <module_name>');
      _logger.info('Available modules: ${_modules.keys.join(', ')}');
      return 1;
    }

    final moduleName = argResults!.rest.first.toLowerCase();
    final module = _modules[moduleName];

    if (module == null) {
      _logger.err('Error: Module "$moduleName" is not recognized.');
      _logger.info('Available modules: ${_modules.keys.join(', ')}');
      return 1;
    }

    final projectConfig = _configParser.readConfig(fallbackProjectName: '');
    if (projectConfig == null) {
      _logger.err('Error: No zuq.yaml configuration found in this directory.');
      _logger.err('Make sure you are at the root of a zuq project.');
      return 1;
    }

    final projectPath = Directory.current.path;
    final context = ProjectContext(
      projectName: projectConfig.projectName,
      projectPath: projectPath,
      stateManagement: projectConfig.stateManagement,
      router: projectConfig.router,
    );

    final progress = _logger.progress('Installing $moduleName module...');
    try {
      await module.install(context);
      progress.complete('$moduleName module files generated.');
    } catch (e) {
      progress.fail('Failed to generate files for $moduleName: $e');
      return 1;
    }

    // Install dependencies if registered by the module
    if (context.corePackages.isNotEmpty) {
      final coreInstallProgress = _logger.progress(
        'Installing packages for $moduleName: ${context.corePackages.join(', ')}',
      );
      final coreResult = await _processRunner.run('flutter', [
        'pub',
        'add',
        ...context.corePackages,
      ], workingDirectory: projectPath);

      if (coreResult.exitCode != 0) {
        coreInstallProgress.fail('Failed to install module packages.');
        return coreResult.exitCode;
      }
      coreInstallProgress.complete('Packages installed.');
    }

    if (context.devPackages.isNotEmpty) {
      final devInstallProgress = _logger.progress(
        'Installing dev packages for $moduleName: ${context.devPackages.join(', ')}',
      );
      final devResult = await _processRunner.run('flutter', [
        'pub',
        'add',
        '--dev',
        ...context.devPackages,
      ], workingDirectory: projectPath);

      if (devResult.exitCode != 0) {
        devInstallProgress.fail('Failed to install module dev packages.');
        return devResult.exitCode;
      }
      devInstallProgress.complete('Dev packages installed.');
    }

    _logger.success('Successfully added module $moduleName!');
    return 0;
  }
}
