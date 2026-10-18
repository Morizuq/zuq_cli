import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../storage/secure_storage_service.dart';
import 'network_constants.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
{{#isRiverpod}}
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/config_provider.dart';

/// Riverpod provider supplying the configured [Dio] HTTP client.
final dioProvider = Provider<Dio>((ref) {
  final secureStorage = ref.watch(secureStorageServiceProvider);
  final config = ref.watch(configProvider);
  return createDio(config: config, secureStorage: secureStorage);
});
{{/isRiverpod}}{{#isProvider}}
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../config/config_provider.dart';

/// Provider definition for [Dio] for registration inside `MultiProvider`.
SingleChildWidget createDioProvider() {
  return ProxyProvider2<ConfigNotifier, SecureStorageService, Dio>(
    update: (_, configNotifier, secureStorage, __) => createDio(
      config: configNotifier.config,
      secureStorage: secureStorage,
    ),
  );
}
{{/isProvider}}{{#isBloc}}
import 'package:flutter_bloc/flutter_bloc.dart';

/// RepositoryProvider supplying [Dio] across the widget tree for Bloc architectures.
RepositoryProvider<Dio> createDioRepositoryProvider({
  required AppConfig config,
  required SecureStorageService secureStorage,
}) {
  return RepositoryProvider<Dio>.value(
    value: createDio(config: config, secureStorage: secureStorage),
  );
}
{{/isBloc}}{{#isNone}}
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/config_provider.dart';

/// Standalone [Dio] instance for projects without third-party state management.
final Dio dioClient = createDio(
  config: ConfigHolder.current,
  secureStorage: const SecureStorageServiceImpl(FlutterSecureStorage()),
);
{{/isNone}}

/// Core factory that builds and configures a production-ready [Dio] HTTP client.
Dio createDio({
  required AppConfig config,
  required SecureStorageService secureStorage,
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: config.apiBaseUrl,
      connectTimeout: NetworkConstants.connectTimeout,
      receiveTimeout: NetworkConstants.receiveTimeout,
      sendTimeout: NetworkConstants.sendTimeout,
    ),
  );

  dio.interceptors.add(
    AuthInterceptor(
      secureStorage: secureStorage,
      baseUrl: config.apiBaseUrl,
    ),
  );

  if (config.enableLogging) {
    dio.interceptors.add(AppLoggingInterceptor());
  }

  return dio;
}
