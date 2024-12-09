import 'package:flutter/material.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:mawaqit/src/services/user_preferences_manager.dart';
import 'package:provider/provider.dart';
import '../../../../i18n/l10n.dart';
import 'OrientationWidget.dart';

class OnBoardingScreenType extends StatelessWidget {
  final VoidCallback? onDone;
  final bool isOnboarding;

  // Private constructor
  const OnBoardingScreenType._({
    Key? key,
    required this.isOnboarding,
    this.onDone,
  }) : super(key: key);

  // Factory constructor for normal mode
  factory OnBoardingScreenType({
    Key? key,
    required VoidCallback onDone,
  }) {
    return OnBoardingScreenType._(
      key: key,
      isOnboarding: false,
      onDone: onDone,
    );
  }

  // Factory constructor for onboarding mode
  factory OnBoardingScreenType.onboarding({
    Key? key,
  }) {
    return OnBoardingScreenType._(
      key: key,
      isOnboarding: true,
    );
  }

  // Helper method to wrap callbacks with onDone
  VoidCallback _wrapWithOnDone(VoidCallback callback) {
    return () {
      callback();
      if (!isOnboarding) {
        onDone?.call();
      }
    };
  }

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
              tr.mainScreenOrSecondaryScreen,
              style: theme.textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            Text(
              tr.mainScreenOrSecondaryScreenEXPLINATION,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 50),
            ToggleButtonWidget(
              isSelected: !userPrefs.isSecondaryScreen,
              onPressed: _wrapWithOnDone(
                () => userPrefs.isSecondaryScreen = false,
              ),
              label: tr.mainScreen,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(tr.mainScreenExplanation, textAlign: TextAlign.center),
            ),
            SizedBox(height: 20),
            ToggleButtonWidget(
              isSelected: userPrefs.isSecondaryScreen,
              onPressed: _wrapWithOnDone(
                () => userPrefs.isSecondaryScreen = true,
              ),
              label: tr.secondaryScreen,
            ),
            Text(tr.secondaryScreenExplanation, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
