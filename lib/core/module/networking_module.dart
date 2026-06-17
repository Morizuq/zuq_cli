import 'dart:io';

import 'package:mason/mason.dart';
import 'package:zuq_cli/core/module/base/module.dart';
import 'package:zuq_cli/core/module/base/project_context.dart';
import 'package:path/path.dart' as p;

class NetworkingModule implements Module {
  @override
  String get id => 'networking';

  @override
  Future<void> install(ProjectContext context) async {
    // - Request required packages
    context.corePackages.addAll(['dio', 'flutter_secure_storage', 'logger']);

    final isRiverpod = context.stateManagement == 'riverpod';

    final brickPath = p.join(
      Directory.current.path,
      'templates',
      'modules',
      'networking',
    );
    final brick = Brick.path(brickPath);
    final generator = await MasonGenerator.fromBrick(brick);

    final variables = <String, dynamic>{'isRiverpod': isRiverpod};

    final target = DirectoryGeneratorTarget(Directory(context.libPath));
    await generator.generate(target, vars: variables, logger: Logger());
  }
}
