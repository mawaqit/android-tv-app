import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/helpers/mawaqit_icons_icons.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:mawaqit/src/themes/UIShadows.dart';
import 'package:provider/provider.dart';
import 'package:timeago_flutter/timeago_flutter.dart';

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
    final nextSalahIndex = mosqueManager.nextSalahIndex();
    var nextSalahTime = mosqueManager.actualTimes()[nextSalahIndex].difference(now);

    // in case of fajr of the next day
    if (nextSalahTime < Duration.zero) nextSalahTime = nextSalahTime + Duration(days: 1);

    var hijriDate = HijriCalendar.fromDate(now.add(Duration(
      days: mosqueManager.times!.hijriAdjustment,
    )));

    if (mosqueManager.times!.hijriDateForceTo30) hijriDate.hDay = 30;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(.70),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            color: Color(0xb34e2b81),
            padding: EdgeInsets.symmetric(vertical: 1.vw, horizontal: 5.vw),
            child: Column(
              children: [
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: DateFormat('HH:mm').format(now),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 8.vw,
                          shadows: kHomeTextShadow,
                          color: Colors.white,
                          // letterSpacing: 1,
                        ),
                      ),
                      TextSpan(
                        text: ':${DateFormat('ss').format(now)}',
                        style: TextStyle(
                          color: Colors.white54,
                          fontWeight: FontWeight.bold,
                          fontSize: 7.5.vw,
                          shadows: kHomeTextShadow,
                          // letterSpacing: 1.vw,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 3.2.vw,
                  child: AnimatedTextKit(
                    key: ValueKey('122'),
                    isRepeatingAnimation: true,
                    repeatForever: true,
                    displayFullTextOnTap: true,
                    animatedTexts: [
                      FadeAnimatedText(
                        DateFormat("EEEE, MMM dd, yyyy").format(now),
                        duration: Duration(seconds: 6),
                        fadeInEnd: 200 / 10000,
                        fadeOutBegin: 1,
                        textStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 2.3.vw,
                          shadows: kHomeTextShadow,
                          letterSpacing: 1,
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
                          letterSpacing: 1,
                        ),
                      ),
                    ],
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
    );
  }
}

// '12'.toint();
