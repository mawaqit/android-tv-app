import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/src/pages/quran/page/reciter_selection_screen.dart';
import 'package:mawaqit/src/services/user_preferences_manager.dart';
import 'package:mawaqit/src/state_management/quran/quran/quran_notifier.dart';
import 'package:mawaqit/src/state_management/quran/quran/quran_state.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class QuranFloatingActionControls extends ConsumerWidget {
  final FocusNode switchScreenViewFocusNode;
  final FocusNode switchQuranModeNode;
  final FocusNode switchToPlayQuranFocusNode;

  const QuranFloatingActionControls({
    super.key,
    required this.switchScreenViewFocusNode,
    required this.switchQuranModeNode,
    required this.switchToPlayQuranFocusNode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userPrefs = context.watch<UserPreferencesManager>();

    return OrientationBuilder(
      builder: (context, orientation) {
        final isPortrait = orientation == Orientation.portrait;

        return isPortrait
            ? _buildFloatingPortrait(userPrefs, isPortrait, ref, context)
            : _buildFloatingLandscape(userPrefs, isPortrait, ref, context);
      },
    );
  }

  Widget _buildFloatingPortrait(
      UserPreferencesManager userPrefs, bool isPortrait, WidgetRef ref, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _buildOrientationToggleButton(userPrefs, isPortrait, context),
        SizedBox(width: 200.sp),
        _buildQuranModeButton(userPrefs, isPortrait, ref, context),
        SizedBox(width: 200.sp),
        _buildPlayToggleButton(isPortrait),
      ],
    );
  }

  Widget _buildFloatingLandscape(
      UserPreferencesManager userPrefs, bool isPortrait, WidgetRef ref, BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _buildPlayToggleButton(isPortrait),
        SizedBox(height: 1.h),
        _buildOrientationToggleButton(userPrefs, isPortrait, context),
        SizedBox(height: 1.h),
        _buildQuranModeButton(userPrefs, isPortrait, ref, context),
      ],
    );
  }

  Widget _buildOrientationToggleButton(
      UserPreferencesManager userPrefs, bool isPortrait, BuildContext context) {
    return SizedBox(
      width: isPortrait ? 35.sp : 30.sp,
      height: isPortrait ? 35.sp : 30.sp,
      child: FloatingActionButton(
        focusNode: switchScreenViewFocusNode,
        backgroundColor: Colors.black.withOpacity(.3),
        child: Icon(
          !isPortrait ? Icons.stay_current_portrait : Icons.stay_current_landscape,
          color: Colors.white,
          size: isPortrait ? 20.sp : 15.sp,
        ),
        onPressed: () => _toggleOrientation(userPrefs, context),
        heroTag: null,
      ),
    );
  }

  void _toggleOrientation(UserPreferencesManager userPrefs, BuildContext context) {
    final newOrientation = MediaQuery.of(context).orientation == Orientation.portrait
        ? Orientation.landscape
        : Orientation.portrait;

    userPrefs.orientationLandscape = newOrientation == Orientation.landscape;
  }

  Widget _buildQuranModeButton(
      UserPreferencesManager userPrefs, bool isPortrait, WidgetRef ref, BuildContext context) {
    return SizedBox(
      width: isPortrait ? 35.sp : 30.sp,
      height: isPortrait ? 35.sp : 30.sp,
      child: FloatingActionButton(
        focusNode: switchQuranModeNode,
        backgroundColor: Colors.black.withOpacity(.3),
        child: Icon(
          Icons.headset,
          color: Colors.white,
          size: isPortrait ? 20.sp : 15.sp,
        ),
        onPressed: () async {
          ref.read(quranNotifierProvider.notifier).selectModel(QuranMode.listening);
          if (isPortrait) {
            userPrefs.orientationLandscape = true;
          }
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ReciterSelectionScreen.withoutSurahName(),
            ),
          );
        },
        heroTag: null,
      ),
    );
  }

  Widget _buildPlayToggleButton(bool isPortrait) {
    return SizedBox(
      width: isPortrait ? 35.sp : 30.sp,
      height: isPortrait ? 35.sp : 30.sp,
      child: FloatingActionButton(
        focusNode: switchToPlayQuranFocusNode,
        backgroundColor: Colors.black.withOpacity(.3),
        child: Icon(
          !isPortrait ? Icons.play_arrow : Icons.stay_current_landscape,
          color: Colors.white,
          size: isPortrait ? 20.sp : 15.sp,
        ),
        onPressed: () {
          // Implement play functionality
        },
        heroTag: null,
      ),
    );
  }
}
