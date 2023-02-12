import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mawaqit/src/helpers/DateUtils.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/helpers/StringUtils.dart';
import 'package:mawaqit/src/models/MawaqitHijriCalendar.dart';
import 'package:mawaqit/src/pages/home/widgets/FadeInOut.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:mawaqit/src/themes/UIShadows.dart';
import 'package:provider/provider.dart';

import '../../../helpers/weather_icons.dart';

class HomeDateWidget extends StatelessWidget {
  const HomeDateWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mosqueManager = context.watch<MosqueManager>();
    final now = mosqueManager.mosqueDate();
    final lang = Localizations.localeOf(context).languageCode;

    var hijriDate = MawaqitHijriCalendar.fromDateWithAdjustments(
      now,
      force30Days: mosqueManager.times!.hijriDateForceTo30,
      adjustment: mosqueManager.times!.hijriAdjustment,
    );

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Container(
        constraints: BoxConstraints(
          minWidth: 1,
          minHeight: 1,
        ),
        child: FadeInOutWidget(
          duration: Duration(seconds: 10),
          disableSecond: mosqueManager.mosqueConfig!.hijriDateEnabled == false,
          first: Text(
            now.formatIntoMawaqitFormat(local: lang),
            style: TextStyle(
              color: Colors.white,
              fontSize: 2.7.vw,
              shadows: kHomeTextShadow,
              fontFamily: StringManager.getFontFamilyByString(
                now.formatIntoMawaqitFormat(local: lang),
              ),
              height: .8,
            ),
          ),
          secondDuration: Duration(seconds: 10),
          second: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                hijriDate.formatMawaqitType(),
                textDirection: hijriDate.formatMawaqitType().isArabic()
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 2.5.vw,
                  shadows: kHomeTextShadow,
                  fontFamily: StringManager.getFontFamilyByString(
                    hijriDate.formatMawaqitType(),
                  ),
                ),
              ),
              if (hijriDate.isInLunarDays)
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: .5.vw,
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
