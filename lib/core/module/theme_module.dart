import 'dart:io';

import 'package:mason/mason.dart';
import 'package:zuq_cli/core/module/base/module.dart';
import 'package:zuq_cli/core/module/base/project_context.dart';
import 'package:path/path.dart' as p;
import 'package:zuq_cli/core/utils/templates_locator.dart';

class ThemeModule implements Module {
  @override
  String get id => 'theme';

  @override
  Future<void> install(ProjectContext context) async {
    final templatesPath = TemplatesLocator.getTemplatesPath();
    final brickPath = p.join(
      templatesPath,
      'modules',
      'theme',
    );
    final brick = Brick.path(brickPath);
    final generator = await MasonGenerator.fromBrick(brick);

    final variables = <String, dynamic>{
      'isRiverpod': context.stateManagement == 'riverpod',
      'isBloc': context.stateManagement == 'bloc',
      'isProvider': context.stateManagement == 'provider',
      'isNone': context.stateManagement == 'none',
    };

    final target = DirectoryGeneratorTarget(Directory(context.libPath));
    await generator.generate(target, vars: variables, logger: Logger());
  }
}
