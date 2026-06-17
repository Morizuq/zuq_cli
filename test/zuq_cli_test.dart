import 'package:test/test.dart';
import 'package:zuq_cli/core/config/project_config.dart';
import 'package:zuq_cli/core/utils/dependency_resolver.dart';

void main() {
  group('DependencyResolver', () {
    late DependencyResolver resolver;

    setUp(() {
      resolver = DependencyResolver();
    });

    test('should resolve linear dependencies correctly', () {
      // a -> b -> c
      resolver.addNode('a', ['b']);
      resolver.addNode('b', ['c']);
      resolver.addNode('c', []);

      final result = resolver.resolve(['a'], []);
      expect(result, equals(['c', 'b', 'a']));
    });

    test('should resolve complex multi-level/branched dependencies', () {
      // a depends on b and c
      // b depends on d
      // c depends on d
      // d depends on nothing
      resolver.addNode('a', ['b', 'c']);
      resolver.addNode('b', ['d']);
      resolver.addNode('c', ['d']);
      resolver.addNode('d', []);

      final result = resolver.resolve(['a'], []);
      
      // 'd' must be before 'b' and 'c'; 'b' and 'c' must be before 'a'
      expect(result.indexOf('d'), lessThan(result.indexOf('b')));
      expect(result.indexOf('d'), lessThan(result.indexOf('c')));
      expect(result.indexOf('b'), lessThan(result.indexOf('a')));
      expect(result.indexOf('c'), lessThan(result.indexOf('a')));
      expect(result.last, equals('a'));
    });

    test('should filter out already installed dependencies', () {
      // a -> b -> c
      resolver.addNode('a', ['b']);
      resolver.addNode('b', ['c']);
      resolver.addNode('c', []);

      // If 'c' is already installed, only 'b' and 'a' should be resolved
      final result = resolver.resolve(['a'], ['c']);
      expect(result, equals(['b', 'a']));
    });

    test('should throw CircularDependencyException on self circular dependency', () {
      // a -> a
      resolver.addNode('a', ['a']);

      expect(
        () => resolver.resolve(['a'], []),
        throwsA(isA<CircularDependencyException>()),
      );
    });

    test('should throw CircularDependencyException on multi-node cycle', () {
      // a -> b -> c -> a
      resolver.addNode('a', ['b']);
      resolver.addNode('b', ['c']);
      resolver.addNode('c', ['a']);

      expect(
        () => resolver.resolve(['a'], []),
        throwsA(isA<CircularDependencyException>()),
      );
    });
  });

  group('ProjectConfig', () {
    test('should parse from valid map with all properties', () {
      final map = {
        'name': 'my_app',
        'state_management': 'riverpod',
        'router': 'go_router',
        'preset': 'fintech',
        'modules': ['networking', 'storage'],
      };

      final config = ProjectConfig.fromMap(map, defaultName: 'fallback');

      expect(config.projectName, equals('my_app'));
      expect(config.stateManagement, equals('riverpod'));
      expect(config.router, equals('go_router'));
      expect(config.preset, equals('fintech'));
      expect(config.modules, equals(['networking', 'storage']));
    });

    test('should use default values when map properties are missing', () {
      final map = <String, dynamic>{};

      final config = ProjectConfig.fromMap(map, defaultName: 'fallback_name');

      expect(config.projectName, equals('fallback_name'));
      expect(config.stateManagement, equals('none'));
      expect(config.router, equals('go_router'));
      expect(config.preset, equals('default'));
      expect(config.modules, isEmpty);
    });
  });
}
