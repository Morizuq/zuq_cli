import 'dart:io';

import 'package:mason/mason.dart';
import 'package:zuq_cli/core/module/base/module.dart';
import 'package:zuq_cli/core/module/base/project_context.dart';
import 'package:path/path.dart' as p;
import 'package:zuq_cli/core/utils/templates_locator.dart';

class L10nModule implements Module {
  @override
  String get id => 'l10n';

  @override
  Future<void> install(ProjectContext context) async {
    // Add flutter_localizations from flutter SDK
    await Process.run(
      'flutter',
      ['pub', 'add', 'flutter_localizations', '--sdk=flutter'],
      workingDirectory: context.projectPath,
    );

    // Ensure 'generate: true' is set in pubspec.yaml under 'flutter:'
    // We target the flush-left 'flutter:' section by matching '\nflutter:'
    final pubspecFile = File(p.join(context.projectPath, 'pubspec.yaml'));
    if (pubspecFile.existsSync()) {
      var content = pubspecFile.readAsStringSync();
      if (!content.contains('generate: true')) {
        content = content.replaceFirst(
          '\nflutter:',
          '\nflutter:\n  generate: true',
        );
        pubspecFile.writeAsStringSync(content);
      }
    }

    final templatesPath = TemplatesLocator.getTemplatesPath();
    final brickPath = p.join(
      templatesPath,
      'modules',
      'l10n',
    );
    final brick = Brick.path(brickPath);
    final generator = await MasonGenerator.fromBrick(brick);

    // Target the root of the project to generate l10n.yaml at root and lib/ folder structure
    final target = DirectoryGeneratorTarget(Directory(context.projectPath));
    await generator.generate(target, vars: <String, dynamic>{}, logger: Logger());
  }
}
