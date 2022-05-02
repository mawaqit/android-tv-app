import 'package:intl/intl.dart';

extension StringUtils on String {
  /// convert string to UpperCamelCaseFormat
  String get toCamelCase {
    final separated = trim().toLowerCase().split(' ');

    var value = separated.first;
    for (var i = 1; i < separated.length; i++) {
      final val = separated[i];

      value += toBeginningOfSentenceCase(val) ?? '';
    }

    return value;
  }
}

String? toCamelCase(String? value) {
  return value?.toCamelCase;
}
