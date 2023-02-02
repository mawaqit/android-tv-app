import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:mawaqit/i18n/AppLanguage.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:mawaqit/src/themes/UIShadows.dart';
import 'package:provider/provider.dart';
import 'package:timeago_flutter/timeago_flutter.dart';
import '../../../helpers/StringUtils.dart';
import 'ClockTime.dart';
import 'DateAlternate.dart';
import 'SalahInWidget.dart';

class HomeTimeWidget extends TimerRefreshWidget {
  const HomeTimeWidget({
    Key? key,
    super.refreshRate = const Duration(seconds: 1),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double adhanIconSize = 2.3.vw;
    final mosqueManager = context.watch<MosqueManager>();
    final mosqueConfig = mosqueManager.mosqueConfig;
    final now = mosqueManager.mosqueDate();
    final nextSalahIndex = mosqueManager.nextSalahIndex();
    var nextSalahTime = mosqueManager.actualTimes()[nextSalahIndex].difference(now);
    final lang = context.read<AppLanguage>();
    final isArabicLang = lang.isArabic();
    // in case of fajr of the next day
    if (nextSalahTime < Duration.zero) nextSalahTime = nextSalahTime + Duration(days: 1);

    var hijriDate = HijriCalendar.fromDate(now.add(Duration(
      days: mosqueManager.times!.hijriAdjustment,
    )));

    if (mosqueManager.times!.hijriDateForceTo30) hijriDate.hDay = 30;

    return Padding(
      padding: EdgeInsets.only(left: 1.25.vw),
      child: Container(
        clipBehavior: Clip.antiAlias,
        width: 40.vw,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(.70),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 25.vh,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(20),
                  ),
                  color: mosqueManager.getColorTheme().withOpacity(.7),
                ),
                padding: EdgeInsets.symmetric(vertical: 1.5.vw, horizontal: 5.vw),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    //clock timer
                    ClockTime(),
                    // date time

                    Container(
                      constraints: BoxConstraints(maxWidth: 28.vw),
                      height: 2.5.vw,
                      child: mosqueConfig!.hijriDateEnabled!
                          ? DateAlternate()
                          // when hijri disabled
                          : FittedBox(
                              child: Text(
                                DateFormat(
                                  "EEEE, MMM dd, yyyy",
                                ).format(now),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 2.9.vw,
                                  shadows: kHomeTextShadow,
                                  // letterSpacing: 1,
                                  height: .8,
                                  fontFamily: StringManager.getFontFamily(context),
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
              Padding(
                  padding: EdgeInsets.all(isArabicLang ? 0.1.vw : 2.vh),
                  child: SalahInWidget(
                    adhanIconSize: adhanIconSize,
                    nextSalahTime: nextSalahTime,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

// '12'.toint();
