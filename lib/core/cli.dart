import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:zuq_cli/commands/create_command.dart';
import 'package:zuq_cli/commands/add_command.dart';
import 'package:zuq_cli/commands/doctor_command.dart';
import 'package:zuq_cli/commands/upgrade_command.dart';
import 'package:zuq_cli/commands/check_update_command.dart';
import 'package:zuq_cli/commands/init_command.dart';
import 'package:zuq_cli/core/utils/update_checker.dart';

class ZuqCli {
  final CommandRunner<int> runner;
  final Logger _logger;

  ZuqCli({Logger? logger})
    : _logger = logger ?? Logger(),
      runner = CommandRunner<int>(
        'zuq',
        'A custom developer CLI for streamling flutter workflows.',
      ) {
    runner.addCommand(CreateCommand(logger: _logger));
    runner.addCommand(AddCommand(logger: _logger));
    runner.addCommand(DoctorCommand(logger: _logger));
    runner.addCommand(UpgradeCommand(logger: _logger));
    runner.addCommand(CheckUpdateCommand());
    runner.addCommand(InitCommand(logger: _logger));
  }

  // Entry point to execute commands
  Future<int> run(List<String> args) async {
    try {
      // Trigger background update check (async, does not block)
      UpdateChecker.triggerBackgroundCheck(args);

      final exitCode = await runner.run(args);

      // Print update notification if a newer version is cached
      UpdateChecker.printUpdateNotificationIfNeeded(args, _logger);

      return exitCode ?? 0;
    } on UsageException catch (e) {
      _logger.err(e.message);
      _logger.info(e.usage);
      return 64; // Standard command line error code
    } catch (e) {
      _logger.err('An unexpected error occurred: $e');
      return 1;
    }
  }
}
