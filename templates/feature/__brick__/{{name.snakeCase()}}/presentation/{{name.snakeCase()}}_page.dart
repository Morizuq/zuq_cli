import 'package:flutter/material.dart';
{{#isRiverpod}}import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'controllers/{{name.snakeCase()}}_controller.dart';

class {{name.pascalCase()}}Page extends ConsumerWidget {
  const {{name.pascalCase()}}Page({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch({{name.camelCase()}}ControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('{{name.titleCase()}}'),
      ),
      body: Center(
        child: Text('{{name.titleCase()}} State: $state'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ref.read({{name.camelCase()}}ControllerProvider.notifier).increment(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
{{/isRiverpod}}{{#isBloc}}import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/{{name.snakeCase()}}_bloc.dart';

class {{name.pascalCase()}}Page extends StatelessWidget {
  const {{name.pascalCase()}}Page({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => {{name.pascalCase()}}Bloc(),
      child: const {{name.pascalCase()}}PageView(),
    );
  }
}

class {{name.pascalCase()}}PageView extends StatelessWidget {
  const {{name.pascalCase()}}PageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('{{name.titleCase()}}'),
      ),
      body: BlocBuilder<{{name.pascalCase()}}Bloc, {{name.pascalCase()}}State>(
        builder: (context, state) {
          return Center(
            child: Text('{{name.titleCase()}} Counter: ${state.counter}'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.read<{{name.pascalCase()}}Bloc>().add(const IncrementEvent()),
        child: const Icon(Icons.add),
      ),
    );
  }
}
{{/isBloc}}{{#isProvider}}import 'package:provider/provider.dart';
import 'providers/{{name.snakeCase()}}_notifier.dart';

class {{name.pascalCase()}}Page extends StatelessWidget {
  const {{name.pascalCase()}}Page({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => {{name.pascalCase()}}Notifier(),
      child: Consumer<{{name.pascalCase()}}Notifier>(
        builder: (context, notifier, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('{{name.titleCase()}}'),
            ),
            body: Center(
              child: Text('{{name.titleCase()}} Counter: ${notifier.counter}'),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: notifier.increment,
              child: const Icon(Icons.add),
            ),
          );
        },
      ),
    );
  }
}
{{/isProvider}}{{#isNone}}class {{name.pascalCase()}}Page extends StatefulWidget {
  const {{name.pascalCase()}}Page({super.key});

  @override
  State<{{name.pascalCase()}}Page> createState() => _{{name.pascalCase()}}PageState();
}

class _{{name.pascalCase()}}PageState extends State<{{name.pascalCase()}}Page> {
  int _counter = 0;

  void _increment() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('{{name.titleCase()}}'),
      ),
      body: Center(
        child: Text('{{name.titleCase()}} Counter: $_counter'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _increment,
        child: const Icon(Icons.add),
      ),
    );
  }
}
{{/isNone}}
