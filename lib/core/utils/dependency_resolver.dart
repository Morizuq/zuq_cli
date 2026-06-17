class DependencyResolver {
  final Map<String, List<String>> _graph = {};

  void addNode(String id, List<String> dependencies) {
    _graph[id] = dependencies;
  }

  /// Resolves the topological install order for the [requestedIds],
  /// filtering out any modules that are already inside [installedIds].
  ///
  /// Throws [CircularDependencyException] if a cycle is found.
  List<String> resolve(List<String> requestedIds, List<String> installedIds) {
    final Set<String> visited = {};
    final List<String> resolved = [];
    final Set<String> recursionStack = {};

    void dfs(String node) {
      if (recursionStack.contains(node)) {
        throw CircularDependencyException(
          'Circular dependency detected involving module: $node',
        );
      }
      if (visited.contains(node)) return;

      recursionStack.add(node);

      final deps = _graph[node] ?? [];
      for (final dep in deps) {
        dfs(dep);
      }

      recursionStack.remove(node);
      visited.add(node);
      resolved.add(node);
    }

    for (final id in requestedIds) {
      dfs(id);
    }

    // Filter out already installed modules
    return resolved.where((id) => !installedIds.contains(id)).toList();
  }
}

class CircularDependencyException implements Exception {
  final String message;
  CircularDependencyException(this.message);

  @override
  String toString() => message;
}
