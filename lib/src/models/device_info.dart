/// DeviceInfo class holds information about the device where the app is running.
class DeviceInfo {
  /// [deviceId] Unique identifier for the device.
  String deviceId;

  /// [brand] Brand of the device (e.g., Samsung, Apple).
  String brand;

  /// [model] Model of the device.
  String model;

  /// [androidVersion] Android operating system version of the device.
  String androidVersion;

  /// [language] Language setting of the device.
  String language;

  /// [appVersion] Version of the app installed on the device.
  String appVersion;

  /// [totalSpace] holds the total storage space of the device.
  /// It defaults to -1 to indicate that the value is not available or not set.
  double totalSpace;

  /// [freeSpace] holds the available free storage space of the device.
  /// It defaults to -1, similar to [totalSpace], to indicate unavailability.
  double freeSpace;

  /// Constructor for DeviceInfo with default values, ensuring no nulls.
  DeviceInfo({
    this.deviceId = 'Unknown',
    this.brand = 'Unknown',
    this.model = 'Unknown',
    this.androidVersion = 'Unknown',
    this.appVersion = 'Unknown',
    this.totalSpace = -1,
    this.freeSpace = -1,
    this.language = 'Unknown',
  });

  /// Factory constructor to create a DeviceInfo object from a map.
  /// This is useful for deserialization from a data source like JSON.
  factory DeviceInfo.fromMap(Map<String, dynamic> map) {
    return DeviceInfo(
      deviceId: map['device-id'] ?? 'Unknown',
      brand: map['brand'] ?? 'Unknown',
      model: map['model'] ?? 'Unknown',
      androidVersion: map['android-version'] ?? 'Unknown',
      appVersion: map['app-version'] ?? 'Unknown',
      totalSpace: map['space'] ?? -1,
      freeSpace: map['free-space'] ?? -1,
      language: map['language'] ?? 'Unknown',
    );
  }

  /// Converts the DeviceInfo object to a map.
  /// This is useful for serialization to a data format like JSON.
  Map<String, dynamic> toMap() {
    return {
      'device-id': deviceId,
      'brand': brand,
      'model': model,
      'android-version': androidVersion,
      'app-version': appVersion,
      'space': totalSpace,
      'free-space': freeSpace,
      'language': language,
    };
  }

  /// Creates a copy of the DeviceInfo object with the option to override existing values.
  DeviceInfo copyWith({
    String? deviceId,
    String? brand,
    String? model,
    String? androidVersion,
    String? appVersion,
    double? totalSpace,
    double? freeSpace,
    String? language,
  }) {
    return DeviceInfo(
      deviceId: deviceId ?? this.deviceId,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      androidVersion: androidVersion ?? this.androidVersion,
      appVersion: appVersion ?? this.appVersion,
      totalSpace: totalSpace ?? this.totalSpace,
      freeSpace: freeSpace ?? this.freeSpace,
      language: language ?? this.language,
    );
  }
}
