import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart' as fp;
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/services/user_preferences_manager.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class OnBoardingAnnouncementScreens extends StatelessWidget {
  final VoidCallback? onNext;
  final bool isOnboarding;
  final fp.Option<FocusNode> nextButtonFocusNode;

  const OnBoardingAnnouncementScreens({
    super.key,
    this.onNext,
    this.isOnboarding = false,
    this.nextButtonFocusNode = const fp.None(),
  });

  VoidCallback _wrapWithOnNext(VoidCallback callback) {
    return () {
      callback();
      if (!isOnboarding) {
        onNext?.call();
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
    final userPrefs = context.watch<UserPreferencesManager>();
    final theme = Theme.of(context);
    final tr = S.of(context);
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    // Adjust font sizes based on orientation
    final double headerFontSize = isPortrait ? 14.sp : 16.sp;
    final double subtitleFontSize = isPortrait ? 6.sp : 8.sp;
    final double buttonFontSize = isPortrait ? 8.sp : 10.sp;
    final double descriptionFontSize = isPortrait ? 6.sp : 8.sp;

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
            _buildAnnouncementOptions(
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
        AutoSizeText(
          tr.announcementOnlyMode,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontSize: headerFontSize,
            height: 1.2,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          minFontSize: 10,
          // Minimum readable size
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 1.5.h),
        AutoSizeText(
          tr.announcementOnlyModeEXPLINATION,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.textTheme.bodyLarge?.color?.withOpacity(0.8),
            fontSize: subtitleFontSize,
            height: 1.3,
          ),
          textAlign: TextAlign.center,
          maxLines: 4,
          minFontSize: 8,
          // Minimum readable size
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  /// Builds the announcement mode options (normal and announcement only)
  Widget _buildAnnouncementOptions({
    required ThemeData theme,
    required AppLocalizations tr,
    required UserPreferencesManager userPrefs,
    required double buttonFontSize,
    required double descriptionFontSize,
    required bool isPortrait,
  }) {
    return Column(
      children: [
        // Normal mode option
        _buildAnnouncementOption(
          theme: theme,
          isSelected: !userPrefs.announcementsOnly,
          onToggle: () => userPrefs.announcementsOnly = false,
          label: tr.normalMode,
          description: tr.normalModeExplanation,
          buttonFontSize: buttonFontSize,
          descriptionFontSize: descriptionFontSize,
          isPortrait: isPortrait,
        ),

        SizedBox(height: isPortrait ? 1.5.h : 2.h),

        // Announcement only mode option
        _buildAnnouncementOption(
          theme: theme,
          isSelected: userPrefs.announcementsOnly,
          onToggle: () => userPrefs.announcementsOnly = true,
          label: tr.announcementOnlyMode,
          description: tr.announcementOnlyModeExplanation,
          buttonFontSize: buttonFontSize,
          descriptionFontSize: descriptionFontSize,
          isPortrait: isPortrait,
        ),
      ],
    );
  }

  /// Builds a single announcement option with button and description
  Widget _buildAnnouncementOption({
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
    final verticalPadding = isPortrait ? (screenWidth > 600 ? 1.2.h : 1.0.h) : (screenWidth > 600 ? 1.8.h : 1.5.h);

    // Ensure font size is responsive but has a minimum size
    final effectiveTextStyle = (textStyle ?? TextStyle(fontSize: isPortrait ? 8.sp : 10.sp));

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
        padding: EdgeInsets.symmetric(vertical: verticalPadding, horizontal: isPortrait ? 1.w : 2.w),
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
        padding: EdgeInsets.symmetric(vertical: verticalPadding, horizontal: isPortrait ? 1.w : 2.w),
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
