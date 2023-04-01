import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:mawaqit/const/resource.dart';
import 'package:mawaqit/src/pages/onBoarding/widgets/MawaqitAboutWidget.dart';
import 'package:mawaqit/src/services/user_preferences_manager.dart';
import 'package:provider/provider.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int tapCount = 0;
    return CallbackShortcuts(
      bindings: {
        SingleActivator(LogicalKeyboardKey.arrowDown): () {
          tapCount++;
          if (tapCount >= 7) {
            context.read<UserPreferencesManager>().developerModeEnabled = true;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text("You have activated the Abogabal secret menu 😎💪 رائع! لقد قمت بتنشيط قائمة أبو جبل السرية"),
              ),
            );
            tapCount = 0;
            return;
          }

          EasyDebounce.debounce('tag', Duration(milliseconds: 2000), () {
            tapCount = 0;
          });
        },
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          body: Row(
            children: [
              Expanded(
                flex: 4,
                child: Align(
                  child: Lottie.asset(
                    R.ASSETS_ANIMATIONS_LOTTIE_WELCOME_JSON,
                    fit: BoxFit.contain,
                  ),
                  alignment: Alignment.center,
                ),
              ),
              Expanded(
                flex: 6,
                child: OnBoardingMawaqitAboutWidget(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
