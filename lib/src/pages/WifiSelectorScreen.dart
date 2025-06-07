import 'package:flutter/material.dart';
import 'package:mawaqit/const/resource.dart';
import 'package:mawaqit/src/pages/onBoarding/widgets/widgets.dart';
import 'package:mawaqit/src/widgets/ScreenWithAnimation.dart';

import '../helpers/AppRouter.dart';

class WifiSelectorScreen extends StatelessWidget {
  final void Function(String)? onSelect;

  WifiSelectorScreen({
    Key? key,
    this.onSelect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenWithAnimationWidget(
      animation: R.ASSETS_ANIMATIONS_LOTTIE_SETTINGS_JSON,
      child: OnBoardingWifiSelector(onSelect: AppRouter.pop),
    );
  }
}
