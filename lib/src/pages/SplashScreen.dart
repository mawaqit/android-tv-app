import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mawaqit/src/data/config.dart';
import 'package:mawaqit/src/helpers/AppRouter.dart';
import 'package:mawaqit/src/helpers/HexColor.dart';
import 'package:mawaqit/src/helpers/SharedPref.dart';
import 'package:mawaqit/src/models/settings.dart';
import 'package:mawaqit/src/pages/HomeScreen.dart';
import 'package:mawaqit/src/pages/onBoarding/OnBoardingScreen.dart';
import 'package:mawaqit/src/repository/settings_service.dart';
import 'package:mawaqit/src/services/settings_manager.dart';
import 'package:mawaqit/src/widgets/InfoWidget.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  final Settings? localSettings;

  SplashScreen({required this.localSettings});

  @override
  State<StatefulWidget> createState() => new _SplashScreen();
}

class _SplashScreen extends State<SplashScreen> {
  final SettingsService settingsService = SettingsService();
  SharedPref sharedPref = SharedPref();

  bool applicationProblem = false;

  Future<bool> loadBoarding() async {
    var res = await sharedPref.read("boarding");
    return res == null;
  }

  ///
  Future<String?> loadMosqueId() async {
    String? id = await sharedPref.read("mosqueId");

    return id;
  }

  /// navigates to first screen
  void _navigateToHome(Settings settings) async {
    var goBoarding = await loadBoarding();
    var mosqueId = await loadMosqueId();

    if (mosqueId == null || goBoarding && settings.boarding == "1") {
      AppRouter.pushReplacement(OnBoardingScreen(settings));
    } else {
      AppRouter.pushReplacement(HomeScreen(settings));
    }
  }

  Widget build(BuildContext context) {
    final settingsManager = Provider.of<SettingsManager>(context);

    if (settingsManager.settingsLoaded) {
      // Future.delayed(Duration(milliseconds: 80)).then((value) =>);
      _navigateToHome(settingsManager.settings);
    }
    var settingsSplach = widget.localSettings;

    Color firstColor = settingsSplach?.splash?.enable_img == "1"
        ? HexColor("#FFFFFF")
        : (settingsSplach?.splash!.firstColor != null && settingsSplach?.splash!.firstColor != "")
            ? HexColor(settingsSplach!.splash!.firstColor)
            : HexColor('${GlobalConfiguration().getValue('firstColor')}');

    Color secondColor = settingsSplach?.splash?.enable_img == "1"
        ? HexColor("#FFFFFF")
        : (settingsSplach?.splash?.secondColor != null && settingsSplach?.splash!.secondColor != "")
            ? HexColor(settingsSplach!.splash!.secondColor)
            : HexColor('${GlobalConfiguration().getValue('secondColor')}');

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0, 1],
                colors: [
                  firstColor,
                  secondColor,
                ],
              ),
            ),
          ),
          (settingsSplach?.splash?.enable_img == "1")
              ? Image.asset(
                  'assets/img/background.png',
                  fit: BoxFit.cover,
                )
              : Container(),
          (settingsSplach?.splash?.enable_logo != null)
              ? settingsSplach?.splash?.enable_logo == "1"
                  ? Align(
                      alignment: Alignment.center,
                      child: Image.memory(
                        Base64Decoder().convert(
                          settingsSplach!.splash!.logo_splash_base64!,
                        ),
                        height: 150,
                        width: 150,
                      ),
                    )
                  : Container()
              : Center(child: Config.logo),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: VersionWidget(
                style: GoogleFonts.roboto(
                  fontSize: 18,
                  color: Colors.white54,
                ),
              ),
            ),
          ),
          (applicationProblem == true)
              ? Positioned(
                  bottom: 160,
                  right: 0,
                  left: 0,
                  child: Padding(
                    padding: EdgeInsets.only(top: 50),
                    child: Column(
                      children: [
                        Text(
                          "System down for maintenance",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
                        ),
                        Text(
                          "We're sorry, our system is not available",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}
