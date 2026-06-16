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
}
