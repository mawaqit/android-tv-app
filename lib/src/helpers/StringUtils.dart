import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mawaqit/i18n/AppLanguage.dart';
import 'package:provider/provider.dart';

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

class StringManager {
  // final isArabic = Localizations.localeOf(context).languageCode == 'ar';
  static const fontFamilyKufi = "kufi";
  static const fontFamilyArial = "arial";
  static const fontFamilyHelvetica = "helvetica";

  static String getFontFamily(BuildContext context) {
    String langCode = "${context.read<AppLanguage>().appLocal}";
    if (langCode == "ar" || langCode == "ur") {
      return fontFamilyKufi;
    }
    return fontFamilyArial;
  }
}
