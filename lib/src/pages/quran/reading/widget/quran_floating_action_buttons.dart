import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/src/pages/quran/page/reciter_selection_screen.dart';
import 'package:mawaqit/src/routes/routes_constant.dart';
import 'package:mawaqit/src/state_management/quran/quran/quran_notifier.dart';
import 'package:mawaqit/src/state_management/quran/quran/quran_state.dart';
import 'package:mawaqit/src/state_management/quran/reading/auto_reading/auto_reading_notifier.dart';
import 'package:mawaqit/src/state_management/quran/reading/quran_reading_notifer.dart';
import 'package:mawaqit/src/state_management/quran/reading/quran_reading_state.dart';
import 'package:sizer/sizer.dart';

class QuranFloatingActionControls extends ConsumerStatefulWidget {
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
  ConsumerState createState() => _QuranFloatingActionControlsState();
}

class _QuranFloatingActionControlsState extends ConsumerState<QuranFloatingActionControls> {
  @override
  Widget build(BuildContext context) {
    final quranReadingState = ref.watch(quranReadingNotifierProvider);
    final autoScrollState = ref.watch(autoScrollNotifierProvider);

    return quranReadingState.when(
      data: (state) {
        if (autoScrollState.isAutoScrolling) {
          return _AutoScrollingReadingMode(
            isPortrait: state.isRotated,
            quranReadingState: state,
            switchToPlayQuranFocusNode: widget.switchToPlayQuranFocusNode,
          );
        }

        return FocusTraversalGroup(
          policy: WidgetOrderTraversalPolicy(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _PlayPauseButton(
                isPortrait: state.isRotated,
                switchToPlayQuranFocusNode: widget.switchToPlayQuranFocusNode,
              ),
              SizedBox(height: 12),
              _OrientationToggleButton(
                switchScreenViewFocusNode: widget.switchScreenViewFocusNode,
              ),
              SizedBox(height: 12),
              _QuranModeButton(
                isPortrait: state.isRotated,
                switchQuranModeNode: widget.switchQuranModeNode,
              ),
            ],
          ),
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (_, __) => const Icon(Icons.error),
    );
  }
}

class _QuranModeButton extends ConsumerWidget {
  final bool isPortrait;
  final FocusNode switchQuranModeNode;

