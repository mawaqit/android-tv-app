import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class TypeMisMatchException implements Exception {
  final String message;

  TypeMisMatchException(this.message);

  @override
  String toString() {
    return message;
  }
}

class SharedPref {
  @deprecated
  Future<dynamic> read(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(key);

    if (value == null) return null;

    return json.decode(value);
  }

  @deprecated
  Future<void> save(String key, value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, json.encode(value));
  }

  @deprecated
  Future<void> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(key);
  }

  /// if null will remove the value
  Future<dynamic> setDynamic<T>(String key, T? value) async {
    final prefs = await SharedPreferences.getInstance();

    if (value == null) return prefs.remove(key);

    switch (T) {
      case String:
        return prefs.setString(key, value as String);
      case int:
        return prefs.setInt(key, value as int);
      case double:
        return prefs.setDouble(key, value as double);
      case bool:
        return prefs.setBool(key, value as bool);
      case List:
        return prefs.setStringList(key, value as List<String>);
      default:
        return prefs.setString(key, jsonEncode(value));
    }
  }

  Future<T?> readDynamic<T>(
    String key, {
    /// if type not match return null
    bool throwError = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.get(key);

    if (value == null) return null;

    if (T is Map) {
      try {
        return jsonDecode(value.toString());
      } catch (e) {
        if (throwError) throw e;

        return null;
      }
    } else if (value is T) {
      return value as T;
    } else if (throwError) {
      throw TypeMisMatchException('$value is not $T of the key $key');
    } else {
      return null;
    }
  }
}
