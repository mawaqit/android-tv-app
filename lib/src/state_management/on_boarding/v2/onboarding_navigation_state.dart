import 'package:flutter/widgets.dart';



enum OnboardingScreenType {
  language,
  orientation,
  about,
  countrySelection,
  timezoneSelection,
  wifiSelection,
  mosqueSearchType,
  screenType,
  announcement,
  mosqueId,
  mosqueName,
  chromecastMosqueId,
  chromecastMosqueName,
}

class OnboardingNavigationState {
  final int currentScreen;
  final bool enablePreviousButton;
  final bool enableNextButton;
  final bool isLastItem;
  final bool isRooted;
  final List<OnboardingScreenType> screenFlow;

  const OnboardingNavigationState({
    required this.isRooted,
    required this.screenFlow,
    this.currentScreen = 0,
    this.enablePreviousButton = false,
    this.enableNextButton = false,
    this.isLastItem = false,
  });

  OnboardingNavigationState copyWith({
    int? currentScreen,
    int? totalScreens,
    bool? enablePreviousButton,
    bool? enableNextButton,
    bool? isLastItem,
    bool? isRooted,
    List<OnboardingScreenType>? screenFlow,
  }) {
    return OnboardingNavigationState(
      currentScreen: currentScreen ?? this.currentScreen,
      enablePreviousButton: enablePreviousButton ?? this.enablePreviousButton,
      enableNextButton: enableNextButton ?? this.enableNextButton,
      isLastItem: isLastItem ?? this.isLastItem,
      isRooted: isRooted ?? this.isRooted,
      screenFlow: screenFlow ?? this.screenFlow,
    );
  }

  @override
  String toString() {
    return 'BottomNavigationState(currentScreen: $currentScreen, enablePreviousButton: $enablePreviousButton, '
        'enableNextButton: $enableNextButton, isLastItem: $isLastItem'
        'isRooted: $isRooted, screenFlow: $screenFlow)';
  }
}
