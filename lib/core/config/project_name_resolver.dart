import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

/// Resolves and sanitizes Dart package names according to Flutter/Dart package conventions.
class ProjectNameResolver {
  const ProjectNameResolver();

  /// Reserved Dart language keywords that cannot be used as package names.
  static const Set<String> reservedKeywords = {
    'assert',
    'break',
    'case',
    'catch',
    'class',
    'const',
    'continue',
    'default',
    'do',
    'else',
    'enum',
    'extends',
    'false',
    'final',
    'finally',
    'for',
    'if',
    'in',
    'is',
    'new',
    'null',
    'rethrow',
    'return',
    'super',
    'switch',
    'this',
    'throw',
    'true',
    'try',
    'var',
    'void',
    'while',
    'with',
    'yield',
  };

  /// Resolves the intended package name for a target directory or argument.
  ///
  /// Resolution precedence:
  /// 1. Explicit [overrideName] passed via command-line flags.
  /// 2. Existing `zuq.yaml` in [targetDirectory].
  /// 3. Existing `pubspec.yaml` in [targetDirectory].
  /// 4. Directory basename if target is `.` or current working directory.
  /// 5. The [rawTarget] itself.
  String resolve({
    required String rawTarget,
    String? overrideName,
    Directory? currentDirectory,
  }) {
    if (overrideName != null && overrideName.trim().isNotEmpty) {
      return sanitize(overrideName);
    }

    final targetDir = currentDirectory ?? Directory.current;
    final isCurrentDirectory = rawTarget == '.' || rawTarget.trim().isEmpty;

    if (isCurrentDirectory) {
      // 1. Check existing zuq.yaml in current directory
      final zuqFile = File(p.join(targetDir.path, 'zuq.yaml'));
      if (zuqFile.existsSync()) {
        try {
          final yaml = loadYaml(zuqFile.readAsStringSync());
          if (yaml is Map && yaml['name'] is String && yaml['name'] != '.') {
            return sanitize(yaml['name'] as String);
          }
        } catch (_) {}
      }

      // 2. Check existing pubspec.yaml in current directory
      final pubspecFile = File(p.join(targetDir.path, 'pubspec.yaml'));
      if (pubspecFile.existsSync()) {
        try {
          final yaml = loadYaml(pubspecFile.readAsStringSync());
          if (yaml is Map && yaml['name'] is String && yaml['name'] != '.') {
            return sanitize(yaml['name'] as String);
          }
        } catch (_) {}
      }

      // 3. Fallback to current directory's folder name
      final folderName = p.basename(p.normalize(targetDir.absolute.path));
      return sanitize(folderName);
    }

    return sanitize(rawTarget);
  }

  /// Sanitizes an arbitrary string into a valid, lowercase Dart package name.
  ///
  /// Ensures:
  /// - Only lowercase ASCII letters, numbers, and underscores.
  /// - Does not start with a number.
  /// - Collapses consecutive underscores and trims leading/trailing underscores.
  /// - Avoids reserved Dart language keywords.
  /// - Falls back to `'app'` if the result is empty or invalid.
  String sanitize(String name) {
    var result = name
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[^a-z0-9_]'), '_')
        .replaceAll(RegExp(r'_+'), '_');

    // Remove leading numbers and leading underscores
    result = result.replaceFirst(RegExp(r'^[^a-z]+'), '');

    // Remove trailing underscores
    result = result.replaceFirst(RegExp(r'_+$'), '');

    if (result.isEmpty || reservedKeywords.contains(result)) {
      return 'app';
    }

    return result;
  }
}
