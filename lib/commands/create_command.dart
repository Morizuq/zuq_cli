import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;
import 'package:zuq_cli/generator/directory_generator.dart';

class CreateCommand extends Command<int> {
  CreateCommand({DirectoryGenerator? directoryGenerator})
    : _directoryGenerator = directoryGenerator ?? const DirectoryGenerator();

  final DirectoryGenerator _directoryGenerator;

  @override
  String get description => 'Create a new flutter application skeleton';

  @override
  String get name => 'create';

  @override
  Future<int> run() async {
    if (argResults == null || argResults!.rest.isEmpty) {
      print('Error: Please specifiy project name');
      print('Usage: zuq create <project_name>');
      return 1;
    }

    final projectName = argResults!.rest.first;
    print('Scaffolding new Flutter project: $projectName...');

    final process = await Process.run('flutter', [
      'create',
      projectName,
    ], runInShell: true);

    if (process.exitCode == 0) {
      print(process.stdout);
      final projectPath = p.join(Directory.current.path, projectName);
      final libPath = p.join(projectPath, 'lib');
      print('Generating base directory structure in $libPath...');

      await _directoryGenerator.generate(libPath);

      print('\nSuccessfully created project $projectName');
      return 0;
    } else {
      print('Error Scaffolding project:');
      print(process.stderr);
      return process.exitCode;
    }
  }
}
