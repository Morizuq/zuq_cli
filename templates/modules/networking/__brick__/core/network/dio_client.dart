import 'package:dio/dio.dart';
import '../storage/secure_storage_service.dart';
import 'network_constants.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
{{#isRiverpod}}
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dioProvider = Provider<Dio>((ref) {
  final secureStorage = ref.watch(secureStorageServiceProvider);
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
  final SecureStorageService secureStorage;

  const NetworkService({
    required this.dio,
    required this.secureStorage,
  });

  factory NetworkService.create(SecureStorageService secureStorage) {
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
