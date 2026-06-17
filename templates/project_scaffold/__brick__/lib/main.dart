import 'package:flutter/material.dart';
{{#isRiverpod}}import 'package:flutter_riverpod/flutter_riverpod.dart';{{/isRiverpod}}
{{#isBloc}}import 'package:flutter_bloc/flutter_bloc.dart';{{/isBloc}}
{{#isProvider}}import 'package:provider/provider.dart';{{/isProvider}}
import 'core/router/router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_mode_notifier.dart';

void main() {
  runApp(
    {{#isRiverpod}}const ProviderScope(child: MyApp()){{/isRiverpod}}
    {{#isBloc}}BlocProvider(create: (_) => ThemeCubit(), child: const MyApp()){{/isBloc}}
    {{#isProvider}}MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ){{/isProvider}}
    {{#isNone}}const MyApp(){{/isNone}}
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    {{#isRiverpod}}
    return Consumer(
      builder: (context, ref, child) {
        final themeMode = ref.watch(themeModeProvider);
        {{#isAutoRoute}}
        final appRouter = AppRouter();
        {{/isAutoRoute}}
        return MaterialApp.router(
          title: '{{name.titleCase()}}',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          {{#isGoRouter}}routerConfig: router,{{/isGoRouter}}
          {{#isAutoRoute}}routerConfig: appRouter.config(),{{/isAutoRoute}}
        );
      },
    );
    {{/isRiverpod}}
    {{#isBloc}}
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        {{#isAutoRoute}}
        final appRouter = AppRouter();
        {{/isAutoRoute}}
        return MaterialApp.router(
          title: '{{name.titleCase()}}',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          {{#isGoRouter}}routerConfig: router,{{/isGoRouter}}
          {{#isAutoRoute}}routerConfig: appRouter.config(),{{/isAutoRoute}}
        );
      },
    );
    {{/isBloc}}
    {{#isProvider}}
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        {{#isAutoRoute}}
        final appRouter = AppRouter();
        {{/isAutoRoute}}
        return MaterialApp.router(
          title: '{{name.titleCase()}}',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          {{#isGoRouter}}routerConfig: router,{{/isGoRouter}}
          {{#isAutoRoute}}routerConfig: appRouter.config(),{{/isAutoRoute}}
        );
      },
    );
    {{/isProvider}}
    {{#isNone}}
    return ListenableBuilder(
      listenable: themeNotifier,
      builder: (context, child) {
        {{#isAutoRoute}}
        final appRouter = AppRouter();
        {{/isAutoRoute}}
        return MaterialApp.router(
          title: '{{name.titleCase()}}',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeNotifier.themeMode,
          {{#isGoRouter}}routerConfig: router,{{/isGoRouter}}
          {{#isAutoRoute}}routerConfig: appRouter.config(),{{/isAutoRoute}}
        );
      },
    );
    {{/isNone}}
  }
}
