import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/main.dart';
import 'package:mawaqit/src/helpers/Api.dart';
import 'package:mawaqit/src/pages/mosque_search/widgets/InputTypeSelector.dart';
import 'package:mawaqit/src/pages/mosque_search/widgets/MosqueInputId.dart';
import 'package:mawaqit/src/pages/mosque_search/widgets/MosqueInputSearch.dart';
import 'package:mawaqit/src/pages/mosque_search/widgets/chromecast_mosque_input_search.dart';
import 'package:page_transition/page_transition.dart';

import 'onboarding_navigation_state.dart';

class OnboardingNavigationNotifier extends AsyncNotifier<OnboardingNavigationState> {

  @override
  Future<OnboardingNavigationState> build() async {
    // Initialize with root check
    final isRooted = await _checkRoot();

    return OnboardingNavigationState(
      screenFlow: isRooted ? mainKioskModeScreenFlow : mainScreenFlow,
      currentScreen: 0,
      enablePreviousButton: false,
      enableNextButton: true,
      isLastItem: false,
      isRooted: isRooted,
    );
  }

  Future<bool> _checkRoot() async {
    try {
      final result = await const MethodChannel('nativeMethodsChannel').invokeMethod('checkRoot');
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<void> nextPage() async {
    if (!state.hasValue) return;
    final currentState = state.value!;

    if (currentState.currentScreen < currentState.screenFlow.length) {
      if (currentState.screenFlow[currentState.currentScreen] == OnboardingScreenType.mosqueSearchType) {
        final deviceModel = await _fetchDeviceModel() ?? '';
        final isChromeCast = deviceModel.contains('chromecast');
        final selectionType = ref.read(mosqueInputTypeSelectorProvider);

        // Determine the next screen based on device type and user selection
        final screenType = switch ((isChromeCast, selectionType)) {
          (true, SelectionType.mosqueId) => OnboardingScreenType.chromecastMosqueId,
          (true, SelectionType.mosqueName) => OnboardingScreenType.chromecastMosqueName,
          (false, SelectionType.mosqueId) => OnboardingScreenType.mosqueId,
          (false, SelectionType.mosqueName) => OnboardingScreenType.mosqueName,
        };

        currentState.screenFlow.insert(currentState.currentScreen + 1, screenType);
      }

      state = AsyncData(
        currentState.copyWith(
          currentScreen: currentState.currentScreen + 1,
          enablePreviousButton: true,
          isLastItem: currentState.currentScreen + 1 == currentState.screenFlow.length - 1,
        ),
      );
    }
  }

  Future<void> previousPage() async {
    if (!state.hasValue) return;
    final currentState = state.value!;

    if (currentState.currentScreen > 0) {
      currentState.screenFlow.removeLast();
      state = AsyncData(currentState.copyWith(
        currentScreen: currentState.currentScreen - 1,
        isLastItem: false,
        enablePreviousButton: currentState.currentScreen - 1 > 0,
      ));
    }
  }

  Future<String?> _fetchDeviceModel() async {
    try {
      final userData = await Api.prepareUserData();
      if (userData != null) {
        return userData.$2['model'];
      }
      return null;
    } catch (e, stackTrace) {
      logger.e('Error fetching user data: $e', stackTrace: stackTrace);
      return null;
    }
  }

  List<OnboardingScreenType> get mainKioskModeScreenFlow => [
        OnboardingScreenType.language,
        OnboardingScreenType.orientation,
        OnboardingScreenType.about,
        OnboardingScreenType.countrySelection,
        OnboardingScreenType.timezoneSelection,
        OnboardingScreenType.wifiSelection,
        OnboardingScreenType.mosqueSearchType,
      ];

  List<OnboardingScreenType> get mainScreenFlow => [
        OnboardingScreenType.language,
        OnboardingScreenType.orientation,
        OnboardingScreenType.about,
        OnboardingScreenType.mosqueSearchType,
      ];

  List<OnboardingScreenType> get mosqueSearchScreenFlow => [
        OnboardingScreenType.screenType,
        OnboardingScreenType.announcement,
      ];

  List<OnboardingScreenType> get homeScreenFlow => [];
}

final onboardingNavigationProvider = AsyncNotifierProvider<OnboardingNavigationNotifier, OnboardingNavigationState>(
  OnboardingNavigationNotifier.new,
);
