import 'package:flutter/material.dart';
import 'package:mawaqit/src/helpers/StringUtils.dart';

import './storage_manager.dart';

class ThemeNotifier with ChangeNotifier {
  /// used getter to support hot restart in development
  ThemeData get darkTheme => ThemeData(
        toggleButtonsTheme: ToggleButtonsThemeData(
          disabledColor: Colors.white,
          color: Color(0xff490094),
        ),
        cardColor: Color(0xff161b22),
        brightness: Brightness.dark,
        primarySwatch: Colors.deepPurple,
        primaryColor: Color(0xff490094),
        primaryColorDark: Color(0xff490094),
        primaryColorLight: Color(0xff490094),
        switchTheme: SwitchThemeData(
          overlayColor: MaterialStateProperty.all(Colors.white.withOpacity(0.1)),
          thumbColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return Colors.deepPurple.shade100;
            } else if (states.contains(MaterialState.focused)) {
              return Color(0xffdbccea);
            }
            return Colors.white;
          }),
          trackColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return Colors.deepPurple;
            } else if (states.contains(MaterialState.focused)) {
              return Colors.grey;
            }

            return Colors.grey;
          }),
        ),
        textTheme: Typography.material2014().white.apply(
          fontFamily: StringManager.fontFamilyHelvetica,
          fontFamilyFallback: [StringManager.fontFamilyKufi],
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: ButtonStyle(
            overlayColor: MaterialStateProperty.all(Color(0xff490094)),
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
        focusColor: Color(0xff490094),
        dialogBackgroundColor: Color(0xff121212),
        canvasColor: Color(0xff121212),
        backgroundColor: Color(0xff121212),
        scaffoldBackgroundColor: Color(0xff121212),
        selectedRowColor: Color(0xff490094),
        colorScheme: ColorScheme.dark(
          brightness: Brightness.dark,
          primary: Colors.white,
        ),
      );

  /// used getter to support hot restart in development
  ThemeData get lightTheme => ThemeData(
        toggleButtonsTheme: ToggleButtonsThemeData(disabledColor: Colors.white, color: Color(0xff490094)),
        primarySwatch: Colors.deepPurple,
        // selectedRowColor: Color(0xff490094),
        // cardColor: Color(0xff490094),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: ButtonStyle(
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xff490094),
          onPrimary: Colors.white,
        ),
        focusColor: Color(0xff9243E0),
      );

  bool? isLightTheme;

  ///when isLightTheme == null will use the default system theme
  ThemeMode? get mode => isLightTheme == null
      ? ThemeMode.dark
      : isLightTheme!
          ? ThemeMode.light
          : ThemeMode.dark;

  ThemeNotifier() {
    StorageManager.readData('themeMode').then((themeMode) {
      print('value read from storage: ' + themeMode.toString());
      if (themeMode == 'light') {
        isLightTheme = true;
      } else if (themeMode == 'dark') {
        // print('setting dark theme');
        isLightTheme = false;
      }
      notifyListeners();
    });
  }

  static Gradient quranBackground() => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF28262F),
          Color(0xFF121117),
        ],
      );

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

  void toggleMode() async {
    isLightTheme = !(isLightTheme ?? true);
    StorageManager.saveData('themeMode', isLightTheme! ? 'light' : 'dark');
    notifyListeners();
  }
}
