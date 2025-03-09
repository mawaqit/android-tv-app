import 'package:flutter/material.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/services/user_preferences_manager.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
      if (nextButtonFocusNode != null) nextButtonFocusNode!.requestFocus();
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

    // Responsive font sizes based on screen width
    final double headerFontSize = 20.sp;
    final double subtitleFontSize = 12.sp;
    final double buttonFontSize = 12.sp;
    final double descriptionFontSize = 10.sp;

    return Material(
      child: FractionallySizedBox(
        widthFactor: .75,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(theme, tr, headerFontSize, subtitleFontSize),
            SizedBox(height: 2.h),
            _buildOrientationOptions(
              theme: theme,
              tr: tr,
              userPrefs: userPrefs,
              buttonFontSize: buttonFontSize,
              descriptionFontSize: descriptionFontSize,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the header section with title and subtitle
  Widget _buildHeader(
    ThemeData theme,
    AppLocalizations tr,
    double headerFontSize,
    double subtitleFontSize,
  ) {
    return Column(
      children: [
        Text(
          tr.orientation,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontSize: headerFontSize,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 2.h),
        Text(
          tr.selectYourMawaqitTvAppOrientation,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.textTheme.bodyLarge?.color?.withOpacity(0.8),
            fontSize: subtitleFontSize,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Builds the orientation options (landscape and portrait)
  Widget _buildOrientationOptions({
    required ThemeData theme,
    required AppLocalizations tr,
    required UserPreferencesManager userPrefs,
    required double buttonFontSize,
    required double descriptionFontSize,
  }) {
    return Column(
      children: [
        // Landscape option
        _buildOrientationOption(
          theme: theme,
          isSelected: userPrefs.orientationLandscape,
          onToggle: () => userPrefs.orientationLandscape = true,
          label: tr.landscape,
          description: tr.landscapeBTNDescription,
          buttonFontSize: buttonFontSize,
          descriptionFontSize: descriptionFontSize,
        ),

        SizedBox(height: 3.h),

        // Portrait option
        _buildOrientationOption(
          theme: theme,
          isSelected: !userPrefs.orientationLandscape,
          onToggle: () => userPrefs.orientationLandscape = false,
          label: tr.portrait,
          description: tr.portraitBTNDescription,
          buttonFontSize: buttonFontSize,
          descriptionFontSize: descriptionFontSize,
        ),
      ],
    );
  }

  /// Builds a single orientation option with button and description
  Widget _buildOrientationOption({
    required ThemeData theme,
    required bool isSelected,
    required VoidCallback onToggle,
    required String label,
    required String description,
    required double buttonFontSize,
    required double descriptionFontSize,
  }) {
    return Column(
      children: [
        ToggleButtonWidget(
          isSelected: isSelected,
          onPressed: _wrapWithOnNext(onToggle),
          label: label,
          textStyle: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: buttonFontSize,
          ),
        ),
        SizedBox(height: 2.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.w),
          child: Text(
            description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyLarge?.color?.withOpacity(0.7),
              fontSize: descriptionFontSize,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
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
    final screenWidth = MediaQuery.of(context).size.width;

    // Dynamic vertical padding based on screen size
    final verticalPadding = screenWidth > 600 ? 1.8.h : 1.5.h;

    // Ensure font size is responsive but has a minimum size
    final effectiveTextStyle = (textStyle ?? TextStyle(fontSize: 10.sp));

    return isSelected
        ? _buildSelectedButton(theme, verticalPadding, effectiveTextStyle)
        : _buildUnselectedButton(theme, verticalPadding, effectiveTextStyle);
  }

  Widget _buildSelectedButton(
    ThemeData theme,
    double verticalPadding,
    TextStyle textStyle,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 20.w),
      ),
      child: Text(label, style: textStyle),
    );
  }

  Widget _buildUnselectedButton(
    ThemeData theme,
    double verticalPadding,
    TextStyle textStyle,
  ) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: EdgeInsets.symmetric(vertical: 1.2.h, horizontal: 20.w),
      ),
      child: Text(label, style: textStyle),
    );
  }

  // Helper to ensure we don't use a font size that's too small
  double max(double a, double b) => a > b ? a : b;
}
