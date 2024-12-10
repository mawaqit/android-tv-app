import 'dart:async';

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
  final bool Function()? skip;
  late FocusNode skipButtonFocusNode;

  OnBoardingItem({
    required this.animation,
    this.widget,
    this.enableNextButton = false,
    this.enablePreviousButton = false,

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
  late FocusNode skipButtonFocusNode = FocusNode();
  late List<OnBoardingItem> onBoardingItems = [
    OnBoardingItem(
      animation: 'language',
      widget: OnBoardingLanguageSelector(),
      enableNextButton: true, // Enable next button for language selection
    ),
    OnBoardingItem(
        animation: 'welcome',
        widget: OnBoardingOrientationWidget.onboarding(), // remove onSelect parameter
        enableNextButton: true, // enable next button
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
        widget: OnBoardingScreenType.onboarding(),
        enableNextButton: true,
        skip: () => !context.read<MosqueManager>().typeIsMosque,
        enablePreviousButton: true),

    /// Allow user to select between regular mode or announcement mode
    OnBoardingItem(
      animation: 'search',
      widget: OnBoardingAnnouncementScreens(isOnboarding: true),
      skip: () => !context.read<MosqueManager>().typeIsMosque,
      enablePreviousButton: true,
      enableNextButton: true,
    ),
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
      widget: OnBoardingLanguageSelector(),
      enableNextButton: true, // Enable next button for language selection
    ),
    OnBoardingItem(
        animation: 'welcome',
        widget: OnBoardingOrientationWidget.onboarding(), // remove onSelect parameter
        enableNextButton: true, // enable next button
        enablePreviousButton: true),
    OnBoardingItem(
      animation: 'welcome',
      widget: OnBoardingMawaqitAboutWidget(onNext: () => nextPage(5)),
      enableNextButton: true,
      enablePreviousButton: true,
    ),
    OnBoardingItem(
        animation: 'settings',
        widget: OnBoardingTimeZoneSelector(onSelect: () => nextPage(2), focusNode: skipButtonFocusNode),
        enablePreviousButton: true,
        enableNextButton: true),
    OnBoardingItem(
        animation: 'settings',
        widget: OnBoardingWifiSelector(onSelect: () => nextPage(3), focusNode: skipButtonFocusNode),
        enablePreviousButton: true,
        enableNextButton: true),
    OnBoardingItem(
      animation: 'search',
      widget: MosqueSearch(onDone: () => nextPage(6)),
      enableNextButton: false,
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
      enableNextButton: true,
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
    final isLastItem =
        currentScreen == (_rootStatus ? kioskModeonBoardingItems.length - 1 : onBoardingItems.length - 1);

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
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
              child: Row(
                children: [
                  // Left side - Version Widget
                  Expanded(
                    flex: 2,
                    child: VersionWidget(
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyText1?.color?.withOpacity(.5),
                      ),
                    ),
                  ),
                  // Left spacer with specific flex
                  Expanded(flex: 1, child: SizedBox()),
                  // Center - Dots Indicator
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
                  // Right spacer with same flex as left
                  Expanded(flex: 1, child: SizedBox()),
                  // Right side - Navigation Buttons
                  // Right side - Navigation Buttons
                  Expanded(
                    flex: 2,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: Directionality.of(context) == TextDirection.ltr
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      children: [
                        // activePage.enablePreviousButton ? MawaqitBackIconButton(
                        //   icon: Icons.arrow_back_rounded,
                        //   label: S.of(context).previous,
                        //   onPressed: () => previousPage(currentScreen - 1),
                        // ) : SizedBox(width: 200,),
                        // if (activePage.enablePreviousButton)
                          Visibility(
                            visible: activePage.enablePreviousButton,
                            replacement: Opacity(
                              opacity: 0,
                              child: MawaqitBackIconButton(
                                icon: Icons.arrow_back_rounded,
                                label: S.of(context).previous,
                                onPressed: () => previousPage(currentScreen - 1),
                              ),
                            ),
                            child: MawaqitBackIconButton(
                              icon: Icons.arrow_back_rounded,
                              label: S.of(context).previous,
                              onPressed: () => previousPage(currentScreen - 1),
                            ),
                          ),
                        if (activePage.enablePreviousButton) SizedBox(width: 10),
                        if (activePage.enableNextButton)
                          MawaqitIconButton(
                            focusNode: ref.watch(nextNodeProvider),
                            icon: isLastItem ? Icons.check : Icons.arrow_forward_rounded,
                            label: isLastItem ? S.of(context).finish : S.of(context).next,
                            onPressed: () => nextPage(currentScreen + 1),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
      ),
    );
  }
}

final nextNodeProvider = riverpod.Provider.autoDispose<FocusNode>((ref) {
  final focusNode = FocusNode();
  ref.onDispose(() => focusNode.dispose());
  return focusNode;
});
