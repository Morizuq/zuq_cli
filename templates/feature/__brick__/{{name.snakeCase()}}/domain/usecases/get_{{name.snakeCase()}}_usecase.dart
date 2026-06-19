import '../entities/{{name.snakeCase()}}.dart';
import '../repositories/{{name.snakeCase()}}_repository.dart';

class Get{{name.pascalCase()}}UseCase {
  final {{name.pascalCase()}}Repository repository;

  const Get{{name.pascalCase()}}UseCase(this.repository);

  Future<{{name.pascalCase()}}> execute() {
    return repository.get{{name.pascalCase()}}();
  }
}
