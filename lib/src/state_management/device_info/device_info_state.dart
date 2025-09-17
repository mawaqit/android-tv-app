/// DeviceInfoState class to hold the state for the device information
class DeviceInfoState {
  final bool isBoxOrAndroidTV;

  const DeviceInfoState({
    required this.isBoxOrAndroidTV,
  });

  /// Copy with method to create a new instance with updated values
  DeviceInfoState copyWith({
    bool? isBoxOrAndroidTV,
  }) {
    return DeviceInfoState(
      isBoxOrAndroidTV: isBoxOrAndroidTV ?? this.isBoxOrAndroidTV,
    );
  }
}
