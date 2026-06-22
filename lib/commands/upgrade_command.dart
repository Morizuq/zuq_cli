import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:zuq_cli/core/utils/update_checker.dart';

class UpgradeCommand extends Command<int> {
  final Logger _logger;

  UpgradeCommand({Logger? logger}) : _logger = logger ?? Logger();

  @override
  final String name = 'upgrade';

  @override
  final String description = 'Upgrade zuq_cli to the latest version.';

  @override
  Future<int> run() async {
    _logger.info('Upgrading zuq_cli...');
    final progress = _logger.progress('Running dart pub global activate zuq_cli');

    try {
      final process = await Process.start(
        'dart',
        ['pub', 'global', 'activate', 'zuq_cli'],
        mode: ProcessStartMode.inheritStdio,
      );

      final exitCode = await process.exitCode;
      if (exitCode == 0) {
        progress.complete('Successfully upgraded zuq_cli!');
        // Clear local cache so the update prompt doesn't show anymore
        try {
          final cacheFile = UpdateChecker.getCacheFile();
          if (cacheFile.existsSync()) {
            cacheFile.deleteSync();
          }
        } catch (_) {}
        return 0;
      } else {
        progress.fail('Failed to upgrade zuq_cli. Process exited with code $exitCode.');
        return exitCode;
      }
    } catch (e) {
      progress.fail('Failed to upgrade zuq_cli: $e');
      return 1;
    }
  }
}
