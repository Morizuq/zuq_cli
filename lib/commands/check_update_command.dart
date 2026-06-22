import 'dart:convert';
import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:zuq_cli/core/utils/update_checker.dart';

class CheckUpdateCommand extends Command<int> {
  @override
  final String name = '_check_update';

  @override
  final String description = 'Internal command to check for updates in the background.';

  @override
  bool get hidden => true;

  @override
  Future<int> run() async {
    final latestVersion = await _fetchLatestVersion();
    if (latestVersion != null) {
      UpdateChecker.writeCache(
        UpdateCache(
          lastChecked: DateTime.now(),
          latestVersion: latestVersion,
        ),
      );
    }
    return 0;
  }

  Future<String?> _fetchLatestVersion() async {
    final client = HttpClient();
    try {
      final uri = Uri.parse('https://pub.dev/api/packages/zuq_cli');
      final request = await client.getUrl(uri).timeout(const Duration(seconds: 5));
      final response = await request.close().timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        final json = jsonDecode(body) as Map<String, dynamic>;
        final latest = json['latest'] as Map<String, dynamic>?;
        if (latest != null) {
          return latest['version'] as String?;
        }
      }
    } catch (_) {
      // Fail silently to not impact CLI usage
    } finally {
      client.close();
    }
    return null;
  }
}
