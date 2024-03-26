
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/src/domain/usecase/on_boarding_usecase.dart';
import 'package:provider/provider.dart' as provider ;

import '../../../i18n/AppLanguage.dart';
import 'device_state.dart';

class DeviceNotifier extends AsyncNotifier<DeviceState> {
  @override
  Future<DeviceState> build() async {
    return DeviceState.initial();
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
}

final deviceNotifier =
AsyncNotifierProvider<DeviceNotifier, DeviceState>(DeviceNotifier.new);
