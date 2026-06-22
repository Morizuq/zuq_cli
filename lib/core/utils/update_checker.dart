import 'dart:convert';
import 'dart:io';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';
import 'package:zuq_cli/core/version.dart';

class UpdateCache {
  final DateTime lastChecked;
  final String latestVersion;

  UpdateCache({required this.lastChecked, required this.latestVersion});

  factory UpdateCache.fromJson(Map<String, dynamic> json) {
    return UpdateCache(
      lastChecked: DateTime.parse(json['last_checked'] as String),
      latestVersion: json['latest_version'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'last_checked': lastChecked.toIso8601String(),
      'latest_version': latestVersion,
    };
  }
}

class UpdateChecker {
  static const String packageName = 'zuq_cli';

  static File getCacheFile() {
    final home = Platform.isWindows
        ? Platform.environment['USERPROFILE']
        : Platform.environment['HOME'];
    final dirPath = p.join(home ?? Directory.systemTemp.path, '.zuq');
    return File(p.join(dirPath, 'update_cache.json'));
  }

  static UpdateCache? readCache() {
    try {
      final file = getCacheFile();
      if (file.existsSync()) {
        final content = file.readAsStringSync();
        return UpdateCache.fromJson(
          jsonDecode(content) as Map<String, dynamic>,
        );
      }
    } catch (_) {}
    return null;
  }

  static void writeCache(UpdateCache cache) {
    try {
      final file = getCacheFile();
      if (!file.parent.existsSync()) {
        file.parent.createSync(recursive: true);
      }
      file.writeAsStringSync(jsonEncode(cache.toJson()));
    } catch (_) {}
  }

  static void triggerBackgroundCheck(List<String> args) {
    // Avoid running check recursively or during upgrade
    if (args.isNotEmpty &&
        (args.first == '_check_update' || args.first == 'upgrade')) {
      return;
    }

    final cache = readCache();
    final now = DateTime.now();

    if (cache == null ||
        now.difference(cache.lastChecked) > const Duration(hours: 24)) {
      _spawnBackgroundProcess();
    }
  }

  static void _spawnBackgroundProcess() async {
    final executable = Platform.resolvedExecutable;
    final List<String> backgroundArgs;
    if (executable.endsWith('dart') || executable.endsWith('dart.exe')) {
      List<String> args;
      try {
        final scriptPath = Platform.script.toFilePath();
        args = [scriptPath, '_check_update'];
      } catch (_) {
        args = ['_check_update'];
      }
      backgroundArgs = args;
    } else {
      backgroundArgs = ['_check_update'];
    }

    try {
      await Process.start(
        executable,
        backgroundArgs,
        mode: ProcessStartMode.detached,
      );
    } catch (_) {}
  }

  static void printUpdateNotificationIfNeeded(
    List<String> args,
    Logger logger,
  ) {
    if (args.isNotEmpty &&
        (args.first == '_check_update' || args.first == 'upgrade')) {
      return;
    }

    final cache = readCache();
    if (cache == null) return;

    try {
      final current = Version.parse(packageVersion);
      final latest = Version.parse(cache.latestVersion);

      if (latest > current) {
        _printUpdateNotification(packageVersion, cache.latestVersion, logger);
      }
    } catch (_) {}
  }

  static void _printUpdateNotification(
    String current,
    String latest,
    Logger logger,
  ) {
    final title = 'A new version of zuq_cli is available!'.padRight(48);
    final versions = 'Current: $current → Latest: $latest'.padRight(48);
    final command = 'Run `zuq upgrade` to update.'.padRight(48);

    logger.info('');
    logger.info(
      lightYellow.wrap(
        '┌──────────────────────────────────────────────────────┐',
      )!,
    );
    logger.info(
      '${lightYellow.wrap('│')!}  ${lightCyan.wrap(title)}    ${lightYellow.wrap('│')!}',
    );
    logger.info(
      '${lightYellow.wrap('│')!}  $versions    ${lightYellow.wrap('│')!}',
    );
    logger.info(
      '${lightYellow.wrap('│')!}    ${lightGreen.wrap(command)}  ${lightYellow.wrap('│')!}',
    );
    logger.info(
      lightYellow.wrap(
        '└──────────────────────────────────────────────────────┘',
      )!,
    );
    logger.info('');
  }
}
