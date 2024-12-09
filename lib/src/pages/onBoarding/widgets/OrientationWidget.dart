import 'package:flutter/material.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/services/user_preferences_manager.dart';
import 'package:provider/provider.dart';

class OnBoardingOrientationWidget extends StatelessWidget {
  const OnBoardingOrientationWidget({Key? key}) : super(key: key);

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
            ToggleButtonWidget(
              isSelected: userPrefs.orientationLandscape,
              onPressed: () => userPrefs.orientationLandscape = true,
              label: tr.landscape,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(tr.landscapeBTNDescription, textAlign: TextAlign.center),
            ),
            SizedBox(height: 20),
            ToggleButtonWidget(
              isSelected: !userPrefs.orientationLandscape,
              onPressed: () => userPrefs.orientationLandscape = false,
              label: tr.portrait,
            ),
            Text(tr.portraitBTNDescription, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class ToggleButtonWidget extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onPressed;
  final String label;

  const ToggleButtonWidget({
    super.key,
    required this.isSelected,
    required this.onPressed,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return isSelected
        ? ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: Text(label),
          )
        : OutlinedButton(
            onPressed: onPressed,
            child: Text(label),
          );
  }
}
