import 'dart:io';

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

  const ProjectGenerator({
    DirectoryGenerator directoryGenerator = const DirectoryGenerator(),
    TemplateGenerator templateGenerator = const TemplateGenerator(),
    DependencyResolver dependencyResolver = const DependencyResolver(),
    ProcessRunner processRunner = const ProcessRunner(),
  }) : _directoryGenerator = directoryGenerator,
       _templateGenerator = templateGenerator,
       _dependencyResolver = dependencyResolver,
       _processRunner = processRunner;

  Future<int> generate({
    required String projectName,
    required String stateManagement,
    required String router,
  }) async {
    print('Scaffolding new Flutter project: $projectName');

    // - Run flutter create
    final createResult = await _processRunner.run('flutter', [
      'create',
      projectName,
    ]);

    if (createResult.exitCode != 0) {
      print('Error Scaffolding project.');
      print(createResult.stderr);
      return createResult.exitCode;
    }

    print(createResult.stdout);

    final projectPath = p.join(Directory.current.path, projectName);
    final libPath = p.join(projectPath, 'lib');

    // - Clean default main.dart
    final defaultMain = File(p.join(libPath, 'main.dart'));

    if (defaultMain.existsSync()) {
      defaultMain.deleteSync();
    }

    print('Generating base directory structure in $libPath...');
    await _directoryGenerator.generate(libPath);

    final isRiverpod = stateManagement == 'riverpod';
    final isBloc = stateManagement == 'bloc';
    final isProvider = stateManagement == 'provider';
    final isNone = stateManagement == 'none';

    final isGoRouter = router == 'go_router';
    final isAutoRoute = router == 'auto_route';

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

    // - Resolve and Install deps
    final corePackages = _dependencyResolver.resolveCorePackages(
      stateManagement: stateManagement,
      router: router,
    );
    final devPackages = _dependencyResolver.resolveDevPackages(router: router);

    // - Install core packages
    print('Installing core packages: ${corePackages.join(', ')}...');
    final coreResult = await _processRunner.run('flutter', [
      'pub',
      'add',
      ...corePackages,
    ], workingDirectory: projectPath);
    if (coreResult.exitCode != 0) {
      print('Error installing core packages:\n${coreResult.stderr}');
      return coreResult.exitCode;
    }

    // - Install dev packages if needed
    if (devPackages.isNotEmpty) {
      print('Installing dev packages: ${devPackages.join(', ')}');
      final devResult = await _processRunner.run('flutter', [
        'pub',
        'add',
        '--dev',
        ...devPackages,
      ]);

      if (devResult.exitCode != 0) {
        print('Error installing dev packages.');
        print(devResult.stderr);
        return devResult.exitCode;
      }
    }

    print('\nSuccessfully created project $projectName');
    print('Navigate to project directory: cd $projectName');
    print('Run "flutter run" to start the application.');
    return 0;
  }
}
