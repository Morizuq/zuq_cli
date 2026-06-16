import 'dart:io';

import 'package:mason_logger/mason_logger.dart';
import 'package:zuq_cli/core/dependency_resolver.dart';
import 'package:zuq_cli/core/process_runner.dart';
import 'package:zuq_cli/generator/directory_generator.dart';
import 'package:zuq_cli/generator/template_generator.dart';

import 'package:path/path.dart' as p;

class ProjectGenerator {
  final DirectoryGenerator _directoryGenerator;
  final TemplateGenerator _templateGenerator;
  final DependencyResolver _dependencyResolver;
  final ProcessRunner _processRunner;
  final Logger _logger;

  ProjectGenerator({
    DirectoryGenerator directoryGenerator = const DirectoryGenerator(),
    TemplateGenerator templateGenerator = const TemplateGenerator(),
    DependencyResolver dependencyResolver = const DependencyResolver(),
    ProcessRunner processRunner = const ProcessRunner(),
    Logger? logger,
  }) : _directoryGenerator = directoryGenerator,
       _templateGenerator = templateGenerator,
       _dependencyResolver = dependencyResolver,
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

    final isRiverpod = stateManagement == 'riverpod';
    final isBloc = stateManagement == 'bloc';
    final isProvider = stateManagement == 'provider';
    final isNone = stateManagement == 'none';

    final isGoRouter = router == 'go_router';
    final isAutoRoute = router == 'auto_route';

    final masonProgress = _logger.progress(
      'Generating architecture templates via Mason',
    );
    await _templateGenerator.generateProjectCore(
      projectPath: projectPath,
      projectName: projectName,
      isRiverpod: isRiverpod,
      isBloc: isBloc,
      isProvider: isProvider,
      isNone: isNone,
      isGoRouter: isGoRouter,
      isAutoRoute: isAutoRoute,
    );
    masonProgress.complete('Architecture templates generated.');

    // - Resolve and Install deps
    final corePackages = _dependencyResolver.resolveCorePackages(
      stateManagement: stateManagement,
      router: router,
    );
    final devPackages = _dependencyResolver.resolveDevPackages(router: router);

    // - Install core packages
    final coreInstallProgress = _logger.progress(
      'Installing core packages: ${corePackages.join(', ')}',
    );
    final coreResult = await _processRunner.run('flutter', [
      'pub',
      'add',
      ...corePackages,
    ], workingDirectory: projectPath);
    if (coreResult.exitCode != 0) {
      coreInstallProgress.fail('Failed to install core packages.');
      return coreResult.exitCode;
    }
    coreInstallProgress.complete('Core packages installed.');

    // - Install dev packages if needed
    if (devPackages.isNotEmpty) {
      final devInstallProgress = _logger.progress(
        'Installing dev packages: ${devPackages.join(', ')}',
      );
      final devResult = await _processRunner.run('flutter', [
        'pub',
        'add',
        '--dev',
        ...devPackages,
      ]);

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
