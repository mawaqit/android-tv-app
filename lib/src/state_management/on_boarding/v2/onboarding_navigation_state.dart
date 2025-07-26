import 'package:flutter/widgets.dart';

enum OnboardingScreenType {
  language,
  orientation,
  about,
  countrySelection,
  timezoneSelection,
  wifiSelection,
  mosqueSearchType,
  chooseMosqueOrHomeScreen,
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
  final OnboardingFlowType flowType;

  const OnboardingNavigationState({
    required this.isRooted,
    required this.screenFlow,
    required this.flowType,
    this.currentScreen = 0,
    this.enablePreviousButton = false,
    this.enableNextButton = true,
    this.isLastItem = false,
  });

  int get totalScreens => screenFlow.length;

  OnboardingScreenType get currentScreenType => screenFlow[currentScreen];

  /// Computed properties for UI logic
  bool get isMosqueSearchScreen => switch (currentScreenType) {
    OnboardingScreenType.mosqueId || OnboardingScreenType.mosqueName => true,
    OnboardingScreenType.chromecastMosqueId || OnboardingScreenType.chromecastMosqueName => true,
    _ => false
  };

  bool get canSkipCurrentScreen => switch (currentScreenType) {
    OnboardingScreenType.countrySelection || OnboardingScreenType.timezoneSelection => true,
    _ => false
  };

  bool shouldShowFinishButton(bool isMosqueSelected) {
    final isAtLastScreen = currentScreen == screenFlow.length - 1;
    
    return switch (currentScreenType) {
      OnboardingScreenType.announcement when isAtLastScreen => true,
      OnboardingScreenType.mosqueId || OnboardingScreenType.chromecastMosqueId 
        when isMosqueSelected && isAtLastScreen => true,
      _ => false,
    };
  }

  OnboardingNavigationState copyWith({
    int? currentScreen,
    bool? enablePreviousButton,
    bool? enableNextButton,
    bool? isLastItem,
    bool? isRooted,
    List<OnboardingScreenType>? screenFlow,
    OnboardingFlowType? flowType,
  }) {
    return OnboardingNavigationState(
      currentScreen: currentScreen ?? this.currentScreen,
      enablePreviousButton: enablePreviousButton ?? this.enablePreviousButton,
      enableNextButton: enableNextButton ?? this.enableNextButton,
      isLastItem: isLastItem ?? this.isLastItem,
      isRooted: isRooted ?? this.isRooted,
      screenFlow: screenFlow ?? this.screenFlow,
      flowType: flowType ?? this.flowType,
    );
  }

  @override
  String toString() {
    return 'OnboardingNavigationState(currentScreen: $currentScreen, enablePreviousButton: $enablePreviousButton, enableNextButton: $enableNextButton, isLastItem: $isLastItem, isRooted: $isRooted, screenFlow: $screenFlow, flowType: $flowType)';
  }
}

enum OnboardingFlowType {
  main,
  kiosk,
  mosque,
  home,
}
