import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:mawaqit/src/helpers/AppRouter.dart';
import 'package:mawaqit/src/helpers/SharedPref.dart';
import 'package:mawaqit/src/helpers/mawaqit_icons_icons.dart';
import 'package:mawaqit/src/models/settings.dart';
import 'package:mawaqit/src/pages/HomeScreen.dart';
import 'package:mawaqit/src/pages/mosque_search/MosqueSearch.dart';
import 'package:mawaqit/src/pages/onBoarding/widgets/LanuageSelectorWidget.dart';
import 'package:mawaqit/src/pages/onBoarding/widgets/MawaqitAboutWidget.dart';
import 'package:mawaqit/src/widgets/InfoWidget.dart';
import 'package:mawaqit/src/widgets/mawaqit_circle_button_widget.dart';

class OnBoardingScreen extends StatefulWidget {
  // final String url;
  final Settings settings;

  const OnBoardingScreen(this.settings);

  @override
  _OnBoardingScreenState createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final sharedPref = SharedPref();
  final _nextButtonFocusNode = FocusNode();

  int currentScreen = 0;

  String get currentImage {
    switch (currentScreen) {
      case 0:
        return 'language';
      case 1:
        return 'welcome';
      case 2:
        return 'search';
      default:
        return '';
    }
  }

  Widget get currentScreenWidget {
    if (currentScreen == 0) {
      return OnBoardingLanguageSelector(
        onSelect: () => setState(() => currentScreen++),
      );
    }

    if (currentScreen == 1)
      return Focus(
        autofocus: true,
        onKey: (FocusNode node, RawKeyEvent event) {
          print(event.logicalKey);

          if (event.isKeyPressed(LogicalKeyboardKey.select) || event.isKeyPressed(LogicalKeyboardKey.enter)) {
            setState(() => currentScreen++);
            return KeyEventResult.handled;
          }

          return KeyEventResult.ignored;
        },
        child: OnBoardingMawaqitAboutWidget(),
      );

    if (currentScreen == 2)
      return MosqueSearch(
        onDone: () {
          sharedPref.save('boarding', 'true');
          AppRouter.pushReplacement(HomeScreen(widget.settings));
        },
      );

    return SizedBox();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (currentScreen == 0) return true;

        setState(() => currentScreen--);
        return false;
      },
      child: SafeArea(
        child: Scaffold(
          body: Row(
            children: [
              Expanded(
                flex: 4,
                child: _buildImage(currentImage),
              ),
              Expanded(
                flex: 6,
                child: currentScreenWidget,
              ),
            ],
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            height: 80,
            child: Row(
              children: [
                VersionWidget(
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyText1?.color?.withOpacity(.5),
                  ),
                ),
                Spacer(flex: 2),
                DotsIndicator(
                  dotsCount: 3,
                  position: currentScreen.toDouble(),
                  decorator: DotsDecorator(
                    size: const Size.square(9.0),
                    activeSize: const Size(21.0, 9.0),
                    activeShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                    spacing: EdgeInsets.all(3),
                  ),
                ),
                Spacer(),
                if (currentScreen != 2)
                  MawaqitCircleButton(
                    icon: Localizations.localeOf(context).languageCode == 'ar'
                        ? MawaqitIcons.icon_arrow_left
                        : MawaqitIcons.icon_arrow_right,
                    focusNode: _nextButtonFocusNode,
                    color: Theme.of(context).primaryColor,
                    size: 21,
                    onPressed: () => setState(() => currentScreen++),
                  ),
              ],
            ),
          ),
        ),
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
