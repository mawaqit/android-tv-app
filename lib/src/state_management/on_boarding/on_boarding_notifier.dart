import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/src/const/constants.dart';
import 'package:mawaqit/src/domain/usecase/on_boarding_usecase.dart';
import 'package:provider/provider.dart' as provider;

import '../../../i18n/AppLanguage.dart';
import 'on_boarding_state.dart';

class OnBoardingNotifier extends AsyncNotifier<OnboardingState> {
  @override
  Future<OnboardingState> build() async {
    return OnboardingState.initial();
  }

  Future<void> getSystemLanguage() async {
    final deviceInfoUseCase = await ref.read(deviceInfoUseCaseProvider.future);
    state = AsyncLoading();
    state = await AsyncValue.guard(() async {
      final language = await deviceInfoUseCase.getDeviceLanguage();
      update((p0) => p0.copyWith(language: language));
      return state.value!;
    });
  }

  Future<void> setLanguage(String language, BuildContext context) async {
    state = AsyncLoading();
    final deviceInfoUseCase = await ref.read(deviceInfoUseCaseProvider.future);

    state = await AsyncValue.guard(() async {
      final appLanguage = provider.Provider.of<AppLanguage>(context, listen: false);
      appLanguage.changeLanguage(Locale(language), '');
      await deviceInfoUseCase.setOnboardingAppLanguage(language);
      update((p0) => p0.copyWith(language: language));
      return state.value!;
    });
  }

  /// check if the device rooted or not
  Future<void> isDeviceRooted() async {
    state = AsyncLoading();
    try {
      final result = await MethodChannel(TurnOnOffTvConstant.kNativeMethodsChannel).invokeMethod(
        TurnOnOffTvConstant.kCheckRoot,
      );
      final newState = state.value!.copyWith(isRootedDevice: result);
      state = AsyncValue.data(newState);
    } catch (e) {
      final newState = state.value!.copyWith(isRootedDevice: false);
      state = AsyncValue.data(newState);
    }
  }
}

final onBoardingProvider = AsyncNotifierProvider<OnBoardingNotifier, OnboardingState>(OnBoardingNotifier.new);
