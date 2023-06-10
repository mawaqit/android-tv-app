import 'package:flutter/material.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/services/user_preferences_manager.dart';
import 'package:provider/provider.dart';

class OnBoardingOrientationWidget extends StatelessWidget {
  const OnBoardingOrientationWidget({Key? key, this.onSelect}) : super(key: key);

  final VoidCallback? onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userPrefs = context.watch<UserPreferencesManager>();

    final tr = S.of(context);

    return Material(
      child: FractionallySizedBox(
        widthFactor: .75,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              tr.orientation,
              style: theme.textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            Text(tr.selectYourMawaqitTvAppOrientation, style: theme.textTheme.titleMedium, textAlign: TextAlign.center),
            SizedBox(height: 50),
            OutlinedButton(
              onFocusChange: (value) {
                if (value) userPrefs.orientationLandscape = true;
              },
              onPressed: onSelect,
              child: Text(tr.landscape),
              autofocus: userPrefs.calculatedOrientation == Orientation.landscape,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(tr.landscapeBTNDescription, textAlign: TextAlign.center),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: OutlinedButton(
                onFocusChange: (value) {
                  if (value) userPrefs.orientationLandscape = false;
                },
                onPressed: onSelect,
                child: Text(tr.portrait),
                autofocus: userPrefs.calculatedOrientation == Orientation.portrait,
              ),
            ),
            Text(tr.portraitBTNDescription, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
