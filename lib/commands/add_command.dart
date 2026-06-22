import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:zuq_cli/commands/add_module_command.dart';
import 'package:zuq_cli/commands/add_feature_command.dart';

class AddCommand extends Command<int> {
  @override
  final String name = 'add';

  @override
  final String description = 'Add a module or a feature to the current project.';

  AddCommand({Logger? logger}) {
    addSubcommand(AddModuleCommand(logger: logger));
    addSubcommand(AddFeatureCommand(logger: logger));
  }
}
