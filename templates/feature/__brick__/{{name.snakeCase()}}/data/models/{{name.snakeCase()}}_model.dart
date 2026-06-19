import '../../domain/entities/{{name.snakeCase()}}.dart';

class {{name.pascalCase()}}Model extends {{name.pascalCase()}} {
  const {{name.pascalCase()}}Model();

  factory {{name.pascalCase()}}Model.fromJson(Map<String, dynamic> json) {
    return const {{name.pascalCase()}}Model();
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{};
  }
}
