import 'package:pub_semver/pub_semver.dart';
import 'package:test/test.dart';
import 'package:zuq_cli/core/utils/update_checker.dart';

void main() {
  group('UpdateCache', () {
    test('should serialize and deserialize JSON correctly', () {
      final lastChecked = DateTime.now().toUtc();
      final cache = UpdateCache(
        lastChecked: lastChecked,
        latestVersion: '1.2.3',
      );

      final json = cache.toJson();
      expect(json['latest_version'], equals('1.2.3'));
      expect(json['last_checked'], equals(lastChecked.toIso8601String()));

      final decoded = UpdateCache.fromJson(json);
      expect(decoded.latestVersion, equals('1.2.3'));
      // Compare ISO strings or timestamps to avoid millisecond/timezone differences
      expect(
        decoded.lastChecked.toUtc().toIso8601String(),
        equals(lastChecked.toIso8601String()),
      );
    });
  });

  group('Version comparison logic', () {
    test('should correctly identify newer version', () {
      final current = Version.parse('1.0.4');
      final latest = Version.parse('1.0.5');
      expect(latest > current, isTrue);
    });

    test('should correctly identify older/equal version', () {
      final current = Version.parse('1.0.4');
      expect(Version.parse('1.0.4') > current, isFalse);
      expect(Version.parse('1.0.3') > current, isFalse);
    });

    test('should handle pre-release version comparison correctly', () {
      final current = Version.parse('1.0.4-dev.1');
      final latest = Version.parse('1.0.4');
      expect(latest > current, isTrue);
    });
  });
}
