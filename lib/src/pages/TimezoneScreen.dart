import 'package:flutter/material.dart';
import 'package:mawaqit/const/resource.dart';
import 'package:mawaqit/src/pages/onBoarding/widgets/onboarding_timezone_selector.dart';
import 'package:mawaqit/src/widgets/ScreenWithAnimation.dart';

import '../helpers/AppRouter.dart';

class TimezoneScreen extends StatelessWidget {
  final void Function(String)? onSelect;

  TimezoneScreen({
    Key? key,
    this.onSelect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenWithAnimationWidget(
      animation: R.ASSETS_ANIMATIONS_LOTTIE_CONFIG_JSON,
      child: OnBoardingTimeZoneSelector(onSelect: AppRouter.pop),
    );
  }
}
