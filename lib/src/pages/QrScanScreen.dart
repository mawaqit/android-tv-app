import 'package:flutter/material.dart';
import 'package:flyweb/i18n/i18n.dart';
import 'package:flyweb/src/helpers/HexColor.dart';
import 'package:flyweb/src/helpers/SharedPref.dart';
import 'package:flyweb/src/models/settings.dart';
import 'package:flyweb/src/services/theme_manager.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';

class QrScanScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new _QrScanScreen();
  }
}

class _QrScanScreen extends State<QrScanScreen> {
  SharedPref sharedPref = SharedPref();
  Settings settings = Settings();

  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: '',
    buildNumber: 'Unknown',
  );

  @override
  void initState() {
    super.initState();
    loadSharedPrefs();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
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
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 0, top: 80, right: 0, bottom: 10),
              child: Container(
                width: 100.0,
                height: 100.0,
                decoration: BoxDecoration(
                  //color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(100),
                      topRight: Radius.circular(100),
                      bottomLeft: Radius.circular(100),
                      bottomRight: Radius.circular(100)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 3,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: Padding(
                    padding: EdgeInsets.all(13),
                    child: Image.network(
                      settings.logoHeaderUrl!,
                    )),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 0, top: 10, right: 0, bottom: 10),
              child: Center(
                  child: Text(
                settings.title!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              )),
            ),
            Text(
              "v " + _packageInfo.version,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300),
            ),
            Padding(
              padding:
                  EdgeInsets.only(left: 20, top: 40, right: 20, bottom: 10),
              child: Center(
                  child: Text(
                settings.aboutUs!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300),
              )),
            ),
            Spacer(flex: 1),
            Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: Text(
                  "Follow Us",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300),
                )),
            SizedBox(height: 30),
          ],
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
