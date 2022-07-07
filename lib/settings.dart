import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  static const _botToken = "botToken";
  static const _number = "number";
  static const _heartbeat = "heartbeat";

  static late SharedPreferences _sharedPref;

  static Future<void> load() async {
    _sharedPref = await SharedPreferences.getInstance();
  }

  static String? getBotToken() {
    return _sharedPref.getString(_botToken);
  }

  static Future<void> setBotToken(String value) async {
    await _sharedPref.setString(_botToken, value);
  }

  static int? getNumber() {
    var value = _sharedPref.getInt(_number);
    if (value == null || value == 0) return null;
    return value;
  }

  static Future<void> setNumer(int number) async {
    await _sharedPref.setInt(_number, number);
  }

  static bool getSendheartbeat() {
    var value = _sharedPref.getBool(_heartbeat);
    return value ?? false;
  }

  static Future<void> setHeartbeat(bool value) async {
    await _sharedPref.setBool(_heartbeat, value);
  }
}
