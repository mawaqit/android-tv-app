import 'dart:async';

import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:fpdart/fpdart.dart';
import 'package:mawaqit/src/data/countries.dart';
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
import 'package:mawaqit/src/state_management/on_boarding/v2/onboarding_navigation_notifier.dart';
import 'package:mawaqit/src/widgets/InfoWidget.dart';
import 'package:mawaqit/src/widgets/ScreenWithAnimation.dart';
import 'package:mawaqit/src/widgets/mawaqit_icon_button.dart';
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
  int currentScreen = 0;
  bool _rootStatus = false;
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
    });
  }

  List<OnBoardingItem> get kioskModeonBoardingItems {
    final baseItems = [
      OnBoardingItem(
        animation: 'language',
        widget: OnBoardingLanguageSelector(
          nextButtonFocusNode: nextButtonFocusNode,
        ),
        enableNextButton: true,
      ),
      OnBoardingItem(
        animation: 'welcome',
        widget: OnBoardingOrientationWidget.onboarding(
          nextButtonFocusNode: nextButtonFocusNode,
          previousButtonFocusNode: previousButtonFocusNode,
        ),
        enableNextButton: true,
        enablePreviousButton: true,
      ),
      OnBoardingItem(
        animation: 'welcome',
        widget: OnBoardingMawaqitAboutWidget(onNext: () {}),
        enableNextButton: true,
        enablePreviousButton: true,
      ),
      OnBoardingItem(
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
        enablePreviousButton: true,
        enableNextButton: true,
      ),
    ];

    final countryDependentItems = country.match(
      () {
        return <OnBoardingItem>[];
      },
      (selectedCountry) {
        return [
          OnBoardingItem(
            animation: 'settings',
            widget: TimezoneSelectionScreen(
              country: selectedCountry,
              nextButtonFocusNode: nextButtonFocusNode,
            ),
            enablePreviousButton: true,
            enableNextButton: true,
          ),
        ];
      },
    );

    final remainingItems = [
      OnBoardingItem(
        animation: 'settings',
        widget: OnBoardingWifiSelector(onSelect: () {}, focusNode: skipButtonFocusNode),
        enablePreviousButton: true,
        enableNextButton: true,
      ),
      OnBoardingItem(
        animation: 'search',
        widget: MosqueSearch(
          nextButtonFocusNode: Some(nextButtonFocusNode),
          onDone: () {},
        ),
        enableNextButton: true,
        enablePreviousButton: true,
      ),
      OnBoardingItem(
        animation: 'search',
        widget: OnBoardingScreenType.onboarding(),
        enableNextButton: true,
        enablePreviousButton: true,
        skip: () => !context.read<MosqueManager>().typeIsMosque,
      ),
      OnBoardingItem(
        animation: 'search',
        widget: OnBoardingAnnouncementScreens(isOnboarding: true),
        enableNextButton: true,
        enablePreviousButton: true,
        skip: () => !context.read<MosqueManager>().typeIsMosque,
      ),
    ];

    return [...baseItems, ...countryDependentItems, ...remainingItems];
  }

  late final List<OnBoardingItem> onBoardingItems = [
    OnBoardingItem(
      animation: 'language',
      widget: OnBoardingLanguageSelector(
        nextButtonFocusNode: nextButtonFocusNode,
      ),
      enableNextButton: true,
      // Enable next button for language selection
    ),
    OnBoardingItem(
      animation: 'welcome',
      widget: OnBoardingOrientationWidget.onboarding(
        previousButtonFocusNode: previousButtonFocusNode,
        nextButtonFocusNode: nextButtonFocusNode,
      ),
      // removed onSelect parameter
      enableNextButton: true,
      // enable next button
      enablePreviousButton: true,
    ),
    OnBoardingItem(
      animation: 'welcome',
      widget: OnBoardingMawaqitAboutWidget(),
      enableNextButton: true,
      enablePreviousButton: true,
    ),
    OnBoardingItem(
      animation: 'search',
      widget: MosqueSearch(
        nextButtonFocusNode: Some(nextButtonFocusNode),
        onDone: () {},
      ),
      enableNextButton: true,
      enablePreviousButton: true,
    ),

    /// main screen or secondary screen (if user has already selected a mosque)
    OnBoardingItem(
      animation: 'search',
      widget: OnBoardingScreenType.onboarding(),
      enableNextButton: true,
      enablePreviousButton: true,
      skip: () => !context.read<MosqueManager>().typeIsMosque,
    ),

    /// Allow user to select between regular mode or announcement mode
    OnBoardingItem(
      animation: 'search',
      widget: OnBoardingAnnouncementScreens(isOnboarding: true),
      skip: () => !context.read<MosqueManager>().typeIsMosque,
      enablePreviousButton: true,
      enableNextButton: true,
    ),
  ];

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

  @override
  Widget build(BuildContext context) {
    final items = _rootStatus ? kioskModeonBoardingItems : onBoardingItems;
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
      data: (state) => buildPageView(context),
      error: (error, stack) => buildPageView(context),
      loading: () => Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget buildPageView(BuildContext context) {
    final items = !_rootStatus ? kioskModeonBoardingItems : onBoardingItems;
    final isLastItem = currentScreen == items.length - 1;
    final state = ref.watch(onboardingNavigationProvider);

    return WillPopScope(
      onWillPop: () async {
        if (currentScreen == 0) return true;
        ref.read(onboardingNavigationProvider.notifier).previousPage();
        return false;
      },
      child: SafeArea(
        child: Scaffold(
          body: state.when(
            data: (data) => PageView.builder(
              controller: data.pageController,
              itemCount: items.length,
              physics: NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                setState(() {
                  currentScreen = index;
                });
              },
              itemBuilder: (context, index) {
                final activePage = items[index];
                return ScreenWithAnimationWidget(
                  animation: activePage.animation,
                  child: activePage.widget ?? SizedBox(),
                );
              },
            ),
            error: (e, s) => Container(),
            loading: () => Container(),
          ),
          bottomNavigationBar: OnboardingBottomNavigationBar(
            onPreviousPressed: () => ref.read(onboardingNavigationProvider.notifier).previousPage(),
            onNextPressed: () => ref.read(onboardingNavigationProvider.notifier).nextPage(),
            nextButtonFocusNode: nextButtonFocusNode,
          ),
        ),
      ),
    );
  }
}
