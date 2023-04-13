import 'package:flutter/material.dart';
import 'package:mawaqit/src/helpers/SharedPref.dart';

const kOnBoardingKey = 'boarding';

/// this class is responsible for managing the on-boarding process
/// including the tutorial and the welcome screen
class OnBoardingManager extends ChangeNotifier {
  OnBoardingManager();

  bool firstOnBoarding = false;

  Future<void> init() async {
    firstOnBoarding = await SharedPref().readDynamic(kOnBoardingKey) ?? true;
  }

  Future<void> onBoardingDone() async {
    firstOnBoarding = false;
    await SharedPref().setDynamic(kOnBoardingKey, false);
    notifyListeners();
  }
}
