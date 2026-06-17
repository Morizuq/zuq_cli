class ProjectConfig {
  final String projectName;
  final String stateManagement;
  final String router;
  final List<String> modules;

  ProjectConfig({
    required this.projectName,
    required this.stateManagement,
    required this.router,
    required this.modules,
  });

  factory ProjectConfig.fromMap(
    Map<String, dynamic> map, {
    required String defaultName,
  }) {
    final rawModules = map['modules'] as List<dynamic>? ?? [];
    return ProjectConfig(
      projectName: map['name'] as String? ?? defaultName,
      stateManagement: map['state_management'] as String? ?? 'none',
      router: map['router'] as String? ?? 'go_router',
      modules: rawModules.cast<String>(),
    );
  }
}
