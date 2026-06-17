import 'dart:io';

import 'package:mason_logger/mason_logger.dart';
import 'package:zuq_cli/core/module/base/module.dart';
import 'package:zuq_cli/core/module/base/project_context.dart';
import 'package:zuq_cli/core/module/networking_module.dart';
import 'package:zuq_cli/core/module/routing_module.dart';
import 'package:zuq_cli/core/process_runner.dart';
import 'package:zuq_cli/generator/directory_generator.dart';
import 'package:zuq_cli/generator/template_generator.dart';

import 'package:path/path.dart' as p;

class ProjectGenerator {
  final DirectoryGenerator _directoryGenerator;
  final TemplateGenerator _templateGenerator;
  final ProcessRunner _processRunner;
  final Logger _logger;

  ProjectGenerator({
    DirectoryGenerator directoryGenerator = const DirectoryGenerator(),
    TemplateGenerator templateGenerator = const TemplateGenerator(),
    ProcessRunner processRunner = const ProcessRunner(),
    Logger? logger,
  }) : _directoryGenerator = directoryGenerator,
       _templateGenerator = templateGenerator,
       _processRunner = processRunner,
       _logger = logger ?? Logger();

  Future<int> generate({
    required String projectName,
    required String stateManagement,
    required String router,
  }) async {
    _logger.info('Scaffolding project ${lightCyan.wrap(projectName)}...');

    // - Run flutter create
    final createProgress = _logger.progress('Running "flutter create"');

    final createResult = await _processRunner.run('flutter', [
      'create',
      projectName,
    ]);

    if (createResult.exitCode != 0) {
      print('Error Scaffolding project.');
      print(createResult.stderr);
      return createResult.exitCode;
    }

    createProgress.complete('Flutter project created.');

    final projectPath = p.join(Directory.current.path, projectName);
    final libPath = p.join(projectPath, 'lib');

    // - Create a local zuq.yaml inside the new project for future commands
    final configProgress = _logger.progress('Creating project config file');

    final projectConfigFile = File(p.join(projectPath, 'zuq.yaml'));
    projectConfigFile.writeAsStringSync('''
name: $projectName
state_management: $stateManagement
router: $router
''');

    configProgress.complete('zuq.yaml created inside the project.');

    // - Clean default main.dart
    final defaultMain = File(p.join(libPath, 'main.dart'));

    if (defaultMain.existsSync()) {
      defaultMain.deleteSync();
    }
    // - Generate Directory Structure
    final structProgress = _logger.progress(
      'Generating base directory structure',
    );
    await _directoryGenerator.generate(libPath);
    structProgress.complete('Base directory structure generated.');

    // - Generate Core Project Scaffold from brick
    final scaffoldProgress = _logger.progress(
      'Generating core project scaffold',
    );
    try {
      await _templateGenerator.generateProjectCore(
        projectPath: projectPath,
        projectName: projectName,
        isRiverpod: stateManagement == 'riverpod',
        isBloc: stateManagement == 'bloc',
        isProvider: stateManagement == 'provider',
        isNone: stateManagement == 'none',
        isGoRouter: router == 'go_router',
        isAutoRoute: router == 'auto_route',
      );
      scaffoldProgress.complete('Core project scaffold generated.');
    } catch (e) {
      scaffoldProgress.fail('Failed to generate core project scaffold: $e');
      return 1;
    }

    final context = ProjectContext(
      projectName: projectName,
      projectPath: projectPath,
      stateManagement: stateManagement,
      router: router,
    );

    // Add state management packages based on selection
    if (stateManagement == 'riverpod') {
      context.corePackages.add('flutter_riverpod');
    } else if (stateManagement == 'bloc') {
      context.corePackages.add('flutter_bloc');
    } else if (stateManagement == 'provider') {
      context.corePackages.add('provider');
    }

    final modules = <Module>[RoutingModule(), NetworkingModule()];

    for (final module in modules) {
      final moduleProgress = _logger.progress(
        'Processing ${module.id} module...',
      );
      await module.install(context);
      moduleProgress.complete('${module.id} module processed.');
    }

    if (context.corePackages.isNotEmpty) {
      final coreInstallProgress = _logger.progress(
        'Installing core packages: ${context.corePackages.join(', ')}',
      );
      final coreResult = await _processRunner.run('flutter', [
        'pub',
        'add',
        ...context.corePackages,
      ], workingDirectory: projectPath);
      if (coreResult.exitCode != 0) {
        coreInstallProgress.fail('Failed to install core packages.');
        return coreResult.exitCode;
      }
      coreInstallProgress.complete('Core packages installed.');
    }

    // - Install dev packages if needed
    if (context.devPackages.isNotEmpty) {
      final devInstallProgress = _logger.progress(
        'Installing dev packages: ${context.devPackages.join(', ')}',
      );
      final devResult = await _processRunner.run('flutter', [
        'pub',
        'add',
        '--dev',
        ...context.devPackages,
      ], workingDirectory: projectPath);

      if (devResult.exitCode != 0) {
        devInstallProgress.fail('Failed to install dev packages.');
        return devResult.exitCode;
      }
      devInstallProgress.complete('Dev packages installed.');
    }

    _logger.success('\nSuccessfully created project $projectName!');
    _logger.info(
      'Navigate to project directory: ${lightCyan.wrap('cd $projectName')}',
    );
    _logger.info(
      'Run ${lightGreen.wrap('flutter run')} to start the application.',
    );

    return 0;
  }
}
