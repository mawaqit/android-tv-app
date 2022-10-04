import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:mawaqit/src/helpers/mawaqit_icons_icons.dart';
import 'package:mawaqit/src/themes/UIShadows.dart';

class HomeTimeWidget extends StatelessWidget {
  const HomeTimeWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                        text: '06:15',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 50,
                          shadows: kHomeTextShadow,
                        ),
                      ),
                      TextSpan(
                        text: ':08',
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
                    key: GlobalKey(),
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
                Text(
                  "Asr in 01:00",
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
  }
}
