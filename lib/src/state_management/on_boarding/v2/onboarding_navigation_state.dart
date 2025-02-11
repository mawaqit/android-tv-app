import 'package:flutter/widgets.dart';

class OnboardingNavigationState {
  final int currentScreen;
  final int totalScreens;
  final bool enablePreviousButton;
  final bool enableNextButton;
  final bool isLastItem;
  final bool isRooted;
  final PageController pageController;

  const OnboardingNavigationState({
    required this.isRooted,
    required this.pageController,
    this.currentScreen = 0,
    this.totalScreens = 0,
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
    PageController? pageController,
  }) {
    return OnboardingNavigationState(
      currentScreen: currentScreen ?? this.currentScreen,
      totalScreens: totalScreens ?? this.totalScreens,
      enablePreviousButton: enablePreviousButton ?? this.enablePreviousButton,
      enableNextButton: enableNextButton ?? this.enableNextButton,
      isLastItem: isLastItem ?? this.isLastItem,
      isRooted: isRooted ?? this.isRooted,
      pageController: pageController ?? this.pageController,
    );
  }

  @override
  String toString() {
    return 'BottomNavigationState(currentScreen: $currentScreen, totalScreens: $totalScreens, enablePreviousButton: $enablePreviousButton, '
        'enableNextButton: $enableNextButton, isLastItem: $isLastItem'
        'isRooted: $isRooted, pageController: $pageController)';
  }
}
