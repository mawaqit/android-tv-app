import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mawaqit/const/resource.dart';
import 'package:mawaqit/src/pages/onBoarding/widgets/MawaqitAboutWidget.dart';
import 'package:mawaqit/src/services/user_preferences_manager.dart';
import 'package:mawaqit/src/widgets/ScreenWithAnimation.dart';
import 'package:provider/provider.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int tapCount = 0;
    return Focus(
      onKeyEvent: (node, event) {
        if (event.logicalKey != LogicalKeyboardKey.arrowDown) return KeyEventResult.ignored;

        tapCount++;
        if (tapCount >= 7) {
          context.read<UserPreferencesManager>().developerModeEnabled = true;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text("You have activated the Abogabal secret menu 😎💪 رائع! لقد قمت بتنشيط قائمة أبو جبل السرية"),
            ),
          );
          tapCount = -100;
          return KeyEventResult.handled;
        }

        EasyDebounce.debounce('tag', Duration(milliseconds: 2000), () {
          tapCount = 0;
        });
        return KeyEventResult.handled;
      },
      canRequestFocus: true,
      autofocus: true,
      child: Scaffold(
        body: ScreenWithAnimationWidget(
          animation: R.ASSETS_ANIMATIONS_LOTTIE_WELCOME_JSON,
          child: OnBoardingMawaqitAboutWidget(),
        ),
      ),
    );
  }
}
