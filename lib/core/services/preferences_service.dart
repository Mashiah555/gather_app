import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  late SharedPreferences _prefs;

  SharedPreferences get prefs => _prefs;

  PreferencesService._internal();
  static PreferencesService instance = PreferencesService._internal();

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<bool> setBool(String key, bool value) {
    return _prefs.setBool(key, value);
  }

  bool? getBool(String key) {
    return _prefs.getBool(key);
  }
}
