class PositionOptions {
  bool enableHighAccuracy = false;
  int? timeout = 0;
  int? maximumAge = 0;

  PositionOptions from(dynamic data) {
    if (isNull(data)) return PositionOptions();

    return PositionOptions()
      ..enableHighAccuracy = parseBool(data['enableHighAccuracy'] ?? false)
      ..timeout = parseInt(data['timeout'] ?? 0)
      ..maximumAge = parseInt(data['maximumAge'] ?? 0);
  }

  bool isNull(dynamic value) {
    return (value == null || value.toString() == 'null' || value.toString().isEmpty);
  }

  bool parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is String)
      return value.toLowerCase() == 'true' || value.toLowerCase() == 'success' || value.toLowerCase() == '1';
    if (value is int) return value == 1;

    return false;
  }

  int? parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;

    return int.tryParse(value) ?? null;
  }
}
