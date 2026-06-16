import 'dart:io';
import 'package:mason/mason.dart';
import 'package:path/path.dart' as p;

class TemplateGenerator {
  const TemplateGenerator();

  Future<void> generateFeature({
    required String targetDirectory,
    required String featureName,
  }) async {
    // Locate the local brick path
    final brickPath = p.join(Directory.current.path, 'templates', 'feature');
    final brick = Brick.path(brickPath);

    // Initialize the Mason generator from the brick
    final generator = await MasonGenerator.fromBrick(brick);

    // Define the variable map to interpolate the Mustache tags
    final variables = <String, dynamic>{'name': featureName};

    // Set the target generation directory and execute
    final target = DirectoryGeneratorTarget(Directory(targetDirectory));

    print('Generating feature $featureName template via Mason');

    await generator.generate(target, vars: variables, logger: Logger());

    print('Generated feature $featureName template successfully');
  }

  Future<void> generateProjectCore({
    required String projectPath,
    required String projectName,
    required bool isRiverpod,
    required bool isBloc,
    required bool isProvider,
    required bool isNone,
    required bool isGoRouter,
    required bool isAutoRoute,
  }) async {
    final brikPath = p.join(
      Directory.current.path,
      'templates',
      'project_scaffold',
    );
    final brick = Brick.path(brikPath);
    final generator = await MasonGenerator.fromBrick(brick);
    final variables = <String, dynamic>{
      'name': projectName,
      'isRiverpod': isRiverpod,
      'isBloc': isBloc,
      'isProvider': isProvider,
      'isNone': isNone,
      'isGoRouter': isGoRouter,
      'isAutoRoute': isAutoRoute,
    };

    final target = DirectoryGeneratorTarget(Directory(projectPath));

    print('Generating project core $projectName template via Mason');

    await generator.generate(target, vars: variables, logger: Logger());

    print('Generated project core $projectName template successfully');
  }
}
