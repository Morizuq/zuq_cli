import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:zuq_cli/core/config/project_name_resolver.dart';

void main() {
  group('ProjectNameResolver', () {
    const resolver = ProjectNameResolver();
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('zuq_name_test_');
    });

    tearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    group('sanitize', () {
      test('keeps valid snake_case names unchanged', () {
        expect(resolver.sanitize('my_app'), equals('my_app'));
        expect(resolver.sanitize('banking_core_v2'), equals('banking_core_v2'));
      });

      test('lowercases and replaces hyphens and spaces with underscores', () {
        expect(resolver.sanitize('My-Super-App'), equals('my_super_app'));
        expect(resolver.sanitize('Fintech Dashboard'), equals('fintech_dashboard'));
      });

      test('strips non-alphanumeric characters and collapses underscores', () {
        expect(resolver.sanitize('foo###bar___baz!'), equals('foo_bar_baz'));
      });

      test('removes leading numbers and leading/trailing underscores', () {
        expect(resolver.sanitize('123my_app'), equals('my_app'));
        expect(resolver.sanitize('___app___'), equals('app'));
      });

      test('falls back to "app" for reserved Dart language keywords', () {
        expect(resolver.sanitize('default'), equals('app'));
        expect(resolver.sanitize('class'), equals('app'));
        expect(resolver.sanitize('switch'), equals('app'));
      });

      test('falls back to "app" for invalid or empty input', () {
        expect(resolver.sanitize('.'), equals('app'));
        expect(resolver.sanitize('   '), equals('app'));
        expect(resolver.sanitize('12345'), equals('app'));
      });
    });

    group('resolve', () {
      test('respects explicit override name regardless of directory', () {
        final result = resolver.resolve(
          rawTarget: '.',
          overrideName: 'custom_branded_app',
          currentDirectory: tempDir,
        );
        expect(result, equals('custom_branded_app'));
      });

      test('resolves from existing pubspec.yaml when target is current directory', () {
        final pubspec = File(p.join(tempDir.path, 'pubspec.yaml'));
        pubspec.writeAsStringSync('name: existing_pubspec_name\n');

        final result = resolver.resolve(
          rawTarget: '.',
          currentDirectory: tempDir,
        );
        expect(result, equals('existing_pubspec_name'));
      });

      test('resolves from existing zuq.yaml when target is current directory', () {
        final zuqYaml = File(p.join(tempDir.path, 'zuq.yaml'));
        zuqYaml.writeAsStringSync('name: existing_zuq_name\n');

        final result = resolver.resolve(
          rawTarget: '.',
          currentDirectory: tempDir,
        );
        expect(result, equals('existing_zuq_name'));
      });

      test('falls back to sanitized directory name when target is . and no files exist', () {
        // Create a custom named directory
        final namedDir = Directory(p.join(tempDir.path, 'My-Finance_Project'));
        namedDir.createSync();

        final result = resolver.resolve(
          rawTarget: '.',
          currentDirectory: namedDir,
        );
        expect(result, equals('my_finance_project'));
      });

      test('sanitizes subfolder target when not targeting current directory', () {
        final result = resolver.resolve(
          rawTarget: 'My-ECommerce-App',
          currentDirectory: tempDir,
        );
        expect(result, equals('my_ecommerce_app'));
      });
    });
  });
}
