import 'package:device_info_plus/device_info_plus.dart';
import 'package:disk_space/disk_space.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/src/data/constants.dart';
import 'package:mawaqit/src/models/device_info.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:unique_identifier/unique_identifier.dart';
import 'package:mawaqit/main.dart' show logger;

import '../../i18n/AppLanguage.dart';

/// DeviceManagerProvider extends AsyncNotifier to asynchronously manage DeviceInfo.
/// [DeviceManagerProvider] It fetches and provides device-related information throughout the app.
/// e.g device id, free space, etc.
class DeviceManagerProvider extends AsyncNotifier<DeviceInfo> {
  @override
  Future<DeviceInfo> build() async {
    // Asynchronously fetch various pieces of device information.
    var hardwareFuture = DeviceInfoPlugin().androidInfo; // Hardware information.
    var softwareFuture = PackageInfo.fromPlatform(); // Software (app) information.
    var languageFuture = AppLanguage.getCountryCode(); // Device language setting.
    var freeSpaceFuture = DiskSpace.getFreeDiskSpace; // Free disk space.
    Future totalSpaceFuture = DiskSpace.getTotalDiskSpace; // Total disk space.
    Future<String?> deviceIdFuture = UniqueIdentifier.serial; // Unique device identifier.

    // Wait for all the asynchronous operations to complete.
    List results = await Future.wait([
      hardwareFuture,
      softwareFuture,
      languageFuture,
      freeSpaceFuture,
      totalSpaceFuture,
      deviceIdFuture,
    ]);

    // Extract results from the completed futures.
    var hardware = results[0] as AndroidDeviceInfo;
    var software = results[1] as PackageInfo;
    var freeSpace = results[3] as double;
    var totalSpace = results[4] as double;
    var deviceId = results[5] as String;

    // Return a DeviceInfo object populated with the fetched data.
    return DeviceInfo(
      deviceId: deviceId,
      brand: hardware.brand,
      model: hardware.model,
      androidVersion: hardware.version.release,
      appVersion: software.version,
      totalSpace: totalSpace,
      freeSpace: freeSpace,
    );
  }

  /// [getFreeSpace] Asynchronously gets the free disk space and updates the state.
  Future<void> getFreeSpace() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final freeSpace = await DiskSpace.getFreeDiskSpace;
      if (freeSpace != null && freeSpace <= kStorageLimit) {
        logger.e('Device Exception: Storage limit reached');
        throw Exception('Storage limit reached');
      }
      return state.value!.copyWith(
        freeSpace: freeSpace,
      );
    });
  }
}

/// Global provider for DeviceManagerProvider.
/// This provider is used to access the device information and status updates throughout the app.
final deviceManagerProvider =
AsyncNotifierProvider<DeviceManagerProvider, DeviceInfo>(DeviceManagerProvider.new);
