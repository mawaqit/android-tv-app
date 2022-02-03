import 'package:flutter/material.dart';

import './storage_manager.dart';

class ThemeNotifier with ChangeNotifier {
  final darkTheme = ThemeData(
    primarySwatch: Colors.grey,
    primaryColor: Colors.black,
    brightness: Brightness.dark,
    backgroundColor: const Color(0xFF212121),
    accentColor: Colors.white,
    accentIconTheme: IconThemeData(color: Colors.black),
    dividerColor: Colors.black12,
    canvasColor: Colors.black,
  );

  final lightTheme = ThemeData(
      // primarySwatch: Colors.grey,
      // primaryColor: Colors.white,
      // brightness: Brightness.light,
      // backgroundColor: const Color(0xFFE5E5E5),
      // accentColor: Colors.black,
      // accentIconTheme: IconThemeData(color: Colors.white),
      // dividerColor: Colors.white54,
      // canvasColor: Colors.white,
      );

  ThemeData _themeData;

  ThemeData getTheme() => _themeData;
  bool isLightTheme;

  ThemeNotifier() {
    StorageManager.readData('themeMode').then((value) {
      print('value read from storage: ' + value.toString());
      var themeMode = value ?? 'light';
      if (themeMode == 'light') {
        _themeData = lightTheme;
        isLightTheme = true;
      } else {
        print('setting dark theme');
        _themeData = darkTheme;
        isLightTheme = false;
      }
      notifyListeners();
    });
  }

  void setDarkMode() async {
    _themeData = darkTheme;
    isLightTheme = false;
    StorageManager.saveData('themeMode', 'dark');
    notifyListeners();
  }

  void setLightMode() async {
    _themeData = lightTheme;
    isLightTheme = true;
    StorageManager.saveData('themeMode', 'light');
    notifyListeners();
  }
}
