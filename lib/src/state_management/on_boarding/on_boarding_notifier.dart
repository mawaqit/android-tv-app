import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/src/helpers/shared_preference_module.dart';

import 'on_boarding_state.dart';


class OnBoardingNotifier extends AsyncNotifier<OnBoardingState> {
  @override
  OnBoardingState build() {
    return OnBoardingState();
  }

  Future<void> nextPage() async {
    state = AsyncLoading();
    if (state.value!.currentScreen < 5) {
      state = AsyncValue.data(
        state.value!.copyWith(currentScreen: state.value!.currentScreen + 1),
      );
    } else {
      final sharedPref = await ref.read(sharedPrefModule.future);
      state = await AsyncValue.guard(() async {
        await sharedPref.setString('boarding', 'true');
        state = AsyncValue.data(
          state.value!.copyWith(isCompleted: true),
        );
        return state.value!;
      });
    }
  }

  void previousPage() {
    state = AsyncLoading();
    if (state.value!.currentScreen > 0) {
      state = AsyncValue.data(
        state.value!.copyWith(currentScreen: state.value!.currentScreen - 1),
      );
    }
  }

  void resetPage() {
    state = AsyncValue.data(
      state.value!.copyWith(currentScreen: 0, isCompleted: false),
    );
  }
}

final boardingProvider = AsyncNotifierProvider<OnBoardingNotifier, OnBoardingState>(OnBoardingNotifier.new);
