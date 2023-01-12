import 'package:flutter/material.dart';
import 'package:mawaqit/src/helpers/SharedPref.dart';

const _developerModeKey = 'DeveloperMode.enabled';

class DeveloperManager extends ChangeNotifier {
  bool developerModeEnabled = false;

  DeveloperManager() {
    init();
  }

  init() async {
    final value = await SharedPref().read(_developerModeKey);

    if (value is bool) {
      developerModeEnabled = value;
      notifyListeners();
    }
  }

  enableDeveloperOptions() async {
    developerModeEnabled = true;
    notifyListeners();

    await SharedPref().save(_developerModeKey, true);
  }
}
