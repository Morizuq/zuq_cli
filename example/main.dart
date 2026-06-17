import 'package:zuq_cli/zuq_cli.dart';

void main(List<String> arguments) async {
  // Instantiate the Zuq CLI command runner
  final cli = ZuqCli();

  // Run the CLI programmatically (e.g., passing arguments like '--help')
  final exitCode = await cli.run(arguments.isEmpty ? ['--help'] : arguments);

  print('Zuq CLI finished execution with exit code: $exitCode');
}
