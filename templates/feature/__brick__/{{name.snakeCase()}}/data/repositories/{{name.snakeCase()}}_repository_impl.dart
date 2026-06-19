import '../../domain/repositories/{{name.snakeCase()}}_repository.dart';
import '../models/{{name.snakeCase()}}_model.dart';

class {{name.pascalCase()}}RepositoryImpl implements {{name.pascalCase()}}Repository {
  const {{name.pascalCase()}}RepositoryImpl();

  @override
  Future<{{name.pascalCase()}}Model> get{{name.pascalCase()}}() async {
    return const {{name.pascalCase()}}Model();
  }
}
