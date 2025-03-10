import 'dart:async';

import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:fpdart/fpdart.dart';
import 'package:mawaqit/main.dart';
import 'package:mawaqit/src/data/countries.dart';
import 'package:mawaqit/src/helpers/Api.dart';
import 'package:mawaqit/src/helpers/AppRouter.dart';
import 'package:mawaqit/src/helpers/SharedPref.dart';
import 'package:mawaqit/src/pages/home/OfflineHomeScreen.dart';
import 'package:mawaqit/src/pages/mosque_search/MosqueSearch.dart';
import 'package:mawaqit/src/pages/mosque_search/widgets/InputTypeSelector.dart';
import 'package:mawaqit/src/pages/mosque_search/widgets/MosqueInputId.dart';
import 'package:mawaqit/src/pages/mosque_search/widgets/MosqueInputSearch.dart';
import 'package:mawaqit/src/pages/mosque_search/widgets/chromecast_mosque_input_id.dart';
import 'package:mawaqit/src/pages/mosque_search/widgets/chromecast_mosque_input_search.dart';
import 'package:mawaqit/src/pages/onBoarding/widgets/MawaqitAboutWidget.dart';
import 'package:mawaqit/src/pages/onBoarding/widgets/OrientationWidget.dart';
import 'package:mawaqit/src/pages/onBoarding/widgets/onboarding_timezone_selector.dart';
import 'package:mawaqit/src/pages/onBoarding/widgets/onboarding_announcement_mode.dart';
import 'package:mawaqit/src/pages/onBoarding/widgets/onboarding_language_selector.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:mawaqit/src/state_management/on_boarding/input_selection_provider.dart';
import 'package:mawaqit/src/state_management/on_boarding/v2/onboarding_navigation_notifier.dart';
import 'package:mawaqit/src/state_management/on_boarding/v2/onboarding_navigation_state.dart';
import 'package:mawaqit/src/widgets/InfoWidget.dart';
import 'package:mawaqit/src/widgets/ScreenWithAnimation.dart';
import 'package:mawaqit/src/widgets/mawaqit_icon_button.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

import '../../../i18n/AppLanguage.dart';
import '../../../i18n/l10n.dart';
import '../../helpers/LocaleHelper.dart';
import '../../state_management/on_boarding/on_boarding_notifier.dart';
import '../../widgets/mawaqit_back_icon_button.dart';
import 'widgets/onboarding_bottom_navigation_bar.dart';
import 'widgets/onboarding_country_selection_screen.dart';
import 'widgets/onboarding_time_zone_selection_screen.dart';
import 'widgets/wifi_selector_widget.dart';
import 'widgets/onboarding_screen_type.dart';

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
  String? _deviceModel;

  @override
  void initState() {
    super.initState();
    nextButtonFocusNode = FocusNode(debugLabel: 'next_button_focus_node');
    previousButtonFocusNode = FocusNode(debugLabel: 'previous_button_focus_node');
    skipButtonFocusNode = FocusNode(debugLabel: 'skip_button_focus_node');

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(onBoardingProvider.notifier).getSystemLanguage();
    });
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
    print('getScreenWidgets: $country');
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
        widget: OnBoardingScreenType.onboarding(),
        enableNextButton: true,
        enablePreviousButton: true,
        skip: () => !context.read<MosqueManager>().typeIsMosque,
      ),
      OnboardingScreenType.announcement: OnBoardingItem(
        animation: 'search',
        widget: OnBoardingAnnouncementScreens(isOnboarding: true),
        enableNextButton: true,
        enablePreviousButton: true,
        skip: () => !context.read<MosqueManager>().typeIsMosque,
      ),
      // Kiosk mode specific screens
      OnboardingScreenType.countrySelection: OnBoardingItem(
        animation: 'settings',
        widget: CountrySelectionScreen(
          onSelect: (countrySelected) {
            setState(() {
              country = Option.of(countrySelected);
            });
          },
          focusNode: skipButtonFocusNode,
          nextButtonFocusNode: nextButtonFocusNode,
        ),
        enableNextButton: true,
        enablePreviousButton: true,
      ),
      OnboardingScreenType.timezoneSelection: countryDependentItems,
      OnboardingScreenType.wifiSelection: OnBoardingItem(
        animation: 'settings',
        widget: OnBoardingWifiSelector(
          onSelect: () {},
          focusNode: skipButtonFocusNode,
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
      child: SafeArea(
        child: Scaffold(
          body: state.when(
            data: (data) {
              return PageView.builder(
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
              );
            },
            error: (e, s) => Container(),
            loading: () => Container(),
          ),
          bottomNavigationBar: OnboardingBottomNavigationBar(
            onPreviousPressed: () => ref.read(onboardingNavigationProvider.notifier).previousPage(),
            onNextPressed: () => ref.read(onboardingNavigationProvider.notifier).nextPage(context),
            nextButtonFocusNode: nextButtonFocusNode,
          ),
        ),
      ),
    );
  }
}
