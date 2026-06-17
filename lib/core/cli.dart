import 'package:args/command_runner.dart';
import 'package:zuq_cli/commands/create_command.dart';
import 'package:zuq_cli/commands/add_command.dart';

class ZuqCli {
  final CommandRunner<int> runner;

  ZuqCli()
    : runner = CommandRunner<int>(
        'zuq',
        'A custom developer CLI for streamling flutter workflows.',
      ) {
    runner.addCommand(CreateCommand());
    runner.addCommand(AddCommand());
  }

  // Entry point to execute commands
  Future<int> run(List<String> args) async {
    try {
      final exitCode = await runner.run(args);
      return exitCode ?? 0;
    } on UsageException catch (e) {
      print(e);
      return 64; // Standard command line error code
    } catch (e) {
      print('An unexpected error occurred: $e');
      return 1;
    }
  }
}
