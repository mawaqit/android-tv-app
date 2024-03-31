
import '../model/device_info_model.dart';

/// An abstraction for retrieving and managing device information.
///
/// This interface defines the contract for implementations that manage
/// device information, including fetching device specifications and
/// updating user preferences such as the preferred language.
abstract class DeviceInfoRepository {

  /// [getAllDeviceInfo] Fetches all device information.
  Future<DeviceInfoModel> getAllDeviceInfo();

  /// [setLanguage] Sets the user's preferred language in the app's persistent storage.
  Future<void> setLanguage(String language, String? mosqueUUID);

  /// [getLanguageWithoutCache] Retrieves the current user's preferred language setting without using cache.
  Future<String> getLanguageWithoutCache();

  /// [isBoxOrAndroidTV] Checks if the device is a box or a androidTV.
  Future<bool> isBoxOrAndroidTV();
}
