import 'package:flutter/material.dart';

import './storage_manager.dart';

class ThemeNotifier with ChangeNotifier {
  /// used getter to support hot restart in development
  ThemeData get darkTheme => ThemeData(
        primarySwatch: Colors.grey,
        primaryColor: Colors.black,
        brightness: Brightness.dark,
        backgroundColor: const Color(0xFF212121),
        accentColor: Colors.white,
        accentIconTheme: IconThemeData(color: Colors.black),
        focusColor: Colors.grey,
        dividerColor: Colors.black12,
        canvasColor: Colors.black,
      );

  /// used getter to support hot restart in development
  ThemeData get lightTheme => ThemeData(
        primarySwatch: Colors.deepPurple,
        selectedRowColor: Colors.deepPurple[100],
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.deepPurple, backgroundColor: Colors.white),
        focusColor: Colors.deepPurpleAccent.withOpacity(.5),
      );

  bool? isLightTheme;

  ///when isLightTheme == null will use the default system theme
  ThemeMode? get mode => isLightTheme == null
      ? null
      : isLightTheme!
          ? ThemeMode.light
          : ThemeMode.dark;

  ThemeNotifier() {
    StorageManager.readData('themeMode').then((themeMode) {
      print('value read from storage: ' + themeMode.toString());
      if (themeMode == 'light') {
        isLightTheme = true;
      } else if (themeMode == 'dark') {
        print('setting dark theme');
        isLightTheme = false;
      }
      notifyListeners();
    });
  }

  void setDarkMode() async {
    isLightTheme = false;
    StorageManager.saveData('themeMode', 'dark');
    notifyListeners();
  }

  void setLightMode() async {
    isLightTheme = true;
    StorageManager.saveData('themeMode', 'light');
    notifyListeners();
  }
}
