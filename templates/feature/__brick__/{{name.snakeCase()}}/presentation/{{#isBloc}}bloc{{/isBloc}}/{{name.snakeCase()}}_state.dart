part of '{{name.snakeCase()}}_bloc.dart';

class {{name.pascalCase()}}State extends Equatable {
  final int counter;

  const {{name.pascalCase()}}State({required this.counter});

  factory {{name.pascalCase()}}State.initial() {
    return const {{name.pascalCase()}}State(counter: 0);
  }

  {{name.pascalCase()}}State copyWith({int? counter}) {
    return {{name.pascalCase()}}State(
      counter: counter ?? this.counter,
    );
  }

  @override
  List<Object?> get props => [counter];
}
