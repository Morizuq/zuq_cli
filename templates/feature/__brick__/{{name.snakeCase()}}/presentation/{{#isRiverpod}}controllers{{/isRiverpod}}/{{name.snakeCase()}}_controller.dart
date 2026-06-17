import 'package:flutter_riverpod/flutter_riverpod.dart';

class {{name.pascalCase()}}Controller extends Notifier<int> {
  @override
  int build() => 0;

  void increment() => state = state + 1;
}

final {{name.camelCase()}}ControllerProvider = NotifierProvider<{{name.pascalCase()}}Controller, int>(
  {{name.pascalCase()}}Controller.new,
);