  const _QuranModeButton({
    required this.isPortrait,
    required this.switchQuranModeNode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Calculate relative size
    double buttonSize = isPortrait
        ? MediaQuery.of(context).size.width * 0.06 // Adjust as needed
        : MediaQuery.of(context).size.width * 0.06; // Adjust as needed
    double iconSize = buttonSize * 0.5; // Icon size relative to button size

    return SizedBox(
      width: buttonSize,
      height: buttonSize,
      child: FloatingActionButton(
        focusNode: switchQuranModeNode,
        backgroundColor: Colors.black.withOpacity(.3),
        focusColor: Theme.of(context).focusColor,
        child: Icon(
          Icons.headset,
          color: Colors.white,
          size: iconSize,
        ),
        onPressed: () {
          ref.read(quranNotifierProvider.notifier).selectModel(QuranMode.listening);
          Navigator.pushReplacementNamed(context, Routes.quranReciter);
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
    final autoScrollNotifier = ref.read(autoScrollNotifierProvider.notifier);
    final autoScrollState = ref.watch(autoScrollNotifierProvider);

    return _ActionButton(
      isPortrait: isPortrait,
      icon: !autoScrollState.isAutoScrolling
          ? Icons.play_arrow
          : autoScrollState.isPlaying
              ? Icons.pause
              : Icons.play_arrow,
      onPressed: () {
        if (!autoScrollState.isAutoScrolling) {
          final quranReadingState = ref.watch(quranReadingNotifierProvider);
          final currentPage = quranReadingState.maybeWhen(
            data: (state) => state.currentPage,
            orElse: () => 0,
          );
          final pageHeight = MediaQuery.of(context).size.height;
          autoScrollNotifier.toggleAutoScroll(currentPage, pageHeight);
        }
        if (autoScrollState.isPlaying) {
          autoScrollNotifier.pauseAutoScroll();
        } else {
          autoScrollNotifier.resumeAutoScroll();
        }
      },
      focusNode: switchToPlayQuranFocusNode,
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
        _ExitButton(
          quranReadingState: quranReadingState,
          isPortrait: isPortrait,
        ),
        SizedBox(height: 1.h),
        _FontSizeControls(
          isPortrait: isPortrait,
          fontSize: autoScrollState.fontSize,
        ),
        SizedBox(height: 1.h),
        _SpeedControls(
          quranReadingState: quranReadingState,
          isPortrait: isPortrait,
          speed: autoScrollState.autoScrollSpeed,
        ),
        SizedBox(height: 1.h),
        _PlayPauseButton(
          isPortrait: isPortrait,
        ),
      ],
    );
  }
}

class _FontSizeControls extends ConsumerWidget {
  final bool isPortrait;
  final double fontSize;

  const _FontSizeControls({
    required this.isPortrait,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _ActionButton(
      isPortrait: isPortrait,
      icon: Icons.text_fields,
      onPressed: () => ref.read(autoScrollNotifierProvider.notifier).cycleFontSize(),
      tooltip: 'Font Size: ${(fontSize * 100).toInt()}%',
      autoFocus: true,
    );
  }
}

// Add new Exit button widget
class _ExitButton extends ConsumerStatefulWidget {
  final bool isPortrait;
  final QuranReadingState quranReadingState;

  const _ExitButton({
    super.key,
    required this.isPortrait,
    required this.quranReadingState,
  });

  @override
  ConsumerState createState() => __ExitButtonState();
}

class __ExitButtonState extends ConsumerState<_ExitButton> {
  late FocusNode exitFocusNode;
  @override
  void initState() {
    exitFocusNode = FocusNode(debugLabel: 'exit_focus_node');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      exitFocusNode.requestFocus();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _ActionButton(
      autoFocus: true,
      focusNode: exitFocusNode,
      isPortrait: widget.isPortrait,
      icon: Icons.close,
      onPressed: () {
        ref
            .read(autoScrollNotifierProvider.notifier)
            .stopAutoScroll(isPortairt: widget.isPortrait, quranReadingState: widget.quranReadingState);
      },
      tooltip: 'Exit Auto-Scroll',
    );
  }
}

class _SpeedControls extends ConsumerWidget {
  final QuranReadingState quranReadingState;
  final bool isPortrait;
  final double speed;

  const _SpeedControls({
    required this.quranReadingState,
    required this.isPortrait,
    required this.speed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _ActionButton(
      isPortrait: isPortrait,
      icon: Icons.speed,
      onPressed: () {
        final pageHeight = MediaQuery.of(context).size.height;
        ref.read(autoScrollNotifierProvider.notifier).cycleSpeed(
              quranReadingState.currentPage,
              pageHeight,
            );
      },
      tooltip: 'Speed: ${speed == speed.toInt() ? speed.toInt() : speed.toStringAsFixed(1)}x',
    );
  }
}

class _ActionButton extends StatelessWidget {
  final bool isPortrait;
  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;
  final FocusNode? focusNode;
  bool autoFocus;

  _ActionButton({
    required this.isPortrait,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.focusNode,
    this.autoFocus = false,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate relative size
    double buttonSize = isPortrait
        ? MediaQuery.of(context).size.width * 0.06 // Adjust as needed
        : MediaQuery.of(context).size.width * 0.06; // Adjust as needed
    double iconSize = buttonSize * 0.5; // Icon size relative to button size

    return SizedBox(
      width: buttonSize,
      height: buttonSize,
      child: FloatingActionButton(
        autofocus: autoFocus,
        focusNode: focusNode,
        backgroundColor: Colors.black.withOpacity(.3),
        focusColor: Theme.of(context).focusColor,
        child: Icon(
          icon,
          color: Colors.white,
          size: iconSize,
        ),
        onPressed: onPressed,
        heroTag: null,
        tooltip: tooltip,
      ),
    );
  }
}

class _OrientationToggleButton extends ConsumerWidget {
  final FocusNode switchScreenViewFocusNode;
  const _OrientationToggleButton({
    required this.switchScreenViewFocusNode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quranReadingState = ref.watch(quranReadingNotifierProvider);

    return quranReadingState.when(
      data: (state) {
        // Calculate relative size
        double buttonSize = state.isRotated
            ? MediaQuery.of(context).size.width * 0.06 // Adjust as needed
            : MediaQuery.of(context).size.width * 0.06; // Adjust as needed
        double iconSize = buttonSize * 0.5; // Icon size relative to button size

        return SizedBox(
          width: buttonSize,
          height: buttonSize,
          child: FloatingActionButton(
            focusNode: switchScreenViewFocusNode,
            backgroundColor: Colors.black.withOpacity(.3),
            focusColor: Theme.of(context).focusColor,
            child: Icon(
              !state.isRotated ? Icons.stay_current_portrait : Icons.stay_current_landscape,
              color: Colors.white,
              size: iconSize,
            ),
            onPressed: () {
              ref.read(quranReadingNotifierProvider.notifier).toggleRotation();
            },
            heroTag: null,
          ),
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (_, __) => const Icon(Icons.error),
    );
  }
}
