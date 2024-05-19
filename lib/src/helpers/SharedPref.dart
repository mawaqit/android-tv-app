import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SharedPref {
  Future<dynamic> read(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(key);

    if (value == null) return null;

    return json.decode(value);
  }

  Future<void> save(String key, value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, json.encode(value));
  }

  Future<void> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(key);
  }
}
