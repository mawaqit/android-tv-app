import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPref {
  Future<dynamic> read(String key) async {
    final prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey(key)) {
      if (prefs.getBool(key) != null) {
        return prefs.getBool(key);
      } else {
        final value = prefs.getString(key);
        return value != null ? json.decode(value) : null;
      }
    }

    return null;
  }

  Future<void> save(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();

    if (value is bool) {
      await prefs.setBool(key, value);
    } else {
      await prefs.setString(key, json.encode(value));
    }
  }

  Future<void> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }
}
