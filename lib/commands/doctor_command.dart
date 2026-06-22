import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as p;
import 'package:zuq_cli/core/config/config_parser.dart';

class DoctorViolation {
  final String filePath;
  final int lineNumber;
  final String sourceLayer;
  final String targetLayer;
  final String importUri;
  final String description;

  DoctorViolation({
    required this.filePath,
    required this.lineNumber,
    required this.sourceLayer,
    required this.targetLayer,
    required this.importUri,
    required this.description,
  });
}

class DoctorCommand extends Command<int> {
  final ConfigParser _configParser;
  final Logger _logger;

  @override
  final String name = 'doctor';

  @override
  final String description =
      'Perform audits on the codebase, enforcing clean-architecture boundaries.';

  DoctorCommand({
    ConfigParser configParser = const ConfigParser(),
    Logger? logger,
  }) : _configParser = configParser,
       _logger = logger ?? Logger();

  @override
  Future<int> run() async {
    final projectConfig = _configParser.readConfig(fallbackProjectName: '');
    if (projectConfig == null) {
      _logger.err('Error: No zuq.yaml configuration found in this directory.');
      _logger.err('Make sure you are at the root of a zuq project.');
      return 1;
    }

    final projectName = projectConfig.projectName;
    final projectPath = Directory.current.path;
    final libPath = p.join(projectPath, 'lib');
    final featuresPath = p.join(projectPath, projectConfig.featuresPath);

    if (!Directory(featuresPath).existsSync()) {
      _logger.info(
        'No features directory found under ${projectConfig.featuresPath}. Architecture is clean.',
      );
      return 0;
    }

    _logger.info(
      'Auditing project architectural boundaries for ${lightCyan.wrap(projectName)}...',
    );

    final List<DoctorViolation> violations = [];
    final dartFiles = _findDartFiles(Directory(featuresPath));

    for (final file in dartFiles) {
      final sourceLayer = _getLayerOfPath(file.path, featuresPath);
      if (sourceLayer == null) continue;

      final fileViolations = _auditFile(
        file: file,
        sourceLayer: sourceLayer,
        projectName: projectName,
        libPath: libPath,
        featuresPath: featuresPath,
      );
      violations.addAll(fileViolations);
    }

    if (violations.isEmpty) {
      _logger.success('\n✓ Architecture audit completed: 0 violations found.');
      return 0;
    }

    _logger.err(
      '\n✗ Architecture audit failed: ${violations.length} violations found:\n',
    );

    for (final violation in violations) {
      final relativePath = p.relative(violation.filePath, from: projectPath);
      _logger.info(
        '  ${red.wrap('Violation')} in ${lightCyan.wrap('$relativePath:${violation.lineNumber}')}\n'
        '    Layer: ${yellow.wrap(violation.sourceLayer)} → Target Layer: ${yellow.wrap(violation.targetLayer)}\n'
        '    Import: ${red.wrap(violation.importUri)}\n'
        '    Reason: ${violation.description}\n',
      );
    }

    return 1;
  }

  List<File> _findDartFiles(Directory directory) {
    final List<File> files = [];
    try {
      final entities = directory.listSync(recursive: true);
      for (final entity in entities) {
        if (entity is File && entity.path.endsWith('.dart')) {
          files.add(entity);
        }
      }
    } catch (_) {}
    return files;
  }

  String? _getLayerOfPath(String filePath, String featuresPath) {
    final relative = p.relative(filePath, from: featuresPath);
    final parts = p.split(relative);
    if (parts.length >= 2) {
      final layer = parts[1];
      if (layer == 'domain' || layer == 'data' || layer == 'presentation') {
        return layer;
      }
    }
    return null;
  }

  List<DoctorViolation> _auditFile({
    required File file,
    required String sourceLayer,
    required String projectName,
    required String libPath,
    required String featuresPath,
  }) {
    final List<DoctorViolation> fileViolations = [];
    final lines = file.readAsLinesSync();
    final RegExp importRegExp = RegExp(r'''import\s+['"]([^'"]+)['"]''');

    bool inBlockComment = false;

    for (int i = 0; i < lines.length; i++) {
      var line = lines[i].trim();

      // Simple block comment tracking
      if (inBlockComment) {
        if (line.contains('*/')) {
          inBlockComment = false;
          // Process the rest of the line after */
          line = line.substring(line.indexOf('*/') + 2).trim();
        } else {
          continue;
        }
      }

      if (line.contains('/*')) {
        if (line.contains('*/')) {
          // Single-line block comment, strip it
          line = line.replaceAll(RegExp(r'/\*.*?\*/'), '').trim();
        } else {
          inBlockComment = true;
          line = line.substring(0, line.indexOf('/*')).trim();
        }
      }

      if (line.isEmpty || line.startsWith('//') || line.startsWith('///')) {
        continue;
      }

      final match = importRegExp.firstMatch(line);
      if (match != null) {
        final importUri = match.group(1)!;
        final targetPath = _resolveImportPath(
          importUri: importUri,
          sourceFilePath: file.path,
          projectName: projectName,
          libPath: libPath,
        );

        if (targetPath == null) continue;

        final targetLayer = _getLayerOfPath(targetPath, featuresPath);
        if (targetLayer == null) continue;

        final violationReason = _checkLayerViolation(sourceLayer, targetLayer);
        if (violationReason != null) {
          fileViolations.add(
            DoctorViolation(
              filePath: file.path,
              lineNumber: i + 1,
              sourceLayer: sourceLayer,
              targetLayer: targetLayer,
              importUri: importUri,
              description: violationReason,
            ),
          );
        }
      }
    }

    return fileViolations;
  }

  String? _resolveImportPath({
    required String importUri,
    required String sourceFilePath,
    required String projectName,
    required String libPath,
  }) {
    if (importUri.startsWith('dart:')) return null;
    if (importUri.startsWith('package:')) {
      final prefix = 'package:$projectName/';
      if (importUri.startsWith(prefix)) {
        final relativePart = importUri.substring(prefix.length);
        return p.canonicalize(p.join(libPath, relativePart));
      }
      return null;
    }
    // Relative import
    return p.canonicalize(p.join(p.dirname(sourceFilePath), importUri));
  }

  String? _checkLayerViolation(String source, String target) {
    if (source == 'domain' && (target == 'presentation' || target == 'data')) {
      return 'The Domain layer must be completely independent. It cannot import from presentation or data layers.';
    }
    if (source == 'presentation' && target == 'data') {
      return 'The Presentation layer should not depend directly on the Data layer (use domain/repositories instead).';
    }
    if (source == 'data' && target == 'presentation') {
      return 'The Data layer cannot depend on the Presentation layer.';
    }
    return null;
  }
}
