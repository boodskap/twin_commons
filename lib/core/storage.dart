import 'package:shared_preferences/shared_preferences.dart';

class Storage {
  static Future<bool> putString(String key, String value) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    var res = await sp.setString(key, value);
    return res;
  }

  static Future<bool> putInt(String key, int value) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return await sp.setInt(key, value);
  }

  static Future<bool> putBool(String key, bool value) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return await sp.setBool(key, value);
  }

  static Future<bool> putDouble(String key, double value) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return await sp.setDouble(key, value);
  }

  static Future<bool> putStringList(String key, List<String> value) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return await sp.setStringList(key, value);
  }

  static Future<bool> getBool(String key, bool def) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    var res = sp.getBool(key);
    return res ?? def;
  }

  static Future<String> getString(String key, String def) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    var res = sp.getString(key);
    return res ?? def;
  }

  static Future<int> getInt(String key, int def) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    var res = sp.getInt(key);
    return res ?? def;
  }

  static Future<double> getDouble(String key, double def) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    var res = sp.getDouble(key);
    return res ?? def;
  }

  static Future<List<String>> getStringList(
      String key, List<String> def) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    var res = sp.getStringList(key);
    return res ?? def;
  }
}
