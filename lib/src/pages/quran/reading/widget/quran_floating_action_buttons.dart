import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/src/pages/quran/page/reciter_selection_screen.dart';
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
  late FocusScopeNode focusScopeNode;

  @override
  void initState() {
    focusScopeNode = FocusScopeNode(debugLabel: 'quran_floating_action_controls');
    super.initState();
  }

  @override
  void dispose() {
    focusScopeNode.dispose();
    super.dispose();
  }

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

  KeyEventResult _handleFloatingActionButtons(FocusNode node, event, bool isRotated) {
    if (event is KeyDownEvent) {
      if (isRotated) {
        // Landscape mode navigation
        switch (event.logicalKey) {
          case LogicalKeyboardKey.arrowUp:
            // Navigate between floating action buttons vertically
            FocusScope.of(context).previousFocus();
            return KeyEventResult.handled;

          case LogicalKeyboardKey.arrowDown:
            // Navigate between floating action buttons vertically
            FocusScope.of(context).nextFocus();
            return KeyEventResult.handled;

          case LogicalKeyboardKey.arrowLeft:
            // Navigate to left side buttons (Quran switcher, etc.)
            if (node == widget.switchToPlayQuranFocusNode) {
              FocusScope.of(context).requestFocus(widget.switchQuranModeNode);
            }
            return KeyEventResult.handled;

          case LogicalKeyboardKey.arrowRight:
            // Navigate to right side floating action buttons
            if (node == widget.switchQuranModeNode) {
              FocusScope.of(context).requestFocus(widget.switchToPlayQuranFocusNode);
            }
            return KeyEventResult.handled;
        }
      } else {
        if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
          node.focusInDirection(TraversalDirection.left);
          return KeyEventResult.handled;
        } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
          ref.read(quranReadingNotifierProvider.notifier).nextPage();
          node.previousFocus();
          return KeyEventResult.handled;
        } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
          FocusScope.of(context).previousFocus();
          return KeyEventResult.handled;
        } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
          FocusScope.of(context).nextFocus();
          return KeyEventResult.handled;
        }
      }
    }
    return KeyEventResult.ignored;
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

class _OrientationToggleButton extends ConsumerWidget {
  final FocusNode switchScreenViewFocusNode;

  const _OrientationToggleButton({
    required this.switchScreenViewFocusNode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quranReadingState = ref.watch(quranReadingNotifierProvider);

    return quranReadingState.when(
      data: (state) => SizedBox(
        width: state.isRotated ? 35.sp : 30.sp,
        height: state.isRotated ? 35.sp : 30.sp,
        child: FloatingActionButton(
          focusNode: switchScreenViewFocusNode,
          backgroundColor: Colors.black.withOpacity(.3),
          child: Icon(
            !state.isRotated ? Icons.stay_current_portrait : Icons.stay_current_landscape,
            color: Colors.white,
            size: state.isRotated ? 20.sp : 15.sp,
          ),
          onPressed: () {
            ref.read(quranReadingNotifierProvider.notifier).toggleRotation();
          },
          heroTag: null,
        ),
      ),
      loading: () => const CircularProgressIndicator(),
      error: (_, __) => const Icon(Icons.error),
    );
  }
}
