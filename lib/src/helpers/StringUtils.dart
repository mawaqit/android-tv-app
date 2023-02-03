import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mawaqit/i18n/AppLanguage.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:provider/provider.dart';

import '../../generated/l10n.dart';

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
  static RegExp arabicLetters = RegExp(r'[\u0600-\u06ff]');
  static RegExp urduLetters = RegExp(r'[\u0600-\u06ff]+');
  static const fontFamilyKufi = "kufi";
  static const fontFamilyArial = "arial";
  static const fontFamilyHelvetica = "helvetica";
///////////// Salah count down text in Time widget
  static String getCountDownText(BuildContext context,Duration salahTime,String salahName) {
    return [
      "$salahName ${S.of(context).in1} ",
      if (salahTime.inMinutes > 0)
        "${salahTime.inHours.toString().padLeft(2, '0')}:${(salahTime.inMinutes % 60).toString().padLeft(2, '0')}",
      if (salahTime.inMinutes == 0) "${(salahTime.inSeconds % 60).toString().padLeft(2, '0')} ${S.of(context).sec}",
    ].join();
  }
//////////// get font family
  static String? getFontFamilyByString(String value) {
    if (value.isArabic() || value.isUrdu()) {
      return fontFamilyKufi;
    }
    return null;
  }

  @Deprecated('user [StringManager.getFontFamilyByString] or anyString.isArabic')
  static String? getFontFamily(BuildContext context) {
    String langCode = "${context.read<AppLanguage>().appLocal}";
    if (langCode == "ar" || langCode == "ur") {
      return fontFamilyKufi;
    }
    return null;
  }

  /// return list
  static List convertStringToList(String text) {
    List<String> list = List.from(text.split(RegExp(r"\s+")));

    List<int> arabicIndexes = [];
    arabicIndexes =
        list.asMap().entries.where((entry) => arabicLetters.hasMatch(entry.value)).map((entry) => entry.key).toList();
    if (arabicIndexes.isEmpty) return list;
    List<String> sublist = list.sublist(arabicIndexes.first, arabicIndexes.last + 1);
// Reverse the sublist
    sublist = sublist.reversed.toList();
// Replace the original sublist with the reversed sublist
    list.replaceRange(arabicIndexes.first, arabicIndexes.last + 1, sublist);

    return list;
  }
}

extension StringConversion on String {
  bool isArabic() {
    return RegExp("[\u0600-\u06FF]").hasMatch(this);
  }

  bool isUrdu() {
    return RegExp(r'[\u0600-\u06ff]+').hasMatch(this);
  }
}
