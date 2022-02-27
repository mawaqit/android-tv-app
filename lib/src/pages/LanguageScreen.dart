import 'package:flutter/material.dart';
import 'package:flyweb/i18n/AppLanguage.dart';
import 'package:flyweb/i18n/i18n.dart';
import 'package:flyweb/src/data/config.dart';
import 'package:flyweb/src/helpers/HexColor.dart';
import 'package:flyweb/src/helpers/SharedPref.dart';
import 'package:flyweb/src/services/mosque_manager.dart';
import 'package:flyweb/src/services/settings_manager.dart';
import 'package:flyweb/src/services/theme_manager.dart';
import 'package:provider/provider.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _LanguageScreen();
}

class _LanguageScreen extends State<LanguageScreen> {
  SharedPref sharedPref = SharedPref();
  List languages = Config.language;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _changeLanguage(Map language) async {
    var appLanguage = Provider.of<AppLanguage>(context, listen: false);
    var mosqueId = Provider.of<MosqueManager>(context, listen: false).mosqueId;

    appLanguage.changeLanguage(Locale(language['value'], ""), mosqueId);
  }

  @override
  Widget build(BuildContext context) {
    var appLanguage = Provider.of<AppLanguage>(context);

    return Scaffold(
      appBar: _renderAppBar(context),
      body: SafeArea(
        child: Column(
          children: [
            Row(children: [
              Container(
                padding: EdgeInsets.all(20),
                child: Icon(
                  Icons.translate,
                  size: 30,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    I18n.current!.appLang,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    I18n.current!.descLang,
                    style: TextStyle(
                      color: Colors.black38,
                      fontSize: 13,
                    ),
                  )
                ],
              )
            ]),
            Expanded(
              child: Container(
                child: ListView.builder(
                  itemCount: languages.length,
                  // Add one more item for progress indicator
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  itemBuilder: (BuildContext context, int index) =>
                      new ListTile(
                    onTap: () => _changeLanguage(languages[index]),
                    leading: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.black26,
                      child: Locale(languages[index]['value'], "") ==
                              appLanguage.appLocal
                          ? Container(
                              padding: EdgeInsets.all(10.0),
                              child: Image.asset(
                                'assets/img/checked.png',
                                color: Colors.white,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Color.fromRGBO(35, 208, 101, 0.5),
                              ),
                            )
                          : Container(),
                      backgroundImage: ExactAssetImage('assets/img/flag/' +
                          languages[index]['value'] +
                          '.png'),
                    ),
                    title: Text(
                      languages[index]['name'],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(languages[index]['subtitle']),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  AppBar _renderAppBar(context) {
    var themeProvider = Provider.of<ThemeNotifier>(context);
    final settingsManager = Provider.of<SettingsManager>(context);
    final settings = settingsManager.settings;

    return AppBar(
        title: Text(
          I18n.current!.languages,
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
}
