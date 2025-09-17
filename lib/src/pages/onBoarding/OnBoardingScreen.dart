import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:fpdart/fpdart.dart';
import 'package:mawaqit/main.dart';
import 'package:mawaqit/src/data/countries.dart';
import 'package:mawaqit/src/helpers/AppRouter.dart';
import 'package:mawaqit/src/helpers/SharedPref.dart';
import 'package:mawaqit/src/pages/home/OfflineHomeScreen.dart';
import 'package:mawaqit/src/pages/mosque_search/MosqueSearch.dart';
import 'package:mawaqit/src/pages/mosque_search/widgets/widgets.dart';
import 'package:mawaqit/src/pages/onBoarding/widgets/widgets.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:mawaqit/src/state_management/on_boarding/on_boarding.dart';
import 'package:mawaqit/src/widgets/ScreenWithAnimation.dart';
import 'package:provider/provider.dart';

import '../../../i18n/AppLanguage.dart';
import '../../../i18n/l10n.dart';
import '../../helpers/LocaleHelper.dart';

class OnBoardingItem {
  final String animation;
  final Widget? widget;
  final bool enableNextButton;
  final bool enablePreviousButton;
  final bool Function()? skip;

  // final FocusNode nextButtonFocusNode;
  // final FocusNode previousButtonFocusNode;
  //
  late FocusNode skipButtonFocusNode;

  OnBoardingItem({
    required this.animation,
    // required this.nextButtonFocusNode,
    // required this.previousButtonFocusNode,
    this.widget,
    this.enableNextButton = false,
    this.enablePreviousButton = false,
    this.skip,
  });
}

class OnBoardingScreen extends riverpod.ConsumerStatefulWidget {
  const OnBoardingScreen({Key? key}) : super(key: key);

