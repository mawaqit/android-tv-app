import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mawaqit/main.dart';
import 'package:mawaqit/src/helpers/Api.dart';
import 'package:mawaqit/src/helpers/AppRouter.dart';
import 'package:mawaqit/src/helpers/SharedPref.dart';
import 'package:mawaqit/src/pages/home/OfflineHomeScreen.dart';
import 'package:mawaqit/src/pages/mosque_search/widgets/InputTypeSelector.dart';
import 'package:mawaqit/src/pages/mosque_search/widgets/MosqueInputId.dart';
import 'package:mawaqit/src/pages/mosque_search/widgets/MosqueInputSearch.dart';
import 'package:mawaqit/src/pages/mosque_search/widgets/chromecast_mosque_input_search.dart';
import 'package:page_transition/page_transition.dart';

import 'onboarding_navigation_state.dart';
import 'search_selection_type_provider.dart';

class OnboardingNavigationNotifier extends AsyncNotifier<OnboardingNavigationState> {
  @override
  Future<OnboardingNavigationState> build() async {
    // Initialize with root check
    final isRooted = await _checkRoot();
    final initialFlow = isRooted ? OnboardingFlowType.kiosk : OnboardingFlowType.main;

    ref.listen(mosqueManagerProvider, (previous, next) {
      next.fold(() => {}, (mosque) {
        _updateFlowBasedOnMosqueType(mosque);
      });
    });

    return OnboardingNavigationState(
      isRooted: isRooted,
      screenFlow: _getInitialScreenFlow(initialFlow),
      flowType: initialFlow,
    );
  }

  void _updateFlowBasedOnMosqueType(SearchSelectionType mosqueType) {
    final currentState = state.value!;
    final newFlow = [...currentState.screenFlow];
    final currentIndex = currentState.currentScreen;

    // Remove any screens after the current screen
    if (currentIndex < newFlow.length) {
      newFlow.removeRange(currentIndex + 1, newFlow.length);
    }

    // Add proper screens based on mosque type
    if (mosqueType == SearchSelectionType.mosque) {
      // First add the screen type selection
      newFlow.add(OnboardingScreenType.screenType);
      // Then add the announcement screen
      newFlow.add(OnboardingScreenType.announcement);
    }

    state = AsyncData(
      currentState.copyWith(
        screenFlow: newFlow,
        flowType: mosqueType == SearchSelectionType.mosque
            ? OnboardingFlowType.mosque
            : OnboardingFlowType.home,
        currentScreen: currentState.currentScreen,
      ),
    );
  }

  // In OnboardingNavigationNotifier
  void completeOnboarding(BuildContext context) {
    if (!state.hasValue) return;
    final sharedPref = SharedPref();
    sharedPref.save('boarding', 'true').then((_) {
      if (context.mounted) {
        AppRouter.pushReplacement(OfflineHomeScreen());
      }
    });
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

  Future<void> nextPage(BuildContext context) async {
    if (!state.hasValue) return;
    final currentState = state.value!;

    if (currentState.currentScreen < currentState.screenFlow.length) {
      // Handle mosque search type selection
      if (currentState.screenFlow[currentState.currentScreen] == OnboardingScreenType.mosqueSearchType) {
        await _handleMosqueSearchNavigation(currentState);
        return;
      }

      final newScreenFlow = [...currentState.screenFlow];

      final mosqueTypeOption = ref.read(mosqueManagerProvider);

      final isCompleted = mosqueTypeOption.fold<bool>(
            () => false,
            (mosqueType) {
          final shouldComplete = switch ((mosqueType, currentState.screenFlow.last)) {
          // Complete immediately for home type
            (SearchSelectionType.home, _) => currentState.currentScreen == currentState.screenFlow.length - 1,
          // Complete after announcement screen for mosque type
            (SearchSelectionType.mosque, OnboardingScreenType.announcement) =>
            currentState.currentScreen == currentState.screenFlow.length -1 ,
            _ => false,
          };
          return shouldComplete;
        },
      );
      if(isCompleted){
        completeOnboarding(context);
        state = AsyncData(
          currentState.copyWith(
            enablePreviousButton: true,
            isLastItem: false,
            screenFlow: newScreenFlow,
          ),
        );
        return;
      }

      state = AsyncData(
        currentState.copyWith(
          currentScreen: currentState.currentScreen + 1 ,
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

    state = AsyncData(
      currentState.copyWith(
        currentScreen: currentState.currentScreen + 1,
        enablePreviousButton: true,
        screenFlow: newFlow,
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
