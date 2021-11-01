import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flyweb/src/data/config.dart';
import 'package:flyweb/src/helpers/HexColor.dart';
import 'package:flyweb/src/helpers/SharedPref.dart';
import 'package:flyweb/src/models/settings.dart';
import 'package:flyweb/src/pages/HomeScreen.dart';
import 'package:flyweb/src/pages/OnBoardingScreen.dart';
import 'package:flyweb/src/repository/settings_service.dart';
import 'package:flyweb/src/services/theme_manager.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:uni_links/uni_links.dart';

class SplashScreen extends StatefulWidget {
  final Settings settings;

  SplashScreen({this.settings});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new _SplashScreen(settingsSplach: this.settings);
  }
}

class _SplashScreen extends State<SplashScreen> {
  final SettingsService settingsService = SettingsService();
  SharedPref sharedPref = SharedPref();
  String url = "";
  String onesignalUrl = "";
  Settings settings = new Settings();
  Settings settingsSplach = new Settings();
  bool applicationProblem = false;
  bool goBoarding = false;
  StreamSubscription _linkSubscription;

  _SplashScreen({this.settingsSplach});

  @override
  void initState() {
    super.initState();
    initOneSignal();
    getSettings();
    loadBoarding();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> initOneSignal() async {
    if (!mounted) return;

    OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);

    OneSignal.shared.setRequiresUserPrivacyConsent(true);

    var settings = {OSiOSSettings.autoPrompt: false, OSiOSSettings.promptBeforeOpeningPushUrl: true};

    OneSignal.shared.setNotificationReceivedHandler((OSNotification notification) {
      this.setState(() {});
    });

    OneSignal.shared.setNotificationOpenedHandler((OSNotificationOpenedResult result) {
      this.setState(() {});
    });

    OneSignal.shared.setInAppMessageClickedHandler((OSInAppMessageAction action) {
      this.setState(() {});
    });

    OneSignal.shared.setSubscriptionObserver((OSSubscriptionStateChanges changes) {});

    OneSignal.shared.setPermissionObserver((OSPermissionStateChanges changes) {});

    OneSignal.shared.setEmailSubscriptionObserver((OSEmailSubscriptionStateChanges changes) {});

    // NOTE: Replace with your own app ID from https://www.onesignal.com
    await OneSignal.shared.init('${GlobalConfiguration().getString('appIdOneSignal')}', iOSSettings: settings);

    OneSignal.shared.setInFocusDisplayType(OSNotificationDisplayType.notification);

    bool requiresConsent = await OneSignal.shared.requiresUserPrivacyConsent();

    OneSignal.shared.consentGranted(true);
  }

  Future loadBoarding() async {
    try {
      var res = await sharedPref.read("boarding");
      if (res == null) {
        setState(() {
          goBoarding = true;
        });
      }
    } on Exception catch (exception) {
      setState(() {
        goBoarding = true;
      });
    } catch (Excepetion) {
      setState(() {
        goBoarding = true;
      });
    }
  }

  Future<bool> _mockCheckForSession() async {
    await Future.delayed(Duration(milliseconds: 3000), () {});
    return true;
  }

  getSettings() async {
    try {
      Settings _settings = await settingsService.getSettings();
      sharedPref.save("settings", _settings);
      this.setState(() {
        url = _settings.url;
        if (settings == null) settingsSplach = _settings;
        settings = _settings;
        applicationProblem = false;
      });
      _mockCheckForSession().then((status) {
        var future = new Future.delayed(const Duration(milliseconds: 150), _navigateToHome);
      });
    } on Exception catch (exception) {
      this.setState(() {
        applicationProblem = true;
      });
    } catch (Excepetion) {
      applicationProblem = true;
    }
  }

  void _navigateToHome() {
    if (goBoarding && widget.settings.boarding == "1") {
      sharedPref.save("boarding", "true");
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => OnBoardingScreen(onesignalUrl != "" ? onesignalUrl : url, settings)));
    } else {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => HomeScreen(onesignalUrl != "" ? onesignalUrl : url, settings)));
    }
  }

  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    Color firstColor = (settingsSplach != null && settingsSplach.splash != null && settingsSplach.splash.enable_img == "1")
        ? HexColor("#FFFFFF")
        : (settingsSplach.splash != null && settingsSplach.splash.firstColor != null && settingsSplach.splash.firstColor != "")
            ? HexColor(settingsSplach.splash.firstColor)
            : HexColor('${GlobalConfiguration().getValue('firstColor')}');

    Color secondColor = (settingsSplach != null && settingsSplach.splash != null && settingsSplach.splash.enable_img == "1")
        ? HexColor("#FFFFFF")
        : (settingsSplach.splash != null && settingsSplach.splash.secondColor != null && settingsSplach.splash.secondColor != "")
            ? HexColor(settingsSplach.splash.secondColor)
            : HexColor('${GlobalConfiguration().getValue('secondColor')}');

    // TODO: implement build
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, stops: [
              0,
              1
            ], colors: [
              firstColor,
              secondColor,
            ])),
          ),
          (settingsSplach.splash != null && settingsSplach.splash.enable_img != null && settingsSplach.splash.enable_img == "1")
              ? Positioned(
                  top: 0,
                  right: 0,
                  child: Image.memory(
                    Base64Decoder().convert(settingsSplach.splash.img_splash_base64),
                    fit: BoxFit.cover,
                    height: height,
                    width: width,
                    alignment: Alignment.center,
                  ),
                )
              : Container(),
          (settingsSplach.splash != null && settingsSplach.splash.enable_logo != null)
              ? settingsSplach.splash.enable_logo == "1"
                  ? Align(
                      alignment: Alignment.center,
                      child: Image.memory(Base64Decoder().convert(settingsSplach.splash.logo_splash_base64), height: 150, width: 150),
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
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
                          ),
                          Text(
                            "We're sorry, our system is not available",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          )
                        ],
                      )))
              : Container()
        ],
      ),
    );
  }
}
