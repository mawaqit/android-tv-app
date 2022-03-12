import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:lottie/lottie.dart';
import 'package:mawaqit/generated/l10n.dart';
import 'package:mawaqit/src/helpers/AppRouter.dart';
import 'package:mawaqit/src/helpers/mawaqit_icons_icons.dart';
import 'package:mawaqit/src/models/settings.dart';
import 'package:mawaqit/src/pages/HomeScreen.dart';
import 'package:mawaqit/src/pages/onBoarding/widgets/LanuageSelectorWidget.dart';
import 'package:mawaqit/src/pages/onBoarding/widgets/MousqeSelectorWidget.dart';
import 'package:mawaqit/src/services/settings_manager.dart';
import 'package:mawaqit/src/widgets/mawaqit_circle_button_widget.dart';
import 'package:provider/provider.dart';

class OnBoardingScreen extends StatefulWidget {
  // final String url;
  final Settings settings;

  const OnBoardingScreen(this.settings);

  @override
  _OnBoardingScreenState createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  @override
  Widget build(BuildContext context) {
    Settings getSettings() {
      final settingsManager = Provider.of<SettingsManager>(context);
      return settingsManager.settingsLoaded ? settingsManager.settings : widget.settings;
    }

    const bodyStyle = TextStyle(fontSize: 15.0);
    PageDecoration pageDecoration = PageDecoration(
      imageFlex: 3,
      bodyFlex: 7,
      titleTextStyle: TextStyle(
        fontSize: 25.0,
        fontWeight: FontWeight.w700,
        color: Theme.of(context).primaryColor,
      ),
      bodyTextStyle: bodyStyle,
      contentMargin: EdgeInsets.all(1.0),
      titlePadding: EdgeInsets.only(
        bottom: 10,
      ),
      pageColor: Theme.of(context).dialogBackgroundColor,
      imagePadding: EdgeInsets.zero,
    );

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: IntroductionScreen(
        globalBackgroundColor: Theme.of(context).dialogBackgroundColor,
        showDoneButton: false,
        showSkipButton: false,
        showBackButton: false,
        nextFlex: 0,
        next: MawaqitCircleButton(
          icon: Localizations.localeOf(context).languageCode == 'ar'
              ? MawaqitIcons.icon_arrow_left
              : MawaqitIcons.icon_arrow_right,
          color: Theme.of(context).primaryColor,
          size: 21,
        ),
        pages: [
          PageViewModel(
            title: S.of(context).appLang,
            image: _buildImage('language'),
            decoration: pageDecoration,
            useScrollView: false,
            bodyWidget: Expanded(
              child: FractionallySizedBox(
                widthFactor: .6,
                child: OnBoardingLanguageSelector(),
              ),
            ),
          ),
          PageViewModel(
            title: S.of(context).mawaqitWelcome,
            image: _buildImage('welcome'),
            decoration: pageDecoration,
            useScrollView: false,
            bodyWidget: Expanded(
              child: FractionallySizedBox(
                widthFactor: .6,
                child: Align(
                  alignment: Alignment(0, -.8),
                  child: Text(
                    S.of(context).mawaqitDesc,
                    style: TextStyle(
                      fontSize: 19,
                      color: Theme.of(context).primaryColorDark,
                    ),
                  ),
                ),
              ),
            ),
          ),
          PageViewModel(
            title: S.of(context).selectMosqueId,
            image: _buildImage('search'),
            decoration: pageDecoration,
            useScrollView: false,
            bodyWidget: Expanded(
              child: FractionallySizedBox(
                widthFactor: .6,
                child: OnBoardingMosqueSelector(onDone: () {
                  AppRouter.push(HomeScreen(widget.settings));
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String assetName) {
    return Align(
      child: Lottie.asset(
        'assets/animations/lottie/$assetName.json',
        fit: BoxFit.contain,
      ),
      alignment: Alignment.center,
    );
  }
}
