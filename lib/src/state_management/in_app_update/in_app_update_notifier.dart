import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../main.dart';
import '../../domain/usecase/in_app_update_usecase.dart';
import 'in_app_update_state.dart';

class InAppUpdateNotifier extends AutoDisposeAsyncNotifier<InAppUpdateState> {
  InAppUpdateState build() {
    return InAppUpdateState.idle();
  }

  Future<void> startUpdate() async {
    state = AsyncLoading();
    state = await AsyncValue.guard(() async {
      final inAppUpdateUseCase = await ref.read(inAppUpdateUseCaseProvider.future);
      final updateStatus = await inAppUpdateUseCase.performImmediateUpdateUseCase();
      logger.i('state_management: InAppUpdateNotifier startUpdate: $updateStatus');
      update((p0) => p0.copyWith(inAppUpdateStatus: updateStatus));
      return state.value!;
    });
  }

  Future<void> checkForUpdate() async {
    state = AsyncLoading();
    state = await AsyncValue.guard(() async {
      final inAppUpdateUseCase = await ref.read(inAppUpdateUseCaseProvider.future);
      final isAvailableUpdate = await inAppUpdateUseCase.checkForUpdateUseCase();
      update((p0) => p0.copyWith(inAppUpdateStatus: isAvailableUpdate));
      return state.value!;
    });
  }

  Future<void> scheduleUpdate(List<String> prayerTimeList) async {
    state = AsyncLoading();
    state = await AsyncValue.guard(() async {
      final inAppUpdateUseCase = await ref.read(inAppUpdateUseCaseProvider.future);
      await inAppUpdateUseCase.scheduleUpdateUseCase(prayerTimeList);
      return state.value!;
    });
  }
}

final inAppUpdateProvider =
    AutoDisposeAsyncNotifierProvider<InAppUpdateNotifier, InAppUpdateState>(InAppUpdateNotifier.new);
