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
  late FocusNode skipButtonFocusNode;

  OnBoardingItem({
    required this.animation,
    this.widget,
    this.enableNextButton = false,
    this.enablePreviousButton = false,
    this.skipPage = false,
    this.skip,
  }) {
    print('Creating OnBoardingItem with animation: $animation');
    skipButtonFocusNode = FocusNode();
  }
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
  late FocusNode skipButtonFocusNode = FocusNode();

  @override
  void initState() {
    print('Initializing OnBoardingScreen');
    initRootRequest();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      print('Getting system language');
      await ref.read(onBoardingProvider.notifier).getSystemLanguage();
    });
  }

  late List<OnBoardingItem> onBoardingItems = [
    OnBoardingItem(
      animation: 'language',
      widget: OnBoardingLanguageSelector(onSelect: () {
        print('Language selector selected');
        return nextPage(1);
      }),
    ),
    OnBoardingItem(
        animation: 'welcome',
        widget: OnBoardingOrientationWidget(onSelect: () {
          print('Orientation widget selected');
          return nextPage(2);
        }),
        enablePreviousButton: true),
    OnBoardingItem(
      animation: 'welcome',
      widget: OnBoardingMawaqitAboutWidget(onNext: () {
        print('About widget next pressed');
        return nextPage(3);
      }),
      enableNextButton: true,
      enablePreviousButton: true,
    ),
    OnBoardingItem(
      animation: 'search',
      widget: MosqueSearch(onDone: () {
        print('Mosque search done');
        return nextPage(4);
      }),
    ),
    OnBoardingItem(
        animation: 'search',
        widget: OnBoardingScreenType(onDone: () {
          print('Screen type selected');
          return nextPage(5);
        }),
        skip: () {
          final isMosque = !context.read<MosqueManager>().typeIsMosque;
          print('Checking if mosque type should be skipped: $isMosque');
          return isMosque;
        },
        enablePreviousButton: true),
    OnBoardingItem(
        animation: 'search',
        widget: OnBoardingAnnouncementScreens(onDone: () {
          print('Announcement mode selected');
          return nextPage(6);
        }),
        skip: () {
          final isMosque = !context.read<MosqueManager>().typeIsMosque;
          print('Checking if announcement should be skipped: $isMosque');
          return isMosque;
        },
        enablePreviousButton: true),
  ];

  late final kioskModeonBoardingItems = [
    OnBoardingItem(
      animation: 'language',
      widget: OnBoardingLanguageSelector(onSelect: () {
        print('Kiosk mode: Language selector selected');
        return nextPage(1);
      }),
    ),
    OnBoardingItem(
        animation: 'settings',
        widget: OnBoardingTimeZoneSelector(
            onSelect: () {
              print('Kiosk mode: Timezone selected');
              return nextPage(2);
            },
            focusNode: skipButtonFocusNode),
        enablePreviousButton: true,
        skipPage: true),
    OnBoardingItem(
        animation: 'settings',
        widget: OnBoardingWifiSelector(
            onSelect: () {
              print('Kiosk mode: Wifi selected');
              return nextPage(3);
            },
            focusNode: skipButtonFocusNode),
        enablePreviousButton: true,
        skipPage: true),
    // ... rest of kioskModeonBoardingItems
  ];

  onDone() {
    print('OnBoarding completed');
    sharedPref.save('boarding', 'true');
    AppRouter.pushReplacement(OfflineHomeScreen());
  }

  nextPage(int nextScreen) {
    print('Attempting to move to next screen: $nextScreen');
    while (true) {
      if (_rootStatus) {
        if (nextScreen >= kioskModeonBoardingItems.length) {
          print('Reached end of kiosk mode screens');
          return onDone();
        }

        currentScreen++;
        print('Moved to kiosk mode screen: $currentScreen');
        if (kioskModeonBoardingItems[currentScreen].skip?.call() != true) break;
      } else {
        if (nextScreen >= onBoardingItems.length) {
          print('Reached end of regular screens');
          return onDone();
        }

        currentScreen++;
        print('Moved to regular screen: $currentScreen');
        if (onBoardingItems[currentScreen].skip?.call() != true) break;
      }
    }

    setState(() {});
  }

  previousPage(int previousScreen) {
    print('Moving to previous screen: $previousScreen');
    while (true) {
      if (_rootStatus) {
        currentScreen = previousScreen;
        if (kioskModeonBoardingItems[currentScreen].skip?.call() != true) break;
        previousScreen--;
      } else {
        currentScreen = previousScreen;
        if (onBoardingItems[currentScreen].skip?.call() != true) break;
        previousScreen--;
      }
    }

    setState(() {});
  }

  static Future<bool> checkRoot() async {
    try {
      print('Checking root access');
      final result = await MethodChannel('nativeMethodsChannel').invokeMethod('checkRoot');
      print('Root access result: $result');
      return result;
    } catch (e) {
      print('Error checking root access: $e');
      return false;
    }
  }

  Future<void> initRootRequest() async {
    print('Initializing root request');
    bool rootStatus = await checkRoot();
    setState(() {
      _rootStatus = rootStatus;
      print('Root status set to: $_rootStatus');
    });
  }

  @override
  Widget build(BuildContext context) {
    print('Building OnBoardingScreen');
    final activePage = _rootStatus ? kioskModeonBoardingItems[currentScreen] : onBoardingItems[currentScreen];
    final onBoardingState = ref.watch(onBoardingProvider);
    final appLanguage = Provider.of<AppLanguage>(context, listen: false);

    final locales = S.supportedLocales;
    final sortedLocales = LocaleHelper.getSortedLocales(locales, appLanguage);

    print('Current screen: $currentScreen');
    print('Root status: $_rootStatus');
    print('Active page animation: ${activePage.animation}');

    ref.listen(onBoardingProvider, (previous, next) {
      print('OnBoarding provider changed');
      if (next.value?.language != previous!.value?.language) {
        next.whenOrNull(
          data: (state) async {
            print('Language state changed: ${state.language}');
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
        print('OnBoarding state has data');
        return buildWillPopScope(activePage, context);
      },
      error: (error, stack) {
        print('OnBoarding state has error: $error');
        return buildWillPopScope(activePage, context);
      },
      loading: () {
        print('OnBoarding state is loading');
        return Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  WillPopScope buildWillPopScope(OnBoardingItem activePage, BuildContext context) {
    print('Building WillPopScope with active page');
    return WillPopScope(
      onWillPop: () async {
        print('WillPopScope triggered');
        if (currentScreen == 0) return true;
        setState(() => currentScreen--);
        return false;
      },
      child: SafeArea(
        child: Scaffold(
          body: Builder(
            builder: (context) {
              print('Building ScreenWithAnimationWidget');
              return ScreenWithAnimationWidget(
                animation: activePage.animation,
                child: activePage.widget ?? SizedBox(),
              );
            },
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
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
                    focusNode: skipButtonFocusNode,
                    icon: Icons.arrow_forward_rounded,
                    label: S.of(context).next,
                    onPressed: () => nextPage(currentScreen + 1),
                  ),
                if (activePage.skipPage)
                  MawaqitIconButton(
                    focusNode: skipButtonFocusNode,
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
