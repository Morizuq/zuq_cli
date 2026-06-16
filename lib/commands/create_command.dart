import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:zuq_cli/generator/project_generator.dart';

class CreateCommand extends Command<int> {
  final ProjectGenerator _projectGenerator;
  CreateCommand({ProjectGenerator? projectGenerator})
    : _projectGenerator =
          projectGenerator ?? ProjectGenerator(logger: Logger()) {
    // Add state management choise option

    argParser.addOption(
      'state',
      abbr: 's',
      help: 'The state management solution to use',
      allowed: ['riverpod', 'bloc', 'provider', 'none'],
      defaultsTo: 'none',
    );

    argParser.addOption(
      'router',
      abbr: 'r',
      help: 'The routing solution to use',
      allowed: ['go_router', 'auto_route'],
      defaultsTo: 'go_router',
    );
  }

  @override
  String get description => 'Create a new flutter application skeleton';

  @override
  String get name => 'create';

  @override
  Future<int> run() async {
    if (argResults == null || argResults!.rest.isEmpty) {
      print('Error: Please specifiy project name');
      print('Usage: zuq create <project_name>');
      return 1;
    }

    final stateManagement = argResults?['state'] as String;
    final projectName = argResults!.rest.first;
    final router = argResults?['router'] as String;

    return await _projectGenerator.generate(
      projectName: projectName,
      stateManagement: stateManagement,
      router: router,
    );
  }
}