  @override
  _OnBoardingScreenState createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends riverpod.ConsumerState<OnBoardingScreen> {
  final sharedPref = SharedPref();
  final PageController pageController = PageController();
  int currentScreen = 0;
  late FocusNode skipButtonFocusNode;
  late FocusNode nextButtonFocusNode;
  late FocusNode previousButtonFocusNode;
  Option<Country> country = None();

  @override
  void initState() {
    super.initState();
    nextButtonFocusNode = FocusNode(debugLabel: 'next_button_focus_node');
    previousButtonFocusNode = FocusNode(debugLabel: 'previous_button_focus_node');
    skipButtonFocusNode = FocusNode(debugLabel: 'skip_button_focus_node');

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(onBoardingProvider.notifier).getSystemLanguage();
      // Load previously selected country
      await _loadSavedCountry();
    });
  }

  /// Load previously selected country from SharedPreferences
  Future<void> _loadSavedCountry() async {
    try {
      final savedCountry = await ref.read(onBoardingProvider.notifier).loadSelectedCountry();
      if (savedCountry != null && mounted) {
        setState(() {
          country = Option.of(savedCountry);
        });
      }
    } catch (e, stackTrace) {
      logger.e('Error loading saved country: $e', stackTrace: stackTrace);
    }
  }

  @override
  void dispose() {
    nextButtonFocusNode.dispose();
    previousButtonFocusNode.dispose();
    skipButtonFocusNode.dispose();

    super.dispose();
  }

  void onDone() {
    sharedPref.save('boarding', 'true');
    AppRouter.pushReplacement(OfflineHomeScreen());
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(onBoardingProvider.notifier).getSystemLanguage();
    });
  }

  Map<OnboardingScreenType, OnBoardingItem> getScreenWidgets(BuildContext context) {
    final countryDependentItems = country.match(
      () {
        return OnBoardingItem(
          animation: 'settings',
          widget: TimezoneSelectionScreen(
            country: Country.empty(),
            nextButtonFocusNode: nextButtonFocusNode,
          ),
          enablePreviousButton: true,
          enableNextButton: true,
        );
      },
      (selectedCountry) {
        return OnBoardingItem(
          animation: 'settings',
          widget: TimezoneSelectionScreen(
            country: selectedCountry,
            nextButtonFocusNode: nextButtonFocusNode,
          ),
          enablePreviousButton: true,
          enableNextButton: true,
        );
      },
    );

    return {
      OnboardingScreenType.language: OnBoardingItem(
        animation: 'language',
        widget: OnBoardingLanguageSelector(
          nextButtonFocusNode: nextButtonFocusNode,
        ),
        enableNextButton: true,
      ),
      OnboardingScreenType.orientation: OnBoardingItem(
        animation: 'welcome',
        widget: OnBoardingOrientationWidget.onboarding(
          previousButtonFocusNode: previousButtonFocusNode,
          nextButtonFocusNode: nextButtonFocusNode,
        ),
        enableNextButton: true,
        enablePreviousButton: true,
      ),
      OnboardingScreenType.about: OnBoardingItem(
        animation: 'welcome',
        widget: OnBoardingMawaqitAboutWidget(),
        enableNextButton: true,
        enablePreviousButton: true,
      ),
      OnboardingScreenType.mosqueSearchType: OnBoardingItem(
        animation: 'search',
        widget: MosqueSearch(
          nextButtonFocusNode: Some(nextButtonFocusNode),
          onDone: () {},
        ),
        enableNextButton: true,
        enablePreviousButton: true,
      ),
      OnboardingScreenType.mosqueId: OnBoardingItem(
        animation: 'search',
        widget: MosqueInputId(
          onDone: () {},
          selectedNode: Some(nextButtonFocusNode),
        ),
        enableNextButton: true,
        enablePreviousButton: true,
      ),
      OnboardingScreenType.mosqueName: OnBoardingItem(
        animation: 'search',
        widget: MosqueInputSearch(
          onDone: () {},
          selectedNode: Some(nextButtonFocusNode),
        ),
        enableNextButton: true,
        enablePreviousButton: true,
      ),
      OnboardingScreenType.chromecastMosqueId: OnBoardingItem(
        animation: 'search',
        widget: ChromeCastMosqueInputId(
          onDone: () {},
          selectedNode: Some(nextButtonFocusNode),
        ),
        enableNextButton: true,
        enablePreviousButton: true,
      ),
      OnboardingScreenType.chromecastMosqueName: OnBoardingItem(
        animation: 'search',
        widget: ChromeCastMosqueInputSearch(
          onDone: () {},
          selectedNode: Some(nextButtonFocusNode),
        ),
        enableNextButton: true,
        enablePreviousButton: true,
      ),
      OnboardingScreenType.screenType: OnBoardingItem(
        animation: 'search',
        widget: OnBoardingScreenType.onboarding(
          nextButtonFocusNode: nextButtonFocusNode,
        ),
        enableNextButton: true,
        enablePreviousButton: true,
        skip: () => !context.read<MosqueManager>().typeIsMosque,
      ),
      OnboardingScreenType.announcement: OnBoardingItem(
        animation: 'search',
        widget: OnBoardingAnnouncementScreens(
          isOnboarding: true,
          nextButtonFocusNode: Some(nextButtonFocusNode),
        ),
        enableNextButton: true,
        enablePreviousButton: true,
        skip: () => !context.read<MosqueManager>().typeIsMosque,
      ),
      // Kiosk mode specific screens
      OnboardingScreenType.countrySelection: OnBoardingItem(
        animation: 'settings',
        widget: CountrySelectionScreen(
          onSelect: (countrySelected) async {
            // Save the country through the notifier (this will also update the state)
            await ref.read(onBoardingProvider.notifier).saveSelectedCountry(countrySelected);
            setState(() {
              country = Option.of(countrySelected);
            });
          },
          nextButtonFocusNode: nextButtonFocusNode,
        ),
        enableNextButton: true,
        enablePreviousButton: true,
      ),
      OnboardingScreenType.timezoneSelection: countryDependentItems,
      OnboardingScreenType.wifiSelection: OnBoardingItem(
        animation: 'settings',
        widget: OnBoardingWifiSelector(
          onSelect: () => ref.read(onboardingNavigationProvider.notifier).nextPage(context),
          focusNode: nextButtonFocusNode,
        ),
        enableNextButton: true,
        enablePreviousButton: true,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final onBoardingState = ref.watch(onboardingNavigationProvider);
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

      // Listen for country changes
      if (next.value?.selectedCountry != previous?.value?.selectedCountry) {
        next.whenOrNull(
          data: (state) {
            if (state.selectedCountry != null) {
              setState(() {
                country = Option.of(state.selectedCountry!);
              });
            }
          },
        );
      }
    });

    return onBoardingState.when(
      data: (state) => buildPageView(context, state.isRooted),
      error: (error, stack) => buildPageView(context, false),
      loading: () => Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  // Helper method to determine if skip button should be shown
  bool _shouldShowSkipButton(OnboardingScreenType screenType) {
    return screenType == OnboardingScreenType.countrySelection || screenType == OnboardingScreenType.timezoneSelection;
  }

  Widget buildPageView(BuildContext context, bool isRooted) {
    final state = ref.watch(onboardingNavigationProvider);

    ref.listen<riverpod.AsyncValue<OnboardingNavigationState>>(
      onboardingNavigationProvider,
      (previous, next) {
        next.whenData((state) {
          if (state.currentScreen != currentScreen && pageController.hasClients) {
            pageController.jumpToPage(state.currentScreen);
            setState(() {
              currentScreen = state.currentScreen;
            });
          }
        });
      },
    );

    return WillPopScope(
      onWillPop: () async {
        if (currentScreen == 0) return true;
        ref.read(onboardingNavigationProvider.notifier).previousPage();
        return false;
      },
      child: state.when(
        data: (data) {
          return SafeArea(
            child: FocusTraversalGroup(
              policy: ReadingOrderTraversalPolicy(),
              child: Scaffold(
                body: PageView.builder(
                  controller: pageController,
                  itemCount: data.screenFlow.length,
                  physics: NeverScrollableScrollPhysics(),
                  onPageChanged: (index) {
                    setState(() {
                      currentScreen = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final screenType = data.screenFlow[index];
                    final allScreens = getScreenWidgets(context);

                    return ScreenWithAnimationWidget(
                      animation: allScreens[screenType]?.animation ?? '',
                      child: allScreens[screenType]!.widget ?? Container(),
                    );
                  },
                ),
                bottomNavigationBar: FocusScope(
                  onKeyEvent: (FocusNode node, KeyEvent event) {
                    if (event is KeyDownEvent) {
                      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                        final screenType = data.screenFlow[currentScreen];

                        if (screenType == OnboardingScreenType.about) {
                          return KeyEventResult.ignored;
                        }

                        FocusScope.of(context).focusInDirection(TraversalDirection.up);
                        return KeyEventResult.handled;
                      }
                    }
                    return KeyEventResult.ignored;
                  },
                  child: OnboardingBottomNavigationBar(
                    onPreviousPressed: () => ref.read(onboardingNavigationProvider.notifier).previousPage(),
                    onNextPressed: () => ref.read(onboardingNavigationProvider.notifier).nextPage(context),
                    nextButtonFocusNode: nextButtonFocusNode,
                    onSkipPressed: _shouldShowSkipButton(data.screenFlow[data.currentScreen]) && country.isNone()
                        ? () => ref.read(onboardingNavigationProvider.notifier).skipCountryAndTimezoneScreens(context)
                        : null,
                  ),
                ),
              ),
            ),
          );
        },
        error: (e, s) => Container(),
        loading: () => Container(),
      ),
    );
  }
}
