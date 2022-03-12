import 'package:flutter/material.dart';
import 'package:mawaqit/generated/l10n.dart';
import 'package:mawaqit/src/helpers/HexColor.dart';
import 'package:mawaqit/src/helpers/SharedPref.dart';
import 'package:mawaqit/src/models/settings.dart';
import 'package:mawaqit/src/services/settings_manager.dart';
import 'package:provider/provider.dart';

class AboutScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _AboutScreen();
}

class _AboutScreen extends State<AboutScreen> {
  SharedPref sharedPref = SharedPref();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final settingsManager = Provider.of<SettingsManager>(context);
    final settings = settingsManager.settings;

    return Scaffold(
      appBar: _renderAppBar(context, settings),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(children: <Widget>[]),
        ),
      ),
    );
  }
}

AppBar _renderAppBar(context, Settings settings) {
  return AppBar(
      title: Text(
        S.of(context).about,
        style: TextStyle(color: Colors.white, fontSize: 22.0, fontWeight: FontWeight.bold),
      ),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: <Color>[
              Theme.of(context).brightness == Brightness.light
                  ? HexColor(settings.firstColor)
                  : Theme.of(context).primaryColor,
              Theme.of(context).brightness == Brightness.light
                  ? HexColor(settings.secondColor)
                  : Theme.of(context).primaryColor,
            ],
          ),
        ),
      ));
}
