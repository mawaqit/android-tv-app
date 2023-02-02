import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:persian_number_utility/persian_number_utility.dart';
import 'package:provider/provider.dart';

import '../../../../i18n/AppLanguage.dart';
import '../../../helpers/StringUtils.dart';
import '../../../services/mosque_manager.dart';
import '../../../themes/UIShadows.dart';

class DateAlternate extends StatelessWidget {
  const DateAlternate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mosqueManager = context.watch<MosqueManager>();
    final now = mosqueManager.mosqueDate();
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final nextSalahIndex = mosqueManager.nextSalahIndex();
    var nextSalahTime =
    mosqueManager.actualTimes()[nextSalahIndex].difference(now);
    final lang = context.read<AppLanguage>();
    // in case of fajr of the next day
    if (nextSalahTime < Duration.zero)
      nextSalahTime = nextSalahTime + Duration(days: 1);

    var hijriDate = HijriCalendar.fromDate(now.add(Duration(
      days: mosqueManager.times!.hijriAdjustment,
    )));
    bool isLunarDays =
        hijriDate.hDay == 13 || hijriDate.hDay == 14 || hijriDate.hDay == 15;
    if (isArabic) {
      HijriCalendar.language = 'ar';
    } else {
      HijriCalendar.language = 'en';
    }

    if (mosqueManager.times!.hijriDateForceTo30) hijriDate.hDay = 30;
    final mosqueConfig = mosqueManager.mosqueConfig;
    bool is12hourFormat = mosqueConfig?.timeDisplayFormat == "12";

    String arabicFormat = [
      DateFormat(
        'EEEE,',
        lang.appLocal.languageCode,
      ).format(now),
      DateFormat('dd', 'en').format(now),
      DateFormat(
        'MMMM,',
        lang.appLocal.languageCode,
      ).format(now),
      DateFormat('yyyy', 'en').format(now),
    ].join(' ');

    String defaultDateFormat = [
      DateFormat(
        'EEEE,',
        lang.appLocal.languageCode,
      ).format(now),
      DateFormat(
        'MMMM',
        lang.appLocal.languageCode,
      ).format(now),
      DateFormat('dd,', 'en').format(now),
      DateFormat('yyyy', 'en').format(now),
    ].join(' ');

    String activeDate =
    lang.appLocal.languageCode == 'ar' || lang.appLocal.languageCode == 'fr'
        ? arabicFormat
        : defaultDateFormat;

    return Row(
      children: [
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Container(
              constraints: BoxConstraints(
                  minWidth: 1, minHeight: 1),
              child: AnimatedTextKit(
                key: ValueKey('122'),
                isRepeatingAnimation: true,
                repeatForever: true,
                displayFullTextOnTap: true,
                animatedTexts: [
                  FadeAnimatedText(
                    activeDate,
                    duration: Duration(seconds: 6),
                    fadeInEnd: 200 / 10000,
                    fadeOutBegin: 1,
                    textStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 2.7.vw,
                      shadows: kHomeTextShadow,
                      // letterSpacing: 1,
                      height: .8,
                      fontFamily: isArabic
                          ? StringManager.getFontFamily(
                          context)
                          : null,
                    ),
                  ),
                  FadeAnimatedText(
                    "${hijriDate.toFormat("DD ")}${hijriDate.toFormat("dd").toEnglishDigit()} ${hijriDate.toFormat("MMMM")} ${hijriDate.toFormat("yyyy").toEnglishDigit()} ",
                    duration: Duration(seconds: 4),
                    fadeInEnd: 200 / 4000,
                    fadeOutBegin: 1,
                    textStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 2.5.vw,
                      shadows: kHomeTextShadow,
                      height: .8,
                      fontFamily: isArabic
                          ? StringManager.getFontFamily(
                          context)
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (isLunarDays)
          Positioned(
            right: -2.5.vw,
            child: FaIcon(
              FontAwesomeIcons.solidMoon,
              size: 2.5.vw,
            ),
          )
      ],
    );
  }
}
