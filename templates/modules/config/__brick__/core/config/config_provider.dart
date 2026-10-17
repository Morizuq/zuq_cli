import 'app_config.dart';
{{#isRiverpod}}
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Riverpod provider delivering the application's runtime [AppConfig].
final configProvider = Provider<AppConfig>((ref) {
  return AppConfig.fromEnvironment();
});
{{/isRiverpod}}{{#isBloc}}
import 'package:flutter_bloc/flutter_bloc.dart';

/// Cubit managing and providing the application's runtime [AppConfig].
class ConfigCubit extends Cubit<AppConfig> {
  ConfigCubit([AppConfig? initialConfig])
      : super(initialConfig ?? AppConfig.fromEnvironment());

  /// Updates the active configuration.
  void updateConfig(AppConfig newConfig) {
    emit(newConfig);
  }
}
{{/isBloc}}{{#isProvider}}
import 'package:flutter/foundation.dart';

/// ChangeNotifier providing the application's runtime [AppConfig].
class ConfigNotifier extends ChangeNotifier {
  AppConfig _config;

  ConfigNotifier([AppConfig? initialConfig])
      : _config = initialConfig ?? AppConfig.fromEnvironment();

  /// Current active configuration.
  AppConfig get config => _config;

  /// Updates the active configuration and notifies listeners.
  void updateConfig(AppConfig newConfig) {
    if (_config != newConfig) {
      _config = newConfig;
      notifyListeners();
    }
  }
}
{{/isProvider}}{{#isNone}}
/// Static access holder for [AppConfig] when no state management library is configured.
class ConfigHolder {
  ConfigHolder._();

  static final AppConfig current = AppConfig.fromEnvironment();
}
{{/isNone}}
