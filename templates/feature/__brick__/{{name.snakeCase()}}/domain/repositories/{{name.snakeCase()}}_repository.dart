import '../entities/{{name.snakeCase()}}.dart';

abstract class {{name.pascalCase()}}Repository {
  Future<{{name.pascalCase()}}> get{{name.pascalCase()}}();
}
