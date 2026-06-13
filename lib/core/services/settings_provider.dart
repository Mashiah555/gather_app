import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// === SharedPreferences Provider =====================================
final sharedPrefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Prefs not initialized');
});
// --------------------------------------------------------------------

// === Theme Provider =================================================
final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(() {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final prefs = ref.watch(sharedPrefsProvider);
    final themeIndex = prefs.getInt('themeMode') ?? ThemeMode.system.index;
    return ThemeMode.values[themeIndex];
  }

  void setTheme(ThemeMode mode) {
    state = mode;
    ref.read(sharedPrefsProvider).setInt('themeMode', mode.index);
  }
}
// --------------------------------------------------------------------

// === Locale (Language) Provider =====================================
final localeProvider = NotifierProvider<LocaleNotifier, Locale>(() {
  return LocaleNotifier();
});

class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    final prefs = ref.watch(sharedPrefsProvider);
    final langCode =
        prefs.getString('languageCode') ?? 'he'; // Default to Hebrew
    return Locale(langCode);
  }

  void setLocale(Locale locale) {
    state = locale;
    ref
        .read(sharedPrefsProvider)
        .setString('languageCode', locale.languageCode);
  }
}
// --------------------------------------------------------------------

// === App Color Provider =============================================
final appColorProvider = NotifierProvider<AppColorNotifier, Color>(() {
  return AppColorNotifier();
});

class AppColorNotifier extends Notifier<Color> {
  // Default app color
  final _defaultAppColor = Colors.deepPurple;

  @override
  Color build() {
    // The initial color state
    return _defaultAppColor;
  }

  // Explicit method to update the state
  void setColor(Color newColor) {
    state = newColor;
  }

  // Explicit method to reset the state to the default
  void resetColor() {
    state = _defaultAppColor;
  }
}
// --------------------------------------------------------------------