import 'package:flutter/material.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/services/user_preferences_manager.dart';
import 'package:provider/provider.dart';

class OnBoardingAnnouncementScreens extends StatelessWidget {
  final VoidCallback? onNext;
  final bool isOnboarding;

  const OnBoardingAnnouncementScreens({
    super.key,
    this.onNext,
    this.isOnboarding = false,
  });

  VoidCallback _wrapWithOnNext(VoidCallback callback) {
    return () {
      callback();
      if (!isOnboarding) {
        onNext?.call();
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    final userPrefs = context.watch<UserPreferencesManager>();
    final theme = Theme.of(context);
    final tr = S.of(context);

    return Material(
      child: FractionallySizedBox(
        widthFactor: .75,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              tr.announcementOnlyMode,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(fontSize: 25),
            ),
            SizedBox(height: 10),
            Text(
              tr.announcementOnlyModeEXPLINATION,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            ToggleButtonWidget(
              isSelected: !userPrefs.announcementsOnly,
              onPressed: _wrapWithOnNext(
                () => userPrefs.announcementsOnly = false,
              ),
              label: tr.normalMode,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(tr.normalModeExplanation, textAlign: TextAlign.center),
            ),
            SizedBox(height: 20),
            ToggleButtonWidget(
              isSelected: userPrefs.announcementsOnly,
              onPressed: _wrapWithOnNext(
                () => userPrefs.announcementsOnly = true,
              ),
              label: tr.announcementOnlyMode,
            ),
            Text(tr.announcementOnlyModeExplanation, textAlign: TextAlign.center),
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
