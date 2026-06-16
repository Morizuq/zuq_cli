import 'package:flutter/material.dart';
{{#isRiverpod}}import 'package:flutter_riverpod/flutter_riverpod.dart';{{/isRiverpod}}
{{#isProvider}}import 'package:provider/provider.dart';{{/isProvider}}import 'core/router/router.dart';

void main() {
  runApp(
    {{#isRiverpod}}const ProviderScope(child: MyApp()){{/isRiverpod}}{{#isBloc}}const MyApp(){{/isBloc}}{{#isProvider}}MultiProvider(providers: const [], child: const MyApp()){{/isProvider}}{{#isNone}}const MyApp(){{/isNone}}
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    {{#isAutoRoute}}
    final appRouter = AppRouter();
    {{/isAutoRoute}}

    return MaterialApp.router(
      title: '{{name.titleCase()}}',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      {{#isGoRouter}}routerConfig: router,{{/isGoRouter}}
      {{#isAutoRoute}}routerConfig: appRouter.config(),{{/isAutoRoute}}
    );
  }
}
