import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flyweb/i18n/AppLanguage.dart';
import 'package:flyweb/src/data/config.dart';
import 'package:flyweb/src/helpers/HexColor.dart';
import 'package:flyweb/src/helpers/SharedPref.dart';
import 'package:flyweb/src/models/settings.dart';
import 'package:flyweb/src/pages/HomeScreen.dart';
import 'package:flyweb/src/pages/onBoarding/OnBoardingScreen.dart';
import 'package:flyweb/src/repository/settings_service.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class SplashScreen extends StatefulWidget {
  final Settings settings;

  SplashScreen({this.settings});

  @override
  State<StatefulWidget> createState() =>
      new _SplashScreen(settingsSplach: this.settings);
}

class _SplashScreen extends State<SplashScreen> {
  final SettingsService settingsService = SettingsService();
  SharedPref sharedPref = SharedPref();

  // String url = "";
  // String onesignalUrl = "";
  Settings settings = new Settings();
  Settings settingsSplach = new Settings();
  bool applicationProblem = false;

  // bool goBoarding = false;
  // StreamSubscription _linkSubscription;

  _SplashScreen({this.settingsSplach});

  @override
  void initState() {
    super.initState();
    initOneSignal();
    getSettings();
    // loadBoarding();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> initOneSignal() async {
    if (!mounted) return;

    OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);

    OneSignal.shared.setRequiresUserPrivacyConsent(true);

    var settings = {
      OSiOSSettings.autoPrompt: false,
      OSiOSSettings.promptBeforeOpeningPushUrl: true
    };

    OneSignal.shared.setNotificationWillShowInForegroundHandler((data) {
      this.setState(() {});
    });

    OneSignal.shared.setNotificationOpenedHandler(
        (OSNotificationOpenedResult result) => this.setState(() {}));

    OneSignal.shared
        .setInAppMessageClickedHandler((OSInAppMessageAction action) {
      this.setState(() {});
    });

    OneSignal.shared
        .setSubscriptionObserver((OSSubscriptionStateChanges changes) {});

    OneSignal.shared
        .setPermissionObserver((OSPermissionStateChanges changes) {});

    OneSignal.shared.setEmailSubscriptionObserver(
        (OSEmailSubscriptionStateChanges changes) {});

    // todo add [infocusdisplaytype] [iosSetting]
    // NOTE: Replace with your own app ID from https://www.onesignal.com
    await OneSignal.shared.setAppId(
      '${GlobalConfiguration().getValue('appIdOneSignal')}',

      // iOSSettings: settings,
    );

    // OneSignal.shared
    //     .setInFocusDisplayType(OSNotificationDisplayType.notification);

    bool requiresConsent = await OneSignal.shared.requiresUserPrivacyConsent();

    OneSignal.shared.consentGranted(true);
  }

  Future<bool> loadBoarding() async {
    var res = await sharedPref.read("boarding").catchError((e) => null);
    return res == null;
  }

  ///
  Future<String> loadMosqueId() async {
    String id = await sharedPref.read("mosqueId").catchError((e) => null);

    return id;
  }

  Future<bool> _mockCheckForSession() async {
    await Future.delayed(Duration(milliseconds: 3000), () {});
    return true;
  }

  getSettings() async {
    try {
      Settings _serverSettings = await settingsService.getSettings();
      sharedPref.save("settings", _serverSettings);
      this.setState(() {
        if (settings == null) settingsSplach = _serverSettings;
        settings = _serverSettings;
        applicationProblem = false;
      });
      _mockCheckForSession().then((status) => Future.delayed(
            const Duration(milliseconds: 150),
            _navigateToHome,
          ));
    } on Exception catch (exception) {
      this.setState(() {
        applicationProblem = true;
      });
    } catch (e) {
      applicationProblem = true;
    }
  }

  /// navigates to first screen
  void _navigateToHome() async {
    var goBoarding = await loadBoarding();
    var mosqueId = await loadMosqueId();

    if (mosqueId == null || goBoarding && widget.settings.boarding == "1") {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (BuildContext context) => OnBoardingScreen(settings),
        ),
      );
    } else {
      var url =
          'https://mawaqit.net/${AppLanguage().appLocal.languageCode}/id/$mosqueId?view=desktop';

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (BuildContext context) => HomeScreen(url, settings),
        ),
      );
    }
  }

  Widget build(BuildContext context) {
    // double width = MediaQuery.of(context).size.width;
    // double height = MediaQuery.of(context).size.height;

    Color firstColor = (settingsSplach != null &&
            settingsSplach.splash != null &&
            settingsSplach.splash.enable_img == "1")
        ? HexColor("#FFFFFF")
        : (settingsSplach.splash != null &&
                settingsSplach.splash.firstColor != null &&
                settingsSplach.splash.firstColor != "")
            ? HexColor(settingsSplach.splash.firstColor)
            : HexColor('${GlobalConfiguration().getValue('firstColor')}');

    Color secondColor = (settingsSplach != null &&
            settingsSplach.splash != null &&
            settingsSplach.splash.enable_img == "1")
        ? HexColor("#FFFFFF")
        : (settingsSplach.splash != null &&
                settingsSplach.splash.secondColor != null &&
                settingsSplach.splash.secondColor != "")
            ? HexColor(settingsSplach.splash.secondColor)
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
          (settingsSplach.splash != null &&
                  settingsSplach.splash.enable_img != null &&
                  settingsSplach.splash.enable_img == "1")
              ? /*Image.memory(
                  Base64Decoder()
                      .convert(settingsSplach.splash.img_splash_base64),
                  fit: BoxFit.cover,
                  height: height,
                  width: width,
                  alignment: Alignment.center,
                )*/
              Image.asset(
                  'assets/img/background.png',
                  fit: BoxFit.cover,
                )
              : Container(),
          (settingsSplach.splash != null &&
                  settingsSplach.splash.enable_logo != null)
              ? settingsSplach.splash.enable_logo == "1"
                  ? Align(
                      alignment: Alignment.center,
                      child: Image.memory(
                        Base64Decoder()
                            .convert(settingsSplach.splash.logo_splash_base64),
                        height: 150,
                        width: 150,
                      ),
                    )
                  : Container()
              : Align(alignment: Alignment.center, child: Config.logo),
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
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.white),
                        ),
                        Text(
                          "We're sorry, our system is not available",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        )
                      ],
                    ),
                  ),
                )
              : Container()
        ],
      ),
    );
  }
}
