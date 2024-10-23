import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/src/pages/quran/page/reciter_selection_screen.dart';
import 'package:mawaqit/src/services/user_preferences_manager.dart';
import 'package:mawaqit/src/state_management/quran/quran/quran_notifier.dart';
import 'package:mawaqit/src/state_management/quran/quran/quran_state.dart';
import 'package:mawaqit/src/state_management/quran/reading/auto_reading/auto_reading_notifier.dart';
import 'package:mawaqit/src/state_management/quran/reading/quran_reading_notifer.dart';
import 'package:mawaqit/src/state_management/quran/reading/quran_reading_state.dart';
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
    final quranReadingState = ref.watch(quranReadingNotifierProvider);
    return OrientationBuilder(
      builder: (context, orientation) {
        final isPortrait = orientation == Orientation.portrait;
        final autoScrollState = ref.watch(autoScrollNotifierProvider);

        if (autoScrollState.isAutoScrolling) {
          return quranReadingState.maybeWhen(
            orElse: () {
              return CircularProgressIndicator();
            },
            data: (quranState) {
              return _AutoScrollingReadingMode(
                isPortrait: isPortrait,
                quranReadingState: quranState,
                switchToPlayQuranFocusNode: switchToPlayQuranFocusNode,
              );
            },
          );
        } else {
          return isPortrait
              ? _FloatingPortrait(
            userPrefs: userPrefs,
            isPortrait: isPortrait,
            switchScreenViewFocusNode: switchScreenViewFocusNode,
            switchQuranModeNode: switchQuranModeNode,
            switchToPlayQuranFocusNode: switchToPlayQuranFocusNode,
          )
              : _FloatingLandscape(
            userPrefs: userPrefs,
            isPortrait: isPortrait,
            switchScreenViewFocusNode: switchScreenViewFocusNode,
            switchQuranModeNode: switchQuranModeNode,
            switchToPlayQuranFocusNode: switchToPlayQuranFocusNode,
          );
        }
      },
    );
  }
}

class _FloatingPortrait extends StatelessWidget {
  final UserPreferencesManager userPrefs;
  final bool isPortrait;
  final FocusNode switchScreenViewFocusNode;
  final FocusNode switchQuranModeNode;
  final FocusNode switchToPlayQuranFocusNode;

  const _FloatingPortrait({
    required this.userPrefs,
    required this.isPortrait,
    required this.switchScreenViewFocusNode,
    required this.switchQuranModeNode,
    required this.switchToPlayQuranFocusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _OrientationToggleButton(
          userPrefs: userPrefs,
          isPortrait: isPortrait,
          switchScreenViewFocusNode: switchScreenViewFocusNode,
        ),
        SizedBox(width: 200.sp),
        _QuranModeButton(
          userPrefs: userPrefs,
          isPortrait: isPortrait,
          switchQuranModeNode: switchQuranModeNode,
        ),
        SizedBox(width: 200.sp),
        _PlayPauseButton(
          isPortrait: isPortrait,
          switchToPlayQuranFocusNode: switchToPlayQuranFocusNode,
        ),
      ],
    );
  }
}

class _FloatingLandscape extends StatelessWidget {
  final UserPreferencesManager userPrefs;
  final bool isPortrait;
  final FocusNode switchScreenViewFocusNode;
  final FocusNode switchQuranModeNode;
  final FocusNode switchToPlayQuranFocusNode;

  const _FloatingLandscape({
    required this.userPrefs,
    required this.isPortrait,
    required this.switchScreenViewFocusNode,
    required this.switchQuranModeNode,
    required this.switchToPlayQuranFocusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _PlayPauseButton(
          isPortrait: isPortrait,
          switchToPlayQuranFocusNode: switchToPlayQuranFocusNode,
        ),
        SizedBox(height: 1.h),
        _OrientationToggleButton(
          userPrefs: userPrefs,
          isPortrait: isPortrait,
          switchScreenViewFocusNode: switchScreenViewFocusNode,
        ),
        SizedBox(height: 1.h),
        _QuranModeButton(
          userPrefs: userPrefs,
          isPortrait: isPortrait,
          switchQuranModeNode: switchQuranModeNode,
        ),
      ],
    );
  }
}

class _OrientationToggleButton extends StatelessWidget {
  final UserPreferencesManager userPrefs;
  final bool isPortrait;
  final FocusNode switchScreenViewFocusNode;

  const _OrientationToggleButton({
    required this.userPrefs,
    required this.isPortrait,
    required this.switchScreenViewFocusNode,
  });

  @override
  Widget build(BuildContext context) {
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
        onPressed: () => _toggleOrientation(context),
        heroTag: null,
      ),
    );
  }

  void _toggleOrientation(BuildContext context) {
    final newOrientation =
    MediaQuery.of(context).orientation == Orientation.portrait ? Orientation.landscape : Orientation.portrait;

    userPrefs.orientationLandscape = newOrientation == Orientation.landscape;
  }
}

