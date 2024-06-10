/// The [DeviceInfoModel] class represents the information about the device
/// retrieved from various sources. It includes the device's brand, model,
/// operating system version, language, storage info, and a unique device identifier.
class DeviceInfoModel {
  final String brand;
  final String model;
  final String androidVersion;
  final String language;
  final double freeSpace;
  final double totalSpace;
  final String deviceId;

  /// Constructs an instance of [DeviceInfoModel].
  ///
  /// Requires values for brand, model, androidVersion, language,
  /// freeSpace, totalSpace, and deviceId to be provided during initialization.
  /// Sets the value of each field to 'unknown' if not provided or if the value is null.
  DeviceInfoModel({
    String? brand,
    String? model,
    String? androidVersion,
    String? language,
    double? freeSpace,
    double? totalSpace,
    String? deviceId,
  })  : this.brand = brand ?? 'unknown',
        this.model = model ?? 'unknown',
        this.androidVersion = androidVersion ?? 'unknown',
        this.language = language ?? 'unknown',
        this.freeSpace = freeSpace ?? -1,

        /// Consider how to represent unknown for double
        this.totalSpace = totalSpace ?? -1,

        /// Consider how to represent unknown for double
        this.deviceId = deviceId ?? 'unknown';

  /// Creates a new [DeviceInfoModel] instance from a JSON map.
  ///
  /// Expects a Map with keys 'brand', 'model', 'android-version', 'language',
  /// 'free-space', 'total-space', and 'device-id', and will throw a TypeError
  /// if any of them are missing or if their types are not as expected.
  factory DeviceInfoModel.fromJson(Map<String, dynamic> json) {
    return DeviceInfoModel(
      brand: json['brand'],
      model: json['model'],
      androidVersion: json['android-version'],
      language: json['language'],
      freeSpace: json['free-space'],
      totalSpace: json['total-space'],
      deviceId: json['device-id'],
    );
  }

  /// Converts the [DeviceInfoModel] instance into a JSON map.
  ///
  /// Useful for serialization or storing the object.
  Map<String, dynamic> toJson() {
    return {
      'brand': brand,
      'model': model,
      'android-version': androidVersion,
      'language': language,
      'free-space': freeSpace,
      'total-space': totalSpace,
      'device-id': deviceId,
    };
  }

  /// Returns a string representation of the [DeviceInfoModel] instance.
  ///
  /// Useful for debugging or logging the information of the device.
  @override
  String toString() {
    return 'DeviceInfoModel(brand: $brand, model: $model, androidVersion: $androidVersion, language: $language, freeSpace: $freeSpace, totalSpace: $totalSpace, deviceId: $deviceId)';
  }
}
