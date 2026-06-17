import 'package:zuq_cli/core/module/base/project_context.dart';

abstract class Module {
  String get id;
  List<String> get dependencies;

  Future<void> install(ProjectContext context);
}
