import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'network_constants.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
{{#isRiverpod}}
import 'package:flutter_riverpod/flutter_riverpod.dart';

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final dioProvider = Provider<Dio>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  final dio = Dio(
    BaseOptions(
      baseUrl: NetworkConstants.baseUrl,
      connectTimeout: NetworkConstants.connectTimeout,
      receiveTimeout: NetworkConstants.receiveTimeout,
      sendTimeout: NetworkConstants.sendTimeout,
    ),
  );
  dio.interceptors.addAll([
    AuthInterceptor(secureStorage),
    AppLoggingInterceptor(),
  ]);
  return dio;
});
{{/isRiverpod}}
{{^isRiverpod}}
class NetworkService {
  final Dio dio;
  final FlutterSecureStorage secureStorage;

  const NetworkService({
    required this.dio,
    required this.secureStorage,
  });

  factory NetworkService.create() {
    final secureStorage = const FlutterSecureStorage();
    final dio = Dio(
      BaseOptions(
        baseUrl: NetworkConstants.baseUrl,
        connectTimeout: NetworkConstants.connectTimeout,
        receiveTimeout: NetworkConstants.receiveTimeout,
        sendTimeout: NetworkConstants.sendTimeout,
      ),
    );
    dio.interceptors.addAll([
      AuthInterceptor(secureStorage),
      AppLoggingInterceptor(),
    ]);
    return NetworkService(
      dio: dio,
      secureStorage: secureStorage,
    );
  }
}
{{/isRiverpod}}
