class ProjectConfig {
  final String projectName;
  final String stateManagement;
  final String router;

  ProjectConfig({
    required this.projectName,
    required this.stateManagement,
    required this.router,
  });

  factory ProjectConfig.fromMap(
    Map<String, dynamic> map, {
    required String defaultName,
  }) {
    return ProjectConfig(
      projectName: map['name'] as String? ?? defaultName,
      stateManagement: map['state_management'] as String? ?? 'none',
      router: map['router'] as String? ?? 'go_router',
    );
  }
}
