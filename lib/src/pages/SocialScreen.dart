import 'package:flutter/material.dart';
import 'package:flyweb/i18n/i18n.dart';
import 'package:flyweb/src/helpers/HexColor.dart';
import 'package:flyweb/src/helpers/SharedPref.dart';
import 'package:flyweb/src/models/settings.dart';
import 'package:flyweb/src/services/theme_manager.dart';
import 'package:provider/provider.dart';

class AboutScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new _AboutScreen();
  }
}

class _AboutScreen extends State<AboutScreen> {
  SharedPref sharedPref = SharedPref();
  Settings settings = Settings();

  @override
  void initState() {
    super.initState();
    loadSharedPrefs();
  }

  Future loadSharedPrefs() async {
    try {
      Settings _settings = Settings.fromJson(await sharedPref.read("settings"));
      setState(() {
        settings = _settings;
      });
    } catch (Excepetion) {}
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return Scaffold(
      appBar: _renderAppBar(context, settings) as PreferredSizeWidget?,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(children: <Widget>[]),
        ),
      ),
    );
  }
}

Widget _renderAppBar(context, Settings settings) {
  var themeProvider = Provider.of<ThemeNotifier>(context);
  return AppBar(
      title: Text(
        I18n.current!.about,
        style: TextStyle(
            color: Colors.white, fontSize: 22.0, fontWeight: FontWeight.bold),
      ),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: <Color>[
              themeProvider.isLightTheme!
                  ? HexColor(settings.firstColor)
                  : themeProvider.darkTheme.primaryColor,
              themeProvider.isLightTheme!
                  ? HexColor(settings.secondColor)
                  : themeProvider.darkTheme.primaryColor,
            ],
          ),
        ),
      ));
}
