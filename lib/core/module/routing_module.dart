import 'dart:io';

import 'package:mason/mason.dart';
import 'package:zuq_cli/core/module/base/module.dart';
import 'package:zuq_cli/core/module/base/project_context.dart';
import 'package:path/path.dart' as p;

class RoutingModule implements Module {
  @override
  String get id => 'routing';

  @override
  Future<void> install(ProjectContext context) async {
    final isGoRouter = context.router == 'go_router';
    final isAutoRoute = context.router == 'auto_route';

    if (isGoRouter) {
      context.corePackages.add('go_router');
    } else if (isAutoRoute) {
      context.corePackages.add('auto_route');
      context.devPackages.addAll(['auto_route_generator', 'build_runner']);
    }

    final brickPath = p.join(
      Directory.current.path,
      'templates',
      'modules',
      'routing',
    );
    final brick = Brick.path(brickPath);
    final generator = await MasonGenerator.fromBrick(brick);

    final variables = <String, dynamic>{
      'name': context.projectName,
      'isGoRouter': isGoRouter,
      'isAutoRoute': isAutoRoute,
    };

    final target = DirectoryGeneratorTarget(Directory(context.libPath));
    await generator.generate(target, vars: variables, logger: Logger());
  }
}
