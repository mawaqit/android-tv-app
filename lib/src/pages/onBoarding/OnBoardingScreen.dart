import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:mawaqit/src/helpers/AppRouter.dart';
import 'package:mawaqit/src/helpers/SharedPref.dart';
import 'package:mawaqit/src/pages/home/OfflineHomeScreen.dart';
import 'package:mawaqit/src/pages/mosque_search/MosqueSearch.dart';
import 'package:mawaqit/src/pages/onBoarding/widgets/MawaqitAboutWidget.dart';
import 'package:mawaqit/src/pages/onBoarding/widgets/OrientationWidget.dart';
import 'package:mawaqit/src/pages/onBoarding/widgets/onboarding_timezone_selector.dart';
import 'package:mawaqit/src/pages/onBoarding/widgets/onboarding_announcement_mode.dart';
import 'package:mawaqit/src/pages/onBoarding/widgets/onboarding_language_selector.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:mawaqit/src/widgets/InfoWidget.dart';
import 'package:mawaqit/src/widgets/ScreenWithAnimation.dart';
import 'package:mawaqit/src/widgets/mawaqit_icon_button.dart';
import 'package:provider/provider.dart';

import '../../../i18n/AppLanguage.dart';
import '../../../i18n/l10n.dart';
import '../../helpers/LocaleHelper.dart';
import '../../state_management/on_boarding/on_boarding_notifier.dart';
import '../../widgets/mawaqit_back_icon_button.dart';
import 'widgets/wifi_selector_widget.dart';
import 'widgets/onboarding_screen_type.dart';

class OnBoardingItem {
  final String animation;
  final Widget? widget;
  final bool enableNextButton;
  final bool enablePreviousButton;
  final bool skipPage;
  final bool Function()? skip;

  OnBoardingItem({
    required this.animation,
    this.widget,
    this.enableNextButton = false,
    this.enablePreviousButton = false,
    this.skipPage = false,

    /// if item is skipped, it will be marked as done
    this.skip,
  });
}

class OnBoardingScreen extends riverpod.ConsumerStatefulWidget {
  const OnBoardingScreen();

