import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'onboarding_navigation_state.dart';

class OnboardingNavigationNotifier extends AsyncNotifier<OnboardingNavigationState> {
  late final PageController _pageController;

  @override
  Future<OnboardingNavigationState> build() async {
    _pageController = PageController();
    ref.onDispose(() {
      _pageController.dispose();
    });

    // Initialize with root check
    final isRooted = await _checkRoot();

    return OnboardingNavigationState(
      currentScreen: 0,
      totalScreens: isRooted ? 8 : 6,
      enablePreviousButton: false,
      enableNextButton: true,
      isLastItem: false,
      isRooted: isRooted,
      pageController: _pageController,
    );
  }

  Future<bool> _checkRoot() async {
    try {
      final result = await const MethodChannel('nativeMethodsChannel').invokeMethod('checkRoot');
      return result ?? false;
    } catch (e) {
      print('Error checking root access: $e');
      return false;
    }
  }

  Future<void> updateNavigation({
    required int currentScreen,
    required int totalScreens,
    required bool enablePreviousButton,
    required bool enableNextButton,
    bool isLastItem = false,
  }) async {
    state = AsyncData(state.value!.copyWith(
      currentScreen: currentScreen,
      totalScreens: totalScreens,
      enablePreviousButton: enablePreviousButton,
      enableNextButton: enableNextButton,
      isLastItem: isLastItem,
    ));
  }

  Future<void> nextPage() async {
    if (!state.hasValue) return;
    final currentState = state.value!;
    if (currentState.currentScreen < currentState.totalScreens - 1) {
      print('Current screen: ${currentState.currentScreen}');

      await _pageController.animateToPage(
        currentState.currentScreen + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );

      state = AsyncData(currentState.copyWith(
        currentScreen: currentState.currentScreen + 1,
        enablePreviousButton: true,
        isLastItem: currentState.currentScreen + 1 == currentState.totalScreens - 1,
      ));
    }
  }

  Future<void> previousPage() async {
    if (!state.hasValue) return;
    final currentState = state.value!;

    if (currentState.currentScreen > 0) {
      await _pageController.animateToPage(
        currentState.currentScreen - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );

      state = AsyncData(currentState.copyWith(
        currentScreen: currentState.currentScreen - 1,
        isLastItem: false,
        enablePreviousButton: currentState.currentScreen - 1 > 0,
      ));
    }
  }

  Future<void> jumpToPage(int page) async {
    if (!state.hasValue) return;
    final currentState = state.value!;

    if (page >= 0 && page < currentState.totalScreens) {
      _pageController.jumpToPage(page);
      state = AsyncData(currentState.copyWith(
        currentScreen: page,
        enablePreviousButton: page > 0,
        isLastItem: page == currentState.totalScreens - 1,
      ));
    }
  }
}

final onboardingNavigationProvider = AsyncNotifierProvider<OnboardingNavigationNotifier, OnboardingNavigationState>(
  OnboardingNavigationNotifier.new,
);
