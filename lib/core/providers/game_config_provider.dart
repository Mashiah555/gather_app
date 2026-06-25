import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gather_app/core/services/settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final gameConfigProvider = NotifierProvider<GameConfigNotifier, void>(() {
  return GameConfigNotifier();
});

class GameConfigNotifier extends Notifier<void> {
  late SharedPreferences _prefs;

  @override
  void build() {
    // Hooks into the SharedPreferences instance
    _prefs = ref.watch(sharedPrefsProvider);
  }

  /// Reads a config. If the user hasn't set it yet, it returns the GameItem's default.
  dynamic getConfig(String gameId, String configKey, dynamic defaultValue) {
    final fullKey = '${gameId}_$configKey';

    if (!_prefs.containsKey(fullKey)) return defaultValue;

    if (defaultValue is double) return _prefs.getDouble(fullKey);
    if (defaultValue is int) return _prefs.getInt(fullKey);
    if (defaultValue is String) return _prefs.getString(fullKey);
    if (defaultValue is bool) return _prefs.getBool(fullKey);

    return defaultValue;
  }

  /// Saves a config to local storage instantly.
  void setConfig(String gameId, String configKey, dynamic value) {
    final fullKey = '${gameId}_$configKey';

    if (value is double) {
      _prefs.setDouble(fullKey, value);
    } else if (value is int) {
      _prefs.setInt(fullKey, value);
    } else if (value is String) {
      _prefs.setString(fullKey, value);
    } else if (value is bool) {
      _prefs.setBool(fullKey, value);
    }
  }
}
