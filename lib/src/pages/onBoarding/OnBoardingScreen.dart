import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mawaqit/src/helpers/AppRouter.dart';
import 'package:mawaqit/src/helpers/SharedPref.dart';
import 'package:mawaqit/src/pages/home/OfflineHomeScreen.dart';
import 'package:mawaqit/src/pages/mosque_search/MosqueSearch.dart';
import 'package:mawaqit/src/pages/onBoarding/widgets/LanuageSelectorWidget.dart';
import 'package:mawaqit/src/pages/onBoarding/widgets/MawaqitAboutWidget.dart';
import 'package:mawaqit/src/pages/onBoarding/widgets/onboarding_announcement_mode.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:mawaqit/src/widgets/InfoWidget.dart';
import 'package:mawaqit/src/widgets/mawaqit_icon_button.dart';
import 'package:provider/provider.dart';

import '../../../i18n/l10n.dart';
import 'widgets/onboarding_screen_type.dart';

class OnBoardingItem {
  final String animation;
  final Widget? widget;
  final bool enableNextButton;
  final bool Function()? skip;

  OnBoardingItem({
    required this.animation,
    this.widget,
    this.enableNextButton = true,

    /// if item is skipped, it will be marked as done
    this.skip,
  });
}

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen();

  @override
  _OnBoardingScreenState createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final sharedPref = SharedPref();
  int currentScreen = 0;

  onDone() {
    sharedPref.save('boarding', 'true');
    AppRouter.pushReplacement(OfflineHomeScreen());
  }

  nextPage() {
    while (true) {
      /// this is the last screen
      if (currentScreen == onBoardingItems.length - 1) return onDone();

      currentScreen++;
      // if false or null, don't skip this screen
      if (onBoardingItems[currentScreen].skip?.call() != true) break;
    }

    setState(() {});
  }

  late final onBoardingItems = [
    OnBoardingItem(
      animation: 'language',
      widget: OnBoardingLanguageSelector(onSelect: nextPage),
    ),
    OnBoardingItem(
      animation: 'welcome',
      widget: OnBoardingMawaqitAboutWidget(onNext: nextPage),
    ),
    OnBoardingItem(
      animation: 'search',
      widget: MosqueSearch(onDone: nextPage),
      enableNextButton: false,
    ),

    /// main screen or secondary screen (if user has already selected a mosque)
    OnBoardingItem(
      animation: 'search',
      widget: OnBoardingScreenType(onDone: nextPage),
      enableNextButton: false,
      skip: () => !context.read<MosqueManager>().typeIsMosque,
    ),

    /// Allow user to select between regular mode or announcement mode
    OnBoardingItem(
      animation: 'search',
      widget: OnBoardingAnnouncementScreens(onDone: nextPage),
      enableNextButton: false,
      skip: () => !context.read<MosqueManager>().typeIsMosque,
    ),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final activePage = onBoardingItems[currentScreen];

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
                child: _buildImage(activePage.animation),
              ),
              Expanded(
                flex: 6,
                child: activePage.widget ?? SizedBox(),
              ),
            ],
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            // height: 80,
            child: Row(
              children: [
                VersionWidget(
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyText1?.color?.withOpacity(.5),
                  ),
                ),
                Spacer(flex: 2),
                DotsIndicator(
                  dotsCount: onBoardingItems.length,
                  position: currentScreen,
                  decorator: DotsDecorator(
                    size: const Size.square(9.0),
                    activeSize: const Size(21.0, 9.0),
                    activeShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                    spacing: EdgeInsets.all(3),
                  ),
                ),
                Spacer(),
                if (activePage.enableNextButton)
                  MawaqitIconButton(
                    icon: Icons.arrow_forward_rounded,
                    label: S.of(context).next,
                    onPressed: nextPage,
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
