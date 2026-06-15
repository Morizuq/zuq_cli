import 'dart:io';

import 'package:args/command_runner.dart';

class CreateCommand extends Command<int> {
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
      print('Successfully created project $projectName');
      return 0;
    } else {
      print('Error Scaffolding project:');
      print(process.stderr);
      return process.exitCode;
    }
  }
}
