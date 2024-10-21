import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/src/pages/quran/page/reciter_selection_screen.dart';
import 'package:mawaqit/src/services/user_preferences_manager.dart';
import 'package:mawaqit/src/state_management/quran/quran/quran_notifier.dart';
import 'package:mawaqit/src/state_management/quran/quran/quran_state.dart';
import 'package:mawaqit/src/state_management/quran/reading/auto_reading/auto_reading_notifier.dart';
import 'package:mawaqit/src/state_management/quran/reading/auto_reading/auto_reading_state.dart';
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
        final autoScrollState = ref.watch(autoScrollNotifierProvider);

        if (autoScrollState.isAutoScrolling) {
          return _buildAutoScrollingReadingMode(isPortrait, ref);
        } else {
          return isPortrait
              ? _buildFloatingPortrait(userPrefs, isPortrait, ref, context, autoScrollState)
              : _buildFloatingLandscape(userPrefs, isPortrait, ref, context, autoScrollState);
        }
      },
    );
  }

  Widget _buildFloatingPortrait(
    UserPreferencesManager userPrefs,
    bool isPortrait,
    WidgetRef ref,
    BuildContext context,
    AutoScrollState autoScrollState,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _buildOrientationToggleButton(userPrefs, isPortrait, context),
        SizedBox(width: 200.sp),
        _buildQuranModeButton(userPrefs, isPortrait, ref, context),
        SizedBox(width: 200.sp),
        _buildPlayPauseButton(
          isPortrait,
          ref,
          autoScrollState
        ),
      ],
    );
  }

  Widget _buildFloatingLandscape(
    UserPreferencesManager userPrefs,
    bool isPortrait,
    WidgetRef ref,
    BuildContext context,
    AutoScrollState autoScrollState,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _buildPlayPauseButton(isPortrait, ref, autoScrollState),
        SizedBox(height: 1.h),
        _buildOrientationToggleButton(userPrefs, isPortrait, context),
        SizedBox(height: 1.h),
        _buildQuranModeButton(userPrefs, isPortrait, ref, context),
      ],
    );
  }

  Widget _buildOrientationToggleButton(UserPreferencesManager userPrefs, bool isPortrait, BuildContext context) {
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
    final newOrientation =
        MediaQuery.of(context).orientation == Orientation.portrait ? Orientation.landscape : Orientation.portrait;

    userPrefs.orientationLandscape = newOrientation == Orientation.landscape;
  }

  Widget _buildQuranModeButton(UserPreferencesManager userPrefs, bool isPortrait, WidgetRef ref, BuildContext context) {
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

  Widget _buildAutoScrollingReadingMode(bool isPortrait, WidgetRef ref) {
    final autoScrollState = ref.watch(autoScrollNotifierProvider);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _buildFontSizeControls(isPortrait, ref),
        SizedBox(height: 1.h),
        _buildSpeedControls(isPortrait, ref),
        SizedBox(height: 1.h),
        _buildPlayPauseButton(isPortrait, ref, autoScrollState),
      ],
    );
  }

  Widget _buildFontSizeControls(bool isPortrait, WidgetRef ref) {
    return Column(
      children: [
        _buildActionButton(
          isPortrait,
          icon: Icons.remove,
          onPressed: () => ref.read(autoScrollNotifierProvider.notifier).decreaseFontSize(),
          tooltip: 'Decrease Font Size',
        ),
        SizedBox(width: 1.h),
        _buildActionButton(
          isPortrait,
          icon: Icons.add,
          onPressed: () => ref.read(autoScrollNotifierProvider.notifier).increaseFontSize(),
          tooltip: 'Increase Font Size',
        ),
      ],
    );
  }

  Widget _buildSpeedControls(bool isPortrait, WidgetRef ref) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildActionButton(
          isPortrait,
          icon: Icons.fast_rewind,
          onPressed: () => ref.read(autoScrollNotifierProvider.notifier).decreaseSpeed(),
          tooltip: 'Decrease Speed',
        ),
        SizedBox(width: 2.h),
        _buildActionButton(
          isPortrait,
          icon: Icons.fast_forward,
          onPressed: () => ref.read(autoScrollNotifierProvider.notifier).increaseSpeed(),
          tooltip: 'Increase Speed',
        ),
      ],
    );
  }

  Widget _buildPlayPauseButton(bool isPortrait, WidgetRef ref, AutoScrollState autoScrollState) {
    return _buildActionButton(
      isPortrait,
      icon: autoScrollState.isAutoScrolling ? Icons.pause : Icons.play_arrow,
      onPressed: () {
        ref.read(autoScrollNotifierProvider.notifier).toggleAutoScroll();
      },
      tooltip: autoScrollState.isAutoScrolling ? 'Pause' : 'Play',
    );
  }

  Widget _buildActionButton(bool isPortrait,
      {required IconData icon, required VoidCallback onPressed, String? tooltip}) {
    return SizedBox(
      width: isPortrait ? 35.sp : 30.sp,
      height: isPortrait ? 35.sp : 30.sp,
      child: FloatingActionButton(
        backgroundColor: Colors.black.withOpacity(.3),
        child: Icon(
          icon,
          color: Colors.white,
          size: isPortrait ? 20.sp : 15.sp,
        ),
        onPressed: onPressed,
        heroTag: null,
        tooltip: tooltip,
      ),
    );
  }
}
