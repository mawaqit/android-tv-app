import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/helpers/mawaqit_icons_icons.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:mawaqit/src/themes/UIShadows.dart';
import 'package:provider/provider.dart';
import 'package:timeago_flutter/timeago_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomeTimeWidget extends TimerRefreshWidget {
  const HomeTimeWidget({
    Key? key,
    super.refreshRate = const Duration(seconds: 1),
  }) : super(key: key);

  // Future<void> openAzhanScreen(BuildContext context) async {
  //   await Navigator.push(
  //     context,
  //     AlertScreen(
  //       title: "Al Adan",
  //       subTitle: "الأذان",
  //       icon: Image.asset('assets/icon/adhan_icon.png'),
  //     ).buildRoute(),
  //   );
  //
  //   Navigator.push(context, AfterAdanHadith().buildRoute());
  // }
  //
  // void openIqamaaScreen(BuildContext context) {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => AlertScreen(
  //         title: "Al Iqama",
  //         subTitle: "الاقامه",
  //         duration: Duration(seconds: 5),
  //         icon: Image.asset('assets/icon/iqama_icon.png'),
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final mosqueManager = context.watch<MosqueManager>();
    final now = mosqueManager.mosqueDate();
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final nextSalahIndex = mosqueManager.nextSalahIndex();
    var nextSalahTime = mosqueManager.actualTimes()[nextSalahIndex].difference(now);

    // in case of fajr of the next day
    if (nextSalahTime < Duration.zero) nextSalahTime = nextSalahTime + Duration(days: 1);

    var hijriDate = HijriCalendar.fromDate(now.add(Duration(
      days: mosqueManager.times!.hijriAdjustment,
    )));
    bool isLunarDays = hijriDate.hDay==13||hijriDate.hDay==14||hijriDate.hDay==15;
    if (isArabic) {
      HijriCalendar.language = 'ar';
    } else {
      HijriCalendar.language = 'en';
    }

    if (mosqueManager.times!.hijriDateForceTo30) hijriDate.hDay = 30;
    final mosqueConfig = mosqueManager.mosqueConfig;
    bool is12hourFormat = mosqueConfig?.timeDisplayFormat == "12";
    return Container(
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
              color: mosqueManager.getColorTheme().withOpacity(.7),
              padding: EdgeInsets.symmetric(vertical: 1.5.vw, horizontal: 5.vw),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        DateFormat(
                          "${is12hourFormat ? "hh:mm" : "HH:mm"}",
                          'en',
                        ).format(now),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 8.vw,
                          shadows: kHomeTextShadow,
                          color: Colors.white,
                          height: 1,
                          // letterSpacing: 1,
                        ),
                      ),

                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            ':${DateFormat('ss', 'en').format(now)}',
                            style: TextStyle(
                              color: Colors.white54,
                              fontWeight: FontWeight.bold,
                              fontSize: is12hourFormat?4.vw:6.vw,
                              shadows: kHomeTextShadow,
                              height: is12hourFormat?1:null,
                              // letterSpacing: 1.vw,
                            ),
                          ),
                          if (is12hourFormat)
                            Padding(
                              padding: EdgeInsets.only(bottom: .6.vh,left: .9.vw),
                              child: Text(
                                '${DateFormat('a', "en").format(now)}',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 3.2.vw,
                                  shadows: kHomeTextShadow,
                                  height: .9,
                                  // letterSpacing: 1.vw,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 2.5.vw,
                    child: mosqueConfig!.hijriDateEnabled!? Row(
                      children: [
                        Expanded(
                          child: FittedBox(
                            child: Center(
                              child: AnimatedTextKit(
                                key: ValueKey('122'),
                                isRepeatingAnimation: true,
                                repeatForever: true,
                                displayFullTextOnTap: true,
                                animatedTexts: [
                                  FadeAnimatedText(
                                    DateFormat("EEEE, MMM dd, yyyy",).format(now),
                                    duration: Duration(seconds: 6),
                                    fadeInEnd: 200 / 10000,
                                    fadeOutBegin: 1,
                                    textStyle: TextStyle(
                                      color: Colors.white,
                                      fontSize: 2.3.vw,
                                      shadows: kHomeTextShadow,
                                      // letterSpacing: 1,
                                      height: .8,
                                      fontFamily: isArabic ? 'kufi' : null,
                                    ),
                                  ),
                                  FadeAnimatedText(
                                    hijriDate.format(
                                      hijriDate.hYear,
                                      hijriDate.hMonth,
                                      hijriDate.hDay,
                                      "dd MMMM yyyy",
                                    ),
                                    duration: Duration(seconds: 4),
                                    fadeInEnd: 200 / 4000,
                                    fadeOutBegin: 1,
                                    textStyle: TextStyle(
                                      color: Colors.white,
                                      fontSize: 2.3.vw,
                                      shadows: kHomeTextShadow,
                                      height: .8,
                                      fontFamily: isArabic ? 'kufi' : null,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        if(isLunarDays)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: FaIcon(FontAwesomeIcons.solidMoon,size: 2.5.vw,),
                          ),
                        )
                      ],
                    ):Text(
                      DateFormat("EEEE, MMM dd, yyyy",).format(now),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 2.3.vw,
                        shadows: kHomeTextShadow,
                        // letterSpacing: 1,
                        height: .8,
                        fontFamily: isArabic ? 'kufi' : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(1.vw),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    MawaqitIcons.icon_adhan,
                    color: Colors.white,
                  ),
                  SizedBox(width: 1.5.vw),
                  Text(
                    [
                      "${mosqueManager.salahName(mosqueManager.nextSalahIndex())} in ",
                      if (nextSalahTime.inMinutes > 0)
                        "${nextSalahTime.inHours.toString().padLeft(2, '0')}:${(nextSalahTime.inMinutes % 60).toString().padLeft(2, '0')} ",
                      if (nextSalahTime.inMinutes == 0)
                        "${(nextSalahTime.inSeconds % 60).toString().padLeft(2, '0')} Sec",
                    ].join(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 3.vw,
                      // height: 2,
                      color: Colors.white,
                      shadows: kHomeTextShadow,
                    ),
                  ),
                  SizedBox(width: 1.5.vw),
                  Icon(
                    MawaqitIcons.icon_adhan,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            SizedBox(height: .5.vw),
          ],
        ),
      ),
    );
  }
}

// '12'.toint();
