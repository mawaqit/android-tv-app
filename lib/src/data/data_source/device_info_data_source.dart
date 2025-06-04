import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/src/const/constants.dart';
import 'package:unique_identifier/unique_identifier.dart';
import 'package:disk_space_2/disk_space_2.dart';

import '../../../main.dart';
import '../../domain/model/device_info_model.dart';

/// This class uses various plugins to gather device-specific information such as brand,
/// model, operating system version, available disk space, and unique device identifiers.
/// It abstracts the complexity of querying multiple sources and consolidates the gathered
/// information into a [DeviceInfoModel].
///
/// [DeviceInfoDataSource]
class DeviceInfoDataSource {
  final DeviceInfoPlugin deviceInfoPlugin;
  final DiskSpace diskSpace;

  /// Constructs a [DeviceInfoDataSource], allowing for optional injection of dependencies
  /// for [DeviceInfoPlugin] and [DiskSpacePlus] for easier testing and configuration. If not
  /// injected, defaults are provided.
  DeviceInfoDataSource({
    DeviceInfoPlugin? deviceInfoPlugin,
    DiskSpace? diskSpace,
  })  : deviceInfoPlugin = deviceInfoPlugin ?? DeviceInfoPlugin(),
        diskSpace = diskSpace ?? DiskSpace();

  /// [getDeviceInfo]
  /// Gathers device information asynchronously and constructs a [DeviceInfoModel].
  /// Queries device-specific details like device brand, model, operating system version,
  /// available and total disk space, and a unique device identifier. It also retrieves
  /// the current device language setting. Returns a future of [DeviceInfoModel] with all
  /// the gathered information.
  Future<DeviceInfoModel> getDeviceInfo() async {
    final deviceInfoFuture = deviceInfoPlugin.androidInfo;
    final freeDeviceFuture = DiskSpace.getFreeDiskSpace;
    final totalFreeSpaceFuture = DiskSpace.getTotalDiskSpace;
    final deviceIdFuture = UniqueIdentifier.serial;

    // Retrieve the device language synchronously as it's not an async call
    final deviceLanguage = Platform.localeName;

    // Wait for all async operations to complete
    final results = await Future.wait([
      deviceInfoFuture,
      freeDeviceFuture,
      totalFreeSpaceFuture,
      deviceIdFuture,
    ]);

    // Extract the individual results from the list
    final androidInfo = results[0] as AndroidDeviceInfo;
    final freeDevice = results[1] as double; // Assuming DiskSpacePlus.getFreeDiskSpace returns double
    final totalFreeSpace = results[2] as double; // Assuming DiskSpacePlus.getTotalDiskSpace returns double
    final deviceId = results[3] as String;

    // Construct the result map
    return DeviceInfoModel(
      brand: androidInfo.brand,
      model: androidInfo.model,
      androidVersion: androidInfo.version.release,
      language: deviceLanguage,
      freeSpace: freeDevice,
      totalSpace: totalFreeSpace,
      deviceId: deviceId,
    );
  }

  /// [getDeviceLanguage] Returns the current device language.
  Future<String> getDeviceLanguage() async {
    return Platform.localeName;
  }

  Future<bool> isBoxOrAndroidTV() async {
    AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;

    // List of features to check
    final featuresToCheck = [
      SystemFeaturesConstant.kLeanback,
      SystemFeaturesConstant.kHdmi,
      SystemFeaturesConstant.kEthernet
    ];

    for (final feature in featuresToCheck) {
      if (androidInfo.systemFeatures.contains(feature)) {
        return true;
      }
    }

    return false;
  }

  /// [isAndroidTv] Checks if the device is AndroidTV.
  Future<bool> isAndroidTv() async {
    AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;

    return androidInfo.systemFeatures.contains(SystemFeaturesConstant.kLeanback);
  }
}

class DeviceInfoDataSourceProviderArgument {
  final DeviceInfoPlugin? deviceInfoPlugin;
  final DiskSpace? diskSpace;

  DeviceInfoDataSourceProviderArgument({
    this.deviceInfoPlugin,
    this.diskSpace,
  });
}

final deviceInfoDataSourceProvider =
    FutureProvider.family<DeviceInfoDataSource, DeviceInfoDataSourceProviderArgument>((ref, args) {
  return DeviceInfoDataSource(
    deviceInfoPlugin: args.deviceInfoPlugin,
    diskSpace: args.diskSpace,
  );
});
