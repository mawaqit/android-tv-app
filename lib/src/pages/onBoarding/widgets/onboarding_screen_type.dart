import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart' as fp;
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:mawaqit/src/services/user_preferences_manager.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../i18n/l10n.dart';
import 'widgets.dart';

class OnBoardingScreenType extends StatelessWidget {
  final VoidCallback? onDone;
  final bool isOnboarding;
  final fp.Option<FocusNode> nextButtonFocusNode;

  // Private constructor
  const OnBoardingScreenType._({
    Key? key,
    required this.isOnboarding,
    this.onDone,
    this.nextButtonFocusNode = const fp.None(),
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
    FocusNode? nextButtonFocusNode,
  }) {
    return OnBoardingScreenType._(
      key: key,
      isOnboarding: true,
      nextButtonFocusNode: fp.Option.fromNullable(nextButtonFocusNode),
    );
  }

  // Helper method to wrap callbacks with onDone
  VoidCallback _wrapWithOnDone(VoidCallback callback) {
    return () {
      callback();
      if (!isOnboarding) {
        onDone?.call();
      } else {
        nextButtonFocusNode.fold(
          () => null,
          (focusNode) {
            // Add a timeout to avoid indefinite stuck states
            final timeout = Future.delayed(Duration(seconds: 2), () {
              // No focus was requested within timeout, nothing more to do
            });

            // Attempt to request focus with safety checks
            Future.delayed(Duration(milliseconds: 500), () {
              // Cancel the timeout since we're handling it
              timeout.ignore();

              // Only request focus if the node can accept it
              if (focusNode.canRequestFocus) {
                focusNode.requestFocus();
              }
            });
          },
        );
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
    final double headerFontSize = 16.sp;
    final double subtitleFontSize = 8.sp;
    final double buttonFontSize = 10.sp;
    final double descriptionFontSize = 8.sp;

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
            _buildScreenTypeOptions(
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
          tr.mainScreenOrSecondaryScreen,
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
          tr.mainScreenOrSecondaryScreenEXPLINATION,
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

  /// Builds the screen type options (main and secondary)
  Widget _buildScreenTypeOptions({
    required ThemeData theme,
    required AppLocalizations tr,
    required UserPreferencesManager userPrefs,
    required double buttonFontSize,
    required double descriptionFontSize,
    required bool isPortrait,
  }) {
    return Column(
      children: [
        // Main screen option
        _buildScreenTypeOption(
          theme: theme,
          isSelected: !userPrefs.isSecondaryScreen,
          onToggle: () => userPrefs.isSecondaryScreen = false,
          label: tr.mainScreen,
          description: tr.mainScreenExplanation,
          buttonFontSize: buttonFontSize,
          descriptionFontSize: descriptionFontSize,
          isPortrait: isPortrait,
        ),

        SizedBox(height: isPortrait ? 1.5.h : 2.h),

        // Secondary screen option
        _buildScreenTypeOption(
          theme: theme,
          isSelected: userPrefs.isSecondaryScreen,
          onToggle: () => userPrefs.isSecondaryScreen = true,
          label: tr.secondaryScreen,
          description: tr.secondaryScreenExplanation,
          buttonFontSize: buttonFontSize,
          descriptionFontSize: descriptionFontSize,
          isPortrait: isPortrait,
        ),
      ],
    );
  }

  /// Builds a single screen type option with button and description
  Widget _buildScreenTypeOption({
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
          onPressed: _wrapWithOnDone(onToggle),
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
