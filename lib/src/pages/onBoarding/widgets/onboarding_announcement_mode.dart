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
              style: theme.textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              tr.announcementOnlyModeEXPLINATION,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.textTheme.bodyLarge?.color?.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
            ToggleButtonWidget(
              isSelected: !userPrefs.announcementsOnly,
              onPressed: _wrapWithOnNext(
                () => userPrefs.announcementsOnly = false,
              ),
              label: tr.normalMode,
              textStyle: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(
                tr.normalModeExplanation,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyLarge?.color?.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 20),
            ToggleButtonWidget(
              isSelected: userPrefs.announcementsOnly,
              onPressed: _wrapWithOnNext(
                () => userPrefs.announcementsOnly = true,
              ),
              label: tr.announcementOnlyMode,
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(
                tr.announcementOnlyModeExplanation,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyLarge?.color?.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ),
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
  final TextStyle? textStyle;

  const ToggleButtonWidget({
    super.key,
    required this.isSelected,
    required this.onPressed,
    required this.label,
    this.textStyle,
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
            child: Text(label, style: textStyle),
          )
        : OutlinedButton(
            onPressed: onPressed,
            child: Text(label, style: textStyle),
          );
  }
}
