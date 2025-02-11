import 'package:flutter/material.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/services/user_preferences_manager.dart';
import 'package:provider/provider.dart';

class OnBoardingOrientationWidget extends StatelessWidget {
  final VoidCallback? onNext;
  final bool isOnboarding;
  final FocusNode? nextButtonFocusNode;
  final FocusNode? previousButtonFocusNode;

  // Private constructor
  const OnBoardingOrientationWidget._({
    Key? key,
    required this.isOnboarding,
    this.nextButtonFocusNode,
    this.previousButtonFocusNode,
    this.onNext,
  }) : super(key: key);

  // Factory constructor for normal mode
  factory OnBoardingOrientationWidget({
    Key? key,
    required VoidCallback onNext,
  }) {
    return OnBoardingOrientationWidget._(
      key: key,
      isOnboarding: false,
      onNext: onNext,
    );
  }

  // Factory constructor for onboarding mode
  factory OnBoardingOrientationWidget.onboarding({
    required FocusNode nextButtonFocusNode,
    required FocusNode previousButtonFocusNode,
    Key? key,
  }) {
    return OnBoardingOrientationWidget._(
      key: key,
      isOnboarding: true,
      nextButtonFocusNode: nextButtonFocusNode,
      previousButtonFocusNode: previousButtonFocusNode,
    );
  }

  // Helper method to wrap callbacks with onNext if available
  VoidCallback _wrapWithOnNext(VoidCallback callback) {
    return () {
      if(nextButtonFocusNode != null) nextButtonFocusNode!.requestFocus();
      callback();
      if (!isOnboarding) {
        onNext?.call();
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
              tr.orientation,
              style: theme.textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              tr.selectYourMawaqitTvAppOrientation,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.textTheme.bodyLarge?.color?.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
            ToggleButtonWidget(
              isSelected: userPrefs.orientationLandscape,
              onPressed: _wrapWithOnNext(
                () => userPrefs.orientationLandscape = true,
              ),
              label: tr.landscape,
              textStyle: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(tr.landscapeBTNDescription,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyLarge?.color?.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center),
            ),
            SizedBox(height: 20),
            ToggleButtonWidget(
              isSelected: !userPrefs.orientationLandscape,
              onPressed: _wrapWithOnNext(
                () => userPrefs.orientationLandscape = false,
              ),
              label: tr.portrait,
            ),
            SizedBox(height: 10),
            Text(
              tr.portraitBTNDescription,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyLarge?.color?.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
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
  final TextStyle? textStyle; // Add this line

  const ToggleButtonWidget({
    super.key,
    required this.isSelected,
    required this.onPressed,
    required this.label,
    this.textStyle, // Add this line
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
            child: Text(label, style: textStyle), // Add style here
          )
        : OutlinedButton(
            onPressed: onPressed,
            child: Text(label, style: textStyle), // Add style here
          );
  }
}
