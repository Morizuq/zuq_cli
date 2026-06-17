class NetworkConstants {
  NetworkConstants._();

  static const String baseUrl = 'https://api.example.com';

  static String get wsBaseUrl => baseUrl
      .replaceFirst('https://', 'wss://')
      .replaceFirst('http://', 'ws://');

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration sendTimeout = Duration(seconds: 15);
}
