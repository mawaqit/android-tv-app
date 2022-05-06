import 'package:flutter/material.dart';

import './storage_manager.dart';

class ThemeNotifier with ChangeNotifier {
  /// used getter to support hot restart in development
  ThemeData get darkTheme => ThemeData(
        primaryIconTheme: IconThemeData(
          color: Colors.white,
        ),
        iconTheme: IconThemeData(
          color: Colors.white.withOpacity(.3),
        ),
        brightness: Brightness.dark,
        primaryColor: Colors.deepPurple[400],
        primaryColorDark: Colors.deepPurple[800],
        selectedRowColor: Colors.deepPurple[800],
        focusColor: Colors.deepPurpleAccent.withOpacity(.3),
        canvasColor: Color(0xff121212),
        colorScheme: ColorScheme.fromSwatch(
          brightness: Brightness.dark,
          primarySwatch: Colors.deepPurple,
          // backgroundColor: Color(0xff121212),
        ),
      );

  /// used getter to support hot restart in development
  ThemeData get lightTheme => ThemeData(

        primarySwatch: Colors.deepPurple,
        selectedRowColor: Colors.deepPurple[100],
        cardColor: Colors.deepPurple[50],
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.deepPurple,
          backgroundColor: Colors.white,
          cardColor: Colors.deepPurple[50],
        ),
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
