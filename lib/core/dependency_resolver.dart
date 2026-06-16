class DependencyResolver {
  const DependencyResolver();

  List<String> resolveCorePackages({
    required String stateManagement,
    required String router,
  }) {
    final packages = <String>['dio'];

    switch (stateManagement) {
      case 'riverpod':
        packages.add('flutter_riverpod');
        break;
      case 'bloc':
        packages.add('flutter_bloc');
        break;
      case 'provider':
        packages.add('provider');
        break;
    }

    switch (router) {
      case 'go_router':
        packages.add('go_router');
        break;
      case 'auto_route':
        packages.add('auto_route');
        break;
    }

    return packages;
  }

  List<String> resolveDevPackages({
    required String router,
  }) {
    final devPackages = <String>[];

    if (router == 'auto_route') {
      devPackages.addAll(['auto_route_generator', 'build_runner']);
    }

    return devPackages;
  }
}
