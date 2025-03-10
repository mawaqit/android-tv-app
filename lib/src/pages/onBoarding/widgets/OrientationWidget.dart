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
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    // Adjust font sizes based on orientation
    final double headerFontSize = isPortrait ? 16.sp : 20.sp;
    final double subtitleFontSize = isPortrait ? 10.sp : 12.sp;
    final double buttonFontSize = isPortrait ? 10.sp : 12.sp;
    final double descriptionFontSize = isPortrait ? 8.sp : 10.sp;

    // Adjust width factor based on orientation
    final double widthFactor = isPortrait ? 0.9 : 0.75;

    return Material(
      child: FractionallySizedBox(
        widthFactor: widthFactor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(theme, tr, headerFontSize, subtitleFontSize),
            SizedBox(height: isPortrait ? 0.5.h : 1.h),
            _buildOrientationOptions(
              theme: theme,
              tr: tr,
              userPrefs: userPrefs,
              buttonFontSize: buttonFontSize,
              descriptionFontSize: descriptionFontSize,
              isPortrait: isPortrait,
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
          style: theme.textTheme.headlineSmall?.copyWith(
            fontSize: headerFontSize,
            height: 1.2, // Tighter line height for better Arabic text display
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
        SizedBox(height: 1.5.h), // Reduced spacing
        Text(
          tr.selectYourMawaqitTvAppOrientation,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.textTheme.bodyLarge?.color?.withOpacity(0.8),
            fontSize: subtitleFontSize,
            height: 1.3, // Better line height for Arabic text
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.visible, // Changed to visible to prevent cutting off text
          maxLines: 4, // Increased max lines for Arabic text
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
    required bool isPortrait,
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
          isPortrait: isPortrait,
        ),

        SizedBox(height: isPortrait ? 1.5.h : 2.h),

        // Portrait option
        _buildOrientationOption(
          theme: theme,
          isSelected: !userPrefs.orientationLandscape,
          onToggle: () => userPrefs.orientationLandscape = false,
          label: tr.portrait,
          description: tr.portraitBTNDescription,
          buttonFontSize: buttonFontSize,
          descriptionFontSize: descriptionFontSize,
          isPortrait: isPortrait,
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
    required bool isPortrait,
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
            height: 1.2, // Better line height for Arabic text
          ),
          isPortrait: isPortrait,
        ),
        SizedBox(height: isPortrait ? 0.8.h : 1.5.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isPortrait ? 1.w : 2.w),
          child: Text(
            description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyLarge?.color?.withOpacity(0.7),
              fontSize: descriptionFontSize,
              height: 1.3, // Better line height for Arabic text
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.visible,
            maxLines: 4,
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
  final bool isPortrait;

  const ToggleButtonWidget({
    super.key,
    required this.isSelected,
    required this.onPressed,
    required this.label,
    this.textStyle,
    this.isPortrait = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    // Dynamic vertical padding based on screen size and orientation
    final verticalPadding = isPortrait
        ? (screenWidth > 600 ? 1.2.h : 1.0.h)
        : (screenWidth > 600 ? 1.8.h : 1.5.h);

    // Ensure font size is responsive but has a minimum size
    final effectiveTextStyle =
        (textStyle ?? TextStyle(fontSize: isPortrait ? 8.sp : 10.sp));

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
        minimumSize: Size(100.w, 0),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
            vertical: verticalPadding, horizontal: isPortrait ? 1.w : 2.w),
      ),
      child: Text(
        label,
        style: textStyle.copyWith(height: 1.2),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
      ),
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
        padding: EdgeInsets.symmetric(
            vertical: verticalPadding, horizontal: isPortrait ? 1.w : 2.w),
        minimumSize: Size(100.w, 0),
      ),
      child: Text(
        label,
        style: textStyle.copyWith(height: 1.2),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
      ),
    );
  }

  // Helper to ensure we don't use a font size that's too small
  double max(double a, double b) => a > b ? a : b;
}
