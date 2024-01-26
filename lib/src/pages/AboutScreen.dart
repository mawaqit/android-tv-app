import 'package:flutter/material.dart';
import 'package:mawaqit/const/resource.dart';
import 'package:mawaqit/src/pages/onBoarding/widgets/MawaqitAboutWidget.dart';
import 'package:mawaqit/src/widgets/ScreenWithAnimation.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScreenWithAnimationWidget(
        animation: R.ASSETS_ANIMATIONS_LOTTIE_WELCOME_JSON,
        child: OnBoardingMawaqitAboutWidget(),
      ),
    );
  }
}
