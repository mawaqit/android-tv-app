import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mawaqit/src/helpers/RouteHelpers.dart';
import 'package:mawaqit/src/helpers/mawaqit_icons_icons.dart';
import 'package:mawaqit/src/helpers/time_utils.dart';
import 'package:mawaqit/src/pages/alert_screen/alert_screen.dart';
import 'package:mawaqit/src/pages/hadith_screens/AfterAdanHadith.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:mawaqit/src/themes/UIShadows.dart';
import 'package:provider/provider.dart';

class HomeTimeWidget extends StatefulWidget {
  const HomeTimeWidget({Key? key}) : super(key: key);

  @override
  State<HomeTimeWidget> createState() => _HomeTimeWidgetState();
}

class _HomeTimeWidgetState extends State<HomeTimeWidget> {
  Future<void> openAzhanScreen(BuildContext context) async {
    await Navigator.push(
      context,
      AlertScreen(
        title: "Al Adan",
        subTitle: "الأذان",
        icon: Image.asset('assets/icon/adhan_icon.png'),
      ).buildRoute(),
    );

    Navigator.push(context, AfterAdanHadith().buildRoute());
  }

  void openIqamaaScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AlertScreen(
          title: "Al Iqama",
          subTitle: "الاقامه",
          duration: Duration(seconds: 5),
          icon: Image.asset('assets/icon/iqama_icon.png'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mosqueManager = context.watch<MosqueManager>();

    return StreamBuilder(
      stream: Stream.periodic(Duration(seconds: 1)),
      builder: (context, snapShot) {
        final now = mosqueManager.mosqueDate();

        print(mosqueManager.nextSalahTime());

        var nextSalahTime = mosqueManager.nextSalahTime().toTimeOfDay()!.toDate().difference(now);
        var nextIqamaTime = mosqueManager
            .nextIqamaTime()
            .toTimeOfDay(
              tryOffset: mosqueManager.nextSalahTime().toTimeOfDay()?.toDate(),
            )!
            .toDate()
            .difference(now);

        // in case of fajr of the next day
        if (nextSalahTime < Duration.zero) {
          nextSalahTime = nextSalahTime + Duration(days: 1);
        }

        if (nextIqamaTime < Duration.zero) {
          nextIqamaTime = nextIqamaTime + Duration(days: 1);
        }

        print(mosqueManager.nextIqamaTime);
        bool showIqama = nextIqamaTime < nextSalahTime;

        /// use debounce to make sure alert will be shown once
        /// and make sure in case of lag it will be fired at least once
        if (nextSalahTime.inSeconds.abs() < 2) {
          print('open home screen ${nextSalahTime.inSeconds}');
          EasyDebounce.debounce(
            'AlertScreen.adan',
            Duration(seconds: 3),
            () => openAzhanScreen(context),
          );
        }
        if (nextIqamaTime.inSeconds.abs() < 2) {
          print('open home screen ${nextSalahTime.inSeconds}');
          EasyDebounce.debounce(
            'AlertScreen.adan',
            Duration(seconds: 3),
            () => openIqamaaScreen(context),
          );
        }

        return Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                color: Color(0xb34e2b81),
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
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
                              fontSize: 50,
                              shadows: kHomeTextShadow,
                            ),
                          ),
                          TextSpan(
                            text: ':${DateFormat('ss').format(now)}',
                            style: TextStyle(
                              color: Colors.white54,
                              fontWeight: FontWeight.bold,
                              fontSize: 50,
                              shadows: kHomeTextShadow,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 30,
                      child: AnimatedTextKit(
                        pause: Duration(seconds: 0),
                        isRepeatingAnimation: true,
                        repeatForever: true,
                        displayFullTextOnTap: true,
                        animatedTexts: [
                          FadeAnimatedText(
                            'Friday, Sep 30, 2022',
                            duration: Duration(seconds: 6),
                            fadeInEnd: .1,
                            fadeOutBegin: .9,
                            textStyle: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              shadows: kHomeTextShadow,
                            ),
                          ),
                          FadeAnimatedText(
                            '04 Rabi Awal 1444',
                            duration: Duration(seconds: 4),
                            fadeInEnd: .1,
                            fadeOutBegin: .9,
                            textStyle: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              shadows: kHomeTextShadow,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(MawaqitIcons.icon_adhan),
                    SizedBox(width: 10),
                    if (showIqama)
                      Text(
                        [
                          "Iqamaa in ",
                          if (nextIqamaTime.inMinutes > 0)
                            "${nextIqamaTime.inHours.toString().padLeft(2, '0')}:${(nextIqamaTime.inMinutes % 60).toString().padLeft(2, '0')} ",
                          if (nextIqamaTime.inMinutes == 0)
                            "${(nextIqamaTime.inSeconds % 60).toString().padLeft(2, '0')} Sec",
                        ].join(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          height: 2,
                          shadows: kHomeTextShadow,
                        ),
                      )
                    else
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
                          fontSize: 18,
                          height: 2,
                          shadows: kHomeTextShadow,
                        ),
                      ),
                    SizedBox(width: 10),
                    Icon(MawaqitIcons.icon_adhan),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// '12'.toint();
