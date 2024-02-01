import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mawaqit/const/resource.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/widgets/InfoWidget.dart';
import 'package:provider/provider.dart';

import '../../../services/user_preferences_manager.dart';

class HomeLogoVersion extends StatefulWidget {
  const HomeLogoVersion({Key? key}) : super(key: key);

  @override
  _HomeLogoVersionState createState() => _HomeLogoVersionState();
}

class _HomeLogoVersionState extends State<HomeLogoVersion> {
  int tapCount = 0;

  static const int _activationTapCount = 7;
  static const String _activationMessage = "You have activated the Abogabal secret menu 😎💪 رائع! لقد قمت بتنشيط قائمة أبو جبل السرية";
  static const String _deactivationMessage = "You have deactivated the Abogabal secret menu 😎💪 رائع! لقد قمت بإلغاء تنشيط قائمة أبو جبل السرية";

  void _handleTap() {
    final userPreferencesManager = Provider.of<UserPreferencesManager>(context, listen: false);
    if (userPreferencesManager.developerModeEnabled) {
      userPreferencesManager.developerModeEnabled = false;
      _showSnackBar(_deactivationMessage);
    } else {
      tapCount++;
      if (tapCount >= _activationTapCount) {
        userPreferencesManager.developerModeEnabled = true;
        _showSnackBar(_activationMessage);
        tapCount = 0; // Reset tapCount after activation
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              _handleTap();
            },
            child: SvgPicture.asset(
              R.ASSETS_SVG_MAWAQIT_LOGO_TEXT_LIGHT_SVG,
              height: 3.8.vwr,
            ),
          ),
          Align(
            heightFactor: .5,
            alignment: Alignment(.5, 0),
            child: Container(
              padding:
                  EdgeInsets.symmetric(horizontal: .5.vwr, vertical: .4.vh),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(5),
                  bottom: Radius.circular(10),
                ),
              ),
              child: VersionWidget(
                style: TextStyle(color: Colors.white, fontSize: 1.vwr),
              ),
            ),
          ),
          // ... rest of the widget tree remains unchanged
        ],
      ),
    );
  }
}
