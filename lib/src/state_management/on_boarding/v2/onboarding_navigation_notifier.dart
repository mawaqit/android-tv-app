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
    final initialFlow = isRooted ? OnboardingFlowType.kiosk : OnboardingFlowType.main;

    return OnboardingNavigationState(
      isRooted: isRooted,
      screenFlow: _getInitialScreenFlow(initialFlow),
      flowType: initialFlow,
    );
  }

  List<OnboardingScreenType> _getInitialScreenFlow(OnboardingFlowType flowType) {
    return switch (flowType) {
      OnboardingFlowType.kiosk => [
          OnboardingScreenType.language,
          OnboardingScreenType.orientation,
          OnboardingScreenType.about,
          OnboardingScreenType.countrySelection,
          OnboardingScreenType.timezoneSelection,
          OnboardingScreenType.wifiSelection,
          OnboardingScreenType.mosqueSearchType,
        ],
      OnboardingFlowType.main => [
          OnboardingScreenType.language,
          OnboardingScreenType.orientation,
          OnboardingScreenType.about,
          OnboardingScreenType.mosqueSearchType,
        ],
      _ => [],
    };
  }

  Future<void> nextPage() async {
    if (!state.hasValue) return;
    final currentState = state.value!;

    if (currentState.currentScreen < currentState.screenFlow.length) {
      // Handle mosque search type selection
      if (currentState.screenFlow[currentState.currentScreen] == OnboardingScreenType.mosqueSearchType) {
        await _handleMosqueSearchNavigation(currentState);
        return;
      }

      final newScreenFlow = [...currentState.screenFlow];

      state = AsyncData(
        currentState.copyWith(
          currentScreen: currentState.currentScreen + 1,
          enablePreviousButton: true,
          isLastItem: currentState.currentScreen + 1 == newScreenFlow.length - 1,
          screenFlow: newScreenFlow,
        ),
      );
    }
  }

  Future<void> _handleMosqueSearchNavigation(OnboardingNavigationState currentState) async {
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

    final newFlow = [...currentState.screenFlow];
    newFlow.insert(currentState.currentScreen + 1, screenType);

    // Add mosque-specific screens if needed
    // final mosqueManager = ref.read(mosqueManagerProvider);
    if (true) {
      newFlow.addAll([
        OnboardingScreenType.screenType,
        OnboardingScreenType.announcement,
      ]);
    }

    state = AsyncData(
      currentState.copyWith(
        currentScreen: currentState.currentScreen + 1,
        enablePreviousButton: true,
        screenFlow: newFlow,
        flowType: true ? OnboardingFlowType.mosque : OnboardingFlowType.home,
      ),
    );
  }

  Future<void> previousPage() async {
    if (!state.hasValue) return;
    final currentState = state.value!;

    if (currentState.currentScreen > 0) {
      final newScreenFlow = [...currentState.screenFlow];

      // Remove mosque-specific screens if going back from mosque flow
      if (currentState.flowType == OnboardingFlowType.mosque &&
          currentState.screenFlow[currentState.currentScreen - 1] == OnboardingScreenType.mosqueSearchType) {
        while (newScreenFlow.last != OnboardingScreenType.mosqueSearchType) {
          newScreenFlow.removeLast();
        }
      }

      state = AsyncData(
        currentState.copyWith(
          currentScreen: currentState.currentScreen - 1,
          isLastItem: false,
          enablePreviousButton: currentState.currentScreen - 1 > 0,
          screenFlow: newScreenFlow,
        ),
      );
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

  Future<bool> _checkRoot() async {
    try {
      final result = await const MethodChannel('nativeMethodsChannel').invokeMethod('checkRoot');
      return result ?? false;
    } catch (e) {
      return false;
    }
  }
}

final onboardingNavigationProvider = AsyncNotifierProvider<OnboardingNavigationNotifier, OnboardingNavigationState>(
  OnboardingNavigationNotifier.new,
);
