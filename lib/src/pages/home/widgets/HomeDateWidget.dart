import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/helpers/StringUtils.dart';
import 'package:mawaqit/src/pages/home/widgets/FadeInOut.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:mawaqit/src/themes/UIShadows.dart';
import 'package:persian_number_utility/persian_number_utility.dart';
import 'package:provider/provider.dart';

class HomeDateWidget extends StatelessWidget {
  const HomeDateWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mosqueManager = context.watch<MosqueManager>();
    final now = mosqueManager.mosqueDate();
    final lang = Localizations.localeOf(context).languageCode;

    var hijriDate = HijriCalendar.fromDate(now.add(Duration(days: mosqueManager.times!.hijriAdjustment)));

    bool isLunarDays = hijriDate.hDay == 13 || hijriDate.hDay == 14 || hijriDate.hDay == 15;

    if (lang == 'ar') {
      HijriCalendar.language = 'ar';
    } else {
      HijriCalendar.language = 'en';
    }

    if (mosqueManager.times!.hijriDateForceTo30) hijriDate.hDay = 30;

    String arabicFormat = [
      DateFormat('EEEE,', lang).format(now),
      DateFormat('dd', 'en').format(now),
      DateFormat('MMMM,', lang).format(now),
      DateFormat('yyyy', 'en').format(now),
    ].join(' ');

    String defaultDateFormat = [
      DateFormat('EEEE,', lang).format(now),
      DateFormat('MMMM').format(now),
      DateFormat('dd,', 'en').format(now),
      DateFormat('yyyy', 'en').format(now),
    ].join(' ');

    String activeDate = lang == 'ar' || lang == 'fr' ? arabicFormat : defaultDateFormat;

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Container(
        constraints: BoxConstraints(
          minWidth: 1,
          minHeight: 1,
        ),
        child: FadeInOutWidget(
          duration: Duration(seconds: 10),
          first: Text(
            activeDate,
            style: TextStyle(
              color: Colors.white,
              fontSize: 2.7.vw,
              shadows: kHomeTextShadow,
              // letterSpacing: 1,
              height: .8,
            ),
          ),
          secondDuration: Duration(seconds: 10),
          second: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${hijriDate.toFormat("DD ")}${hijriDate.toFormat("dd").toEnglishDigit()} ${hijriDate.toFormat("MMMM")} ${hijriDate.toFormat("yyyy").toEnglishDigit()} ",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 2.5.vw,
                  shadows: kHomeTextShadow,
                  height: .8,
                  fontFamily: StringManager.getFontFamily(context),
                ),
              ),
              if (isLunarDays)
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: .2.vw,
                  ),
                  child: FaIcon(
                    FontAwesomeIcons.solidMoon,
                    size: 1.8.vw,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
