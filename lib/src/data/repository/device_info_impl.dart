import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/src/domain/repository/device_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../main.dart';
import '../../const/constants.dart';
import '../../domain/model/device_info_model.dart';
import '../../helpers/AnalyticsWrapper.dart';
import '../data_source/device_info_data_source.dart';

/// [DeviceInfoImpl] Manages device information and settings, including language preferences.
///
/// This class acts as an intermediary between the device information data source
/// and the rest of the application. It's responsible for fetching and persisting
class DeviceInfoImpl implements DeviceInfoRepository {
  final DeviceInfoDataSource deviceInfoDataSource;
  final SharedPreferences sharedPreferences;

  /// Constructs a [DeviceInfoImpl] with dependencies on [DeviceInfoDataSource]
  /// for fetching device info and [SharedPreferences] for persisting settings.
  DeviceInfoImpl({
    required this.deviceInfoDataSource,
    required this.sharedPreferences,
  });

  /// [getAllDeviceInfo] Fetches all device information.
  ///
  /// Retrieves device information from a persistent storage if available,
  /// otherwise queries the device info data source. The result is then
  /// stored for future use.
  @override
  Future<DeviceInfoModel> getAllDeviceInfo() async {
    try {
      if (sharedPreferences.get(kDeviceInfo) == null) {
        final DeviceInfoModel deviceInfo = await deviceInfoDataSource.getDeviceInfo();
        final String deviceInfoString = json.encode(deviceInfo.toJson());
        await sharedPreferences.setString(kDeviceInfo, deviceInfoString);
        return deviceInfo;
      } else {
        final String deviceInfoString = sharedPreferences.getString(kDeviceInfo)!;
        final DeviceInfoModel deviceInfo = DeviceInfoModel.fromJson(jsonDecode(deviceInfoString));
        return deviceInfo;
      }
    } catch (e, s) {
      logger.e('Error fetching device info', stackTrace: s, error: e);
      rethrow;
    }
  }

  /// [setLanguage] Sets the user's preferred language in the app's persistent storage.
  ///
  /// Attempts to store the preferred language and country code. It also logs the
  /// language change event using the AnalyticsWrapper for tracking user preferences.
  /// If an error occurs during the process, it logs the error and rethrows it.
  /// At the on boarding, the language is set to the system language.
  /// At the on boarding, the mosqueUUID is not set, so it is null.
  @override
  Future<void> setLanguage(String language, String? mosqueUUID) async {
    try {
      await sharedPreferences.setString('language_code', language);
      await sharedPreferences.setString('countryCode', language.split('_').last);
      AnalyticsWrapper.changeLanguage(
        oldLanguage: 'en',
        language: language,
        mosqueId: mosqueUUID,
      );
    } catch (e, s) {
      logger.e('Error setting language in shared preferences', stackTrace: s);
      rethrow;
    }
  }

  /// [getLanguageWithoutCache] Fetches the current device language setting directly.
  ///
  /// Retrieves the preferred language setting from the device without relying
  /// on cached values.
  Future<String> getLanguageWithoutCache() async {
    try {
      return deviceInfoDataSource.getDeviceLanguage();
    } catch (e, s) {
      logger.e('Error fetching the language locale', stackTrace: s);
      rethrow;
    }
  }

  ///  [isBoxOrAndroidTV] Checks if the device is a box or a androidTV.
  ///
  /// return a boolean value indicating if the device is a box or a AndroidTV.
  Future<bool> isBoxOrAndroidTV() async {
    try {
      return await deviceInfoDataSource.isBoxOrAndroidTV();
    } catch (e, s) {
      logger.e('Error fetching device type', stackTrace: s);
      rethrow;
    }
  }
  ///  [initRootRequest] Checks if the device is a box or a androidTV.
  ///
  /// return a boolean value indicating if the device is a box or a AndroidTV.
  Future<bool> initRootRequest() async {
    try {
      return await deviceInfoDataSource.initRootRequest();
    } catch (e, s) {
      logger.e('Error fetching root access', stackTrace: s);
      rethrow;
    }
  }
}

class DeviceInfoImplProviderArgument {
  final DeviceInfoDataSource deviceInfoDataSource;
  final SharedPreferences sharedPreferences;

  DeviceInfoImplProviderArgument({
    required this.deviceInfoDataSource,
    required this.sharedPreferences,
  });
}

final deviceInfoImplProvider = FutureProvider.family<DeviceInfoRepository, DeviceInfoImplProviderArgument>(
  (ref, DeviceInfoImplProviderArgument argument) {
    return DeviceInfoImpl(
      deviceInfoDataSource: argument.deviceInfoDataSource,
      sharedPreferences: argument.sharedPreferences,
    );
  },
);
