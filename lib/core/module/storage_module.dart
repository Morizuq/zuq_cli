import 'dart:io';

import 'package:mason/mason.dart';
import 'package:zuq_cli/core/module/base/module.dart';
import 'package:zuq_cli/core/module/base/project_context.dart';
import 'package:path/path.dart' as p;
import 'package:zuq_cli/core/utils/templates_locator.dart';

class StorageModule implements Module {
  @override
  String get id => 'storage';

  @override
  List<String> get dependencies => [];

  @override
  Future<void> install(ProjectContext context) async {
    // Add shared_preferences and flutter_secure_storage
    context.corePackages.addAll(['shared_preferences', 'flutter_secure_storage']);

    final isRiverpod = context.stateManagement == 'riverpod';

    final templatesPath = TemplatesLocator.getTemplatesPath();
    final brickPath = p.join(
      templatesPath,
      'modules',
      'storage',
    );
    final brick = Brick.path(brickPath);
    final generator = await MasonGenerator.fromBrick(brick);

    final variables = <String, dynamic>{
      'isRiverpod': isRiverpod,
    };

    final target = DirectoryGeneratorTarget(Directory(context.libPath));
    await generator.generate(target, vars: variables, logger: Logger());
  }
}