class _QuranModeButton extends ConsumerWidget {
  final UserPreferencesManager userPrefs;
  final bool isPortrait;
  final FocusNode switchQuranModeNode;

  const _QuranModeButton({
    required this.userPrefs,
    required this.isPortrait,
    required this.switchQuranModeNode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
}

class _PlayPauseButton extends ConsumerWidget {
  final bool isPortrait;
  final FocusNode? switchToPlayQuranFocusNode;

  const _PlayPauseButton({
    required this.isPortrait,
    this.switchToPlayQuranFocusNode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final autoScrollState = ref.watch(autoScrollNotifierProvider);
    return _ActionButton(
      isPortrait: isPortrait,
      icon: autoScrollState.isAutoScrolling ? Icons.pause : Icons.play_arrow,
      onPressed: () {
        final quranReadingStateAsync = ref.read(quranReadingNotifierProvider);
        final quranReadingState = quranReadingStateAsync.asData?.value;

        if (quranReadingState != null) {
          final currentPage = quranReadingState.currentPage;
          final pageHeight = MediaQuery.of(context).size.height;

          ref.read(autoScrollNotifierProvider.notifier).toggleAutoScroll(currentPage, pageHeight);
        }
      },
      tooltip: autoScrollState.isAutoScrolling ? 'Pause' : 'Play',
      focusNode: switchToPlayQuranFocusNode,
    );
  }
}

class _ActionButton extends StatelessWidget {
  final bool isPortrait;
  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;
  final FocusNode? focusNode;

  const _ActionButton({
    required this.isPortrait,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isPortrait ? 35.sp : 30.sp,
      height: isPortrait ? 35.sp : 30.sp,
      child: FloatingActionButton(
        focusNode: focusNode,
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

class _AutoScrollingReadingMode extends ConsumerWidget {
  final bool isPortrait;
  final QuranReadingState quranReadingState;
  final FocusNode? switchToPlayQuranFocusNode;

  const _AutoScrollingReadingMode({
    required this.isPortrait,
    required this.quranReadingState,
    this.switchToPlayQuranFocusNode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final autoScrollState = ref.watch(autoScrollNotifierProvider);
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _FontSizeControls(isPortrait: isPortrait),
        SizedBox(height: 1.h),
        _SpeedControls(
          quranReadingState: quranReadingState,
          isPortrait: isPortrait,
        ),
        SizedBox(height: 1.h),
        _PlayPauseButton(
          isPortrait: isPortrait,
          switchToPlayQuranFocusNode: switchToPlayQuranFocusNode,
        ),
      ],
    );
  }
}

class _FontSizeControls extends ConsumerWidget {
  final bool isPortrait;

  const _FontSizeControls({required this.isPortrait});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        _ActionButton(
          isPortrait: isPortrait,
          icon: Icons.remove,
          onPressed: () => ref.read(autoScrollNotifierProvider.notifier).decreaseFontSize(),
          tooltip: 'Decrease Font Size',
        ),
        SizedBox(width: 1.h),
        _ActionButton(
          isPortrait: isPortrait,
          icon: Icons.add,
          onPressed: () => ref.read(autoScrollNotifierProvider.notifier).increaseFontSize(),
          tooltip: 'Increase Font Size',
        ),
      ],
    );
  }
}

class _SpeedControls extends ConsumerWidget {
  final QuranReadingState quranReadingState;
  final bool isPortrait;

  const _SpeedControls({
    required this.quranReadingState,
    required this.isPortrait,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Positioned(
      right: 16,
      bottom: isPortrait ? 100 : 16,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            mini: true,
            backgroundColor: Colors.black.withOpacity(.3),
            child: Icon(
              Icons.add,
              color: Colors.white,
              size: isPortrait ? 20.sp : 15.sp,
            ),
            onPressed: () {
              final pageHeight = MediaQuery.of(context).size.height;
              ref.read(autoScrollNotifierProvider.notifier).increaseSpeed(
                quranReadingState.currentPage,
                pageHeight,
              );
            },
            heroTag: 'increase_speed',
          ),
          SizedBox(height: 8),
          FloatingActionButton(
            mini: true,
            backgroundColor: Colors.black.withOpacity(.3),
            child: Icon(
              Icons.remove,
              color: Colors.white,
              size: isPortrait ? 20.sp : 15.sp,
            ),
            onPressed: () {
              final pageHeight = MediaQuery.of(context).size.height;
              ref.read(autoScrollNotifierProvider.notifier).decreaseSpeed(
                quranReadingState.currentPage,
                pageHeight,
              );
            },
            heroTag: 'decrease_speed',
          ),
        ],
      ),
    );
  }
}
