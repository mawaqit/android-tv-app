import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/pages/onBoarding/widgets/toggle_button_widget.dart';
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
      callback();

      // Add a timeout to avoid indefinite stuck states
      final timeout = Future.delayed(Duration(seconds: 2), () {
        // No focus was requested within timeout, nothing more to do
      });

      // Add a small delay before requesting focus to ensure state changes are fully applied
      Future.delayed(Duration(milliseconds: 300), () {
        // Cancel the timeout since we're handling it
        timeout.ignore();

        if (nextButtonFocusNode != null && nextButtonFocusNode!.canRequestFocus) {
          nextButtonFocusNode!.requestFocus();
        }
      });

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
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    // Adjust font sizes based on orientation
    final double headerFontSize = isPortrait ? 16.sp : 20.sp;
    final double subtitleFontSize = isPortrait ? 10.sp : 12.sp;
    final double buttonFontSize = isPortrait ? 10.sp : 12.sp;
    final double descriptionFontSize = isPortrait ? 8.sp : 10.sp;

    return Material(
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isPortrait ? 4.w : 8.w,
            vertical: isPortrait ? 2.h : 3.h,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header section - flexible
              Flexible(
                flex: 2,
                child: _buildHeader(theme, tr, headerFontSize, subtitleFontSize),
              ),

              // Orientation options - takes most space
              Flexible(
                flex: 6,
                child: _buildOrientationOptions(
                  theme: theme,
                  tr: tr,
                  userPrefs: userPrefs,
                  buttonFontSize: buttonFontSize,
                  descriptionFontSize: descriptionFontSize,
                  isPortrait: isPortrait,
                ),
              ),
            ],
          ),
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
        Expanded(
          flex: 2,
          child: AutoSizeText(
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
        // Landscape option - takes equal space
        Expanded(
          child: _buildOrientationOption(
            theme: theme,
            isSelected: userPrefs.orientationLandscape,
            onToggle: () => userPrefs.orientationLandscape = true,
            label: tr.landscape,
            description: tr.landscapeBTNDescription,
            buttonFontSize: buttonFontSize,
            descriptionFontSize: descriptionFontSize,
            isPortrait: isPortrait,
          ),
        ),

        // Spacer between options
        SizedBox(height: isPortrait ? 2.h : 3.h),

        // Portrait option - takes equal space
        Expanded(
          child: _buildOrientationOption(
            theme: theme,
            isSelected: !userPrefs.orientationLandscape,
            onToggle: () => userPrefs.orientationLandscape = false,
            label: tr.portrait,
            description: tr.portraitBTNDescription,
            buttonFontSize: buttonFontSize,
            descriptionFontSize: descriptionFontSize,
            isPortrait: isPortrait,
          ),
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
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Toggle button - centered
        ToggleButtonWidget(
          isSelected: isSelected,
          onPressed: _wrapWithOnNext(onToggle),
          label: label,
          textStyle: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: buttonFontSize,
            height: 1.2,
          ),
          isPortrait: isPortrait,
        ),

        // Spacer
        SizedBox(height: isPortrait ? 1.h : 1.5.h),

        // Description text - flexible
        Expanded(
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: isPortrait ? 1.w : 2.w,
            ),
            child: AutoSizeText(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyLarge?.color?.withOpacity(0.7),
                fontSize: descriptionFontSize,
                height: 1.3,
              ),
              maxLines: 3,
              softWrap: true,
              textAlign: TextAlign.center,
              // overflow: TextOverflow.visible,
            ),
          ),
        ),
      ],
    );
  }
}
