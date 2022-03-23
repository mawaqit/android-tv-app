import 'package:intl/intl.dart';

extension StringUtils on String {
  /// convert string to UpperCamelCaseFormat
  String get toCamelCase {
    return trim().split(' ').map((e) => toBeginningOfSentenceCase(e)).join();
  }
}

String? toCamelCase(String? value) {
  return value?.toCamelCase;
}
