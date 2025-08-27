import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/src/data/data_source/device_info_data_source.dart';

import 'device_info_state.dart';

/// AsyncNotifier for device information that manages detecting if a device is an Android box or Android TV
class DeviceInfoNotifier extends AutoDisposeAsyncNotifier<DeviceInfoState> {
  late final DeviceInfoDataSource deviceInfoDataSource;

  /// Initialize the state by loading the device information
  @override
  Future<DeviceInfoState> build() async {
    // Create the data source
    deviceInfoDataSource = DeviceInfoDataSource();

    final isBoxOrAndroidTV = await deviceInfoDataSource.isBoxOrAndroidTV();

    // Return the initial state
    return DeviceInfoState(isBoxOrAndroidTV: isBoxOrAndroidTV);
  }

  /// Refresh the device information data
  Future<void> refreshDeviceInfo() async {
    state = const AsyncValue.loading();
    try {
      final deviceInfoDataSource = DeviceInfoDataSource();
      final isBoxOrAndroidTV = await deviceInfoDataSource.isBoxOrAndroidTV();
      state = AsyncValue.data(DeviceInfoState(isBoxOrAndroidTV: isBoxOrAndroidTV));
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

/// Provider for the DeviceInfoNotifier
final deviceInfoProvider =
    AutoDisposeAsyncNotifierProvider<DeviceInfoNotifier, DeviceInfoState>(DeviceInfoNotifier.new);
