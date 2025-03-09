import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:mawaqit/src/services/user_preferences_manager.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
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

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AutoSizeText(
          tr.mainScreenOrSecondaryScreen,
          style: theme.textTheme.headlineSmall?.copyWith(fontSize: 20.sp),
          textAlign: TextAlign.center,
          maxLines: 2,
        ),
        SizedBox(height: 1.2.h),
        AutoSizeText(
          tr.mainScreenOrSecondaryScreenEXPLINATION,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.textTheme.bodyLarge?.color?.withOpacity(0.8),
            fontSize: 12.sp,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
        ),
        SizedBox(height: 2.h),
        ToggleButtonWidget(
          isSelected: !userPrefs.isSecondaryScreen,
          onPressed: _wrapWithOnDone(
            () => userPrefs.isSecondaryScreen = false,
          ),
          label: tr.mainScreen,
          textStyle: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 12.sp,
          ),
        ),
        SizedBox(height: 1.5.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 3.w),
          child: Text(
            tr.mainScreenExplanation,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyLarge?.color?.withOpacity(0.7),
              fontSize: 10.sp,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: 3.h),
        ToggleButtonWidget(
          isSelected: userPrefs.isSecondaryScreen,
          onPressed: _wrapWithOnDone(
            () => userPrefs.isSecondaryScreen = true,
          ),
          label: tr.secondaryScreen,
          textStyle: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 12.sp,
          ),
        ),
        SizedBox(height: 1.5.h),
        AutoSizeText(
          tr.secondaryScreenExplanation,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.textTheme.bodyLarge?.color?.withOpacity(0.7),
            fontSize: 10.sp,
          ),
          textAlign: TextAlign.center,
          maxLines: 4,
        ),
      ],
    );
  }
}
