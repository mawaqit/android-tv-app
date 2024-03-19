import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:mawaqit/src/helpers/AppRouter.dart';
import 'package:mawaqit/src/helpers/SharedPref.dart';
import 'package:mawaqit/src/pages/home/OfflineHomeScreen.dart';
import 'package:mawaqit/src/pages/mosque_search/MosqueSearch.dart';
import 'package:mawaqit/src/pages/onBoarding/widgets/MawaqitAboutWidget.dart';
import 'package:mawaqit/src/pages/onBoarding/widgets/OrientationWidget.dart';
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
import '../../state_management/on_boarding/device_notifier.dart';
import '../../widgets/mawaqit_back_icon_button.dart';
import 'widgets/onboarding_screen_type.dart';

class OnBoardingItem {
  final String animation;
  final Widget? widget;
  final bool enableNextButton;
  final bool enablePreviousButton;
  final bool Function()? skip;

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

  late List<OnBoardingItem> onBoardingItems = [
    OnBoardingItem(
      animation: 'language',
      widget: OnBoardingLanguageSelector(onSelect: () => ref.read(boardingProvider.notifier).nextPage()),
    ),
    OnBoardingItem(
        animation: 'welcome',
        widget: OnBoardingOrientationWidget(onSelect: () => ref.read(boardingProvider.notifier).nextPage()),
        enablePreviousButton: true),
    OnBoardingItem(
      animation: 'welcome',
      widget: OnBoardingMawaqitAboutWidget(onNext: () => ref.read(boardingProvider.notifier).nextPage()),
      enableNextButton: true,
      enablePreviousButton: true,
    ),
    OnBoardingItem(
      animation: 'search',
      widget: MosqueSearch(onDone: () => ref.read(boardingProvider.notifier).nextPage()),
    ),

    /// main screen or secondary screen (if user has already selected a mosque)
    OnBoardingItem(
        animation: 'search',
        widget: OnBoardingScreenType(onDone: () => ref.read(boardingProvider.notifier).nextPage()),
        skip: () => !context.read<MosqueManager>().typeIsMosque,
        enablePreviousButton: true),

    /// Allow user to select between regular mode or announcement mode
    OnBoardingItem(
        animation: 'search',
        widget: OnBoardingAnnouncementScreens(onDone: () => ref.read(boardingProvider.notifier).nextPage()),
        skip: () => !context.read<MosqueManager>().typeIsMosque,
        enablePreviousButton: true),
  ];


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(deviceNotifier.notifier).getSystemLanguage();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentScreenIndex = ref.watch(boardingProvider.select((value) => value.value?.currentScreen)) ?? 0;
    final activePage = onBoardingItems[currentScreenIndex];
    final onBoardingState = ref.watch(deviceNotifier);
    final appLanguage = Provider.of<AppLanguage>(context, listen: false);

    final locales = S.supportedLocales;

    final sortedLocales = LocaleHelper.getSortedLocales(locales, appLanguage);

    ref.listen(deviceNotifier, (previous, next) {
      if (next.value?.language != previous!.value?.language) {
        next.whenOrNull(
          data: (state) async {
            if (state.language != 'unknown') {
              final locale = LocaleHelper.splitLocaleCode(state.language);
              if (sortedLocales.contains(locale)) {
                String language = locale.languageCode;
                ref.read(deviceNotifier.notifier).setLanguage(language, context);
              }
            }
          },
        );
      }
    });

    ref.listen(boardingProvider, (previous, next) {
      if (next.value?.isCompleted == true) {
          AppRouter.pushReplacement(OfflineHomeScreen());
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
    final currentScreenIndex = ref.watch(boardingProvider.select((value) => value.value?.currentScreen)) ?? 0;

    return WillPopScope(
      onWillPop: () async {
        if (currentScreenIndex == 0) return true;
        ref.read(boardingProvider.notifier).previousPage();
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
                  dotsCount: onBoardingItems.length,
                  position: currentScreenIndex,
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
                    onPressed: () => ref.read(boardingProvider.notifier).previousPage(),
                  ),
                if (activePage.enableNextButton)
                  MawaqitIconButton(
                    icon: Icons.arrow_forward_rounded,
                    label: S.of(context).next,
                    onPressed: () => ref.read(boardingProvider.notifier).nextPage(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
