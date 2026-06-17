import 'package:path/path.dart' as p;

class ProjectContext {
  final String projectName;
  final String projectPath;
  final String stateManagement;
  final String router;

  final List<String> corePackages = [];
  final List<String> devPackages = [];

  ProjectContext({
    required this.projectName,
    required this.projectPath,
    required this.stateManagement,
    required this.router,
  });

  String get libPath => p.join(projectPath, 'lib');
}
