import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:mawaqit/src/services/user_preferences_manager.dart';
import 'package:mawaqit/src/widgets/ScreenWithAnimation.dart';
import 'package:mawaqit/src/pages/onBoarding/widgets/widgets.dart';
import 'package:mawaqit/const/resource.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);
  static const int _activationTapCount = 7;
  static const String _activationMessage =
      "You have activated the Abogabal secret menu 😎💪 رائع! لقد قمت بتنشيط قائمة أبو جبل السرية";
  static const String _deactivationMessage =
      "You have deactivated the Abogabal secret menu 😎💪 رائع! لقد قمت بإلغاء تنشيط قائمة أبو جبل السرية";
  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    int tapCount = 0;
    bool menuActivated = Provider.of<UserPreferencesManager>(context, listen: false).developerModeEnabled;

    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (RawKeyEvent event) {
        if (event.logicalKey == LogicalKeyboardKey.arrowDown && event is RawKeyDownEvent) {
          if (!menuActivated) {
            tapCount++;
            if (tapCount >= _activationTapCount) {
              menuActivated = true;
              Provider.of<UserPreferencesManager>(context, listen: false).developerModeEnabled = true;
              _showSnackBar(context, _activationMessage);
              tapCount = 0;
            }
          } else {
            menuActivated = false;
            Provider.of<UserPreferencesManager>(context, listen: false).developerModeEnabled = false;
            _showSnackBar(context, _deactivationMessage);
          }
        }
      },
      child: Scaffold(
        body: ScreenWithAnimationWidget(
          animation: R.ASSETS_ANIMATIONS_LOTTIE_WELCOME_JSON,
          child: OnBoardingMawaqitAboutWidget(),
        ),
      ),
    );
  }
}