  @override
  _OnBoardingScreenState createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends riverpod.ConsumerState<OnBoardingScreen> {
  final sharedPref = SharedPref();
  int currentScreen = 0;
  bool _rootStatus = false;

  late List<OnBoardingItem> onBoardingItems = [
    OnBoardingItem(
      animation: 'language',
      widget: OnBoardingLanguageSelector(onSelect: () => nextPage(1)),
    ),
    OnBoardingItem(
        animation: 'welcome',
        widget: OnBoardingOrientationWidget(onSelect: () => nextPage(2)),
        enablePreviousButton: true),
    OnBoardingItem(
      animation: 'welcome',
      widget: OnBoardingMawaqitAboutWidget(onNext: () => nextPage(3)),
      enableNextButton: true,
      enablePreviousButton: true,
    ),
    OnBoardingItem(
      animation: 'search',
      widget: MosqueSearch(onDone: () => nextPage(4)),
    ),

    /// main screen or secondary screen (if user has already selected a mosque)
    OnBoardingItem(
        animation: 'search',
        widget: OnBoardingScreenType(onDone: () => nextPage(5)),
        skip: () => !context.read<MosqueManager>().typeIsMosque,
        enablePreviousButton: true),

    /// Allow user to select between regular mode or announcement mode
    OnBoardingItem(
        animation: 'search',
        widget: OnBoardingAnnouncementScreens(onDone: () => nextPage(6)),
        skip: () => !context.read<MosqueManager>().typeIsMosque,
        enablePreviousButton: true),
  ];

  onDone() {
    sharedPref.save('boarding', 'true');
    AppRouter.pushReplacement(OfflineHomeScreen());
  }

  nextPage(int nextScreen) {
    while (true) {
      /// this is the last screen
      if (_rootStatus) {
        if (nextScreen >= kioskModeonBoardingItems.length) return onDone();

        currentScreen++;
        // if false or null, don't skip this screen
        if (kioskModeonBoardingItems[currentScreen].skip?.call() != true) break;
      } else {
        if (nextScreen >= onBoardingItems.length) return onDone();

        currentScreen++;
        // if false or null, don't skip this screen
        if (onBoardingItems[currentScreen].skip?.call() != true) break;
      }
    }

    setState(() {});
  }

  previousPage(int previousScreen) {
    while (true) {
      if (_rootStatus) {
        currentScreen = previousScreen;
        // if false or null, don't skip this screen
        if (kioskModeonBoardingItems[currentScreen].skip?.call() != true) break;

        previousScreen--;
      } else {
        currentScreen = previousScreen;
        // if false or null, don't skip this screen
        if (onBoardingItems[currentScreen].skip?.call() != true) break;

        previousScreen--;
      }
    }

    setState(() {});
  }

  late final kioskModeonBoardingItems = [
    OnBoardingItem(
      animation: 'language',
      widget: OnBoardingLanguageSelector(onSelect: () => nextPage(1)),
    ),
    OnBoardingItem(
        animation: 'settings',
        widget: OnBoardingTimeZoneSelector(onSelect: () => nextPage(2)),
        enablePreviousButton: true,
        skipPage: true),
    OnBoardingItem(
        animation: 'settings',
        widget: OnBoardingWifiSelector(onSelect: () => nextPage(3)),
        enablePreviousButton: true,
        skipPage: true),
    OnBoardingItem(
        animation: 'welcome',
        widget: OnBoardingOrientationWidget(onSelect: () => nextPage(4)),
        enablePreviousButton: true),
    OnBoardingItem(
      animation: 'welcome',
      widget: OnBoardingMawaqitAboutWidget(onNext: () => nextPage(5)),
      enableNextButton: true,
      enablePreviousButton: true,
    ),
    OnBoardingItem(
      animation: 'search',
      widget: MosqueSearch(onDone: () => nextPage(6)),
      enableNextButton: false,
    ),

    /// main screen or secondary screen (if user has already selected a mosque)
    OnBoardingItem(
      animation: 'search',
      widget: OnBoardingScreenType(onDone: () => nextPage(7)),
      enableNextButton: false,
      skip: () => !context.read<MosqueManager>().typeIsMosque,
    ),

    /// Allow user to select between regular mode or announcement mode
    OnBoardingItem(
      animation: 'search',
      widget: OnBoardingAnnouncementScreens(onDone: () => nextPage(8)),
      enablePreviousButton: true,
      skip: () => !context.read<MosqueManager>().typeIsMosque,
    ),
  ];
  static Future<bool> checkRoot() async {
    try {
      final result = await MethodChannel('nativeMethodsChannel').invokeMethod('checkRoot');
      return result;
    } catch (e) {
      print('Error checking root access: $e');
      return false;
    }
  }

  Future<void> initRootRequest() async {
    bool rootStatus = await checkRoot();
    setState(() {
      _rootStatus = rootStatus;
    });
  }

  @override
  void initState() {
    initRootRequest();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(onBoardingProvider.notifier).getSystemLanguage();
    });
  }

  @override
  Widget build(BuildContext context) {
    final activePage = _rootStatus ? kioskModeonBoardingItems[currentScreen] : onBoardingItems[currentScreen];
    final onBoardingState = ref.watch(onBoardingProvider);
    final appLanguage = Provider.of<AppLanguage>(context, listen: false);

    final locales = S.supportedLocales;

    final sortedLocales = LocaleHelper.getSortedLocales(locales, appLanguage);

    ref.listen(onBoardingProvider, (previous, next) {
      if (next.value?.language != previous!.value?.language) {
        next.whenOrNull(
          data: (state) async {
            if (state.language != 'unknown') {
              final locale = LocaleHelper.splitLocaleCode(state.language);
              if (sortedLocales.contains(locale)) {
                String language = locale.languageCode;
                ref.read(onBoardingProvider.notifier).setLanguage(language, context);
              }
            }
          },
        );
      }
    });

    return onBoardingState.when(
      data: (state) {
        return buildWillPopScope(activePage, context);
      },
      error: (error, stack) => buildWillPopScope(activePage, context),
      loading: () => Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  WillPopScope buildWillPopScope(OnBoardingItem activePage, BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (currentScreen == 0) return true;

        setState(() => currentScreen--);
        return false;
      },
      child: SafeArea(
        child: Scaffold(
          body: ScreenWithAnimationWidget(
            animation: activePage.animation,
            child: activePage.widget ?? SizedBox(),
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
                  dotsCount: _rootStatus ? kioskModeonBoardingItems.length : onBoardingItems.length,
                  position: currentScreen,
                  decorator: DotsDecorator(
                    size: const Size.square(9.0),
                    activeSize: const Size(21.0, 9.0),
                    activeShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                    spacing: EdgeInsets.all(3),
                  ),
                ),
                Spacer(),
                if (activePage.enablePreviousButton)
                  MawaqitBackIconButton(
                    icon: Icons.arrow_back_rounded,
                    label: S.of(context).previous,
                    onPressed: () => previousPage(currentScreen - 1),
                  ),
                if (activePage.enableNextButton)
                  MawaqitIconButton(
                    icon: Icons.arrow_forward_rounded,
                    label: S.of(context).next,
                    onPressed: () => nextPage(currentScreen + 1),
                  ),
                if (activePage.skipPage)
                  MawaqitIconButton(
                    icon: Icons.arrow_forward_rounded,
                    label: S.of(context).skip,
                    onPressed: () => nextPage(currentScreen + 1),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
