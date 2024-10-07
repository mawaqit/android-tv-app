enum MoshafType {
  warsh,
  hafs;

  static MoshafType fromString(String value) {
    return MoshafType.values.firstWhere(
      (type) {
        return type.name.toString().toLowerCase() == value.toString().toLowerCase();
      },
      orElse: () => throw ArgumentError('Invalid MoshafType: $value'),
    );
  }
}
