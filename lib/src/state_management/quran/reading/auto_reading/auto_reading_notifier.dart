import 'dart:async';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mawaqit/src/state_management/quran/reading/auto_reading/auto_reading_state.dart';
import 'package:mawaqit/src/state_management/quran/reading/quran_reading_notifer.dart';
import 'package:mawaqit/src/state_management/quran/reading/quran_reading_state.dart';

class AutoScrollNotifier extends AutoDisposeNotifier<AutoScrollState> {
  Timer? _autoScrollTimer;
  Timer? _hideTimer;
  late ScrollController scrollController;

  @override
  AutoScrollState build() {
    scrollController = ScrollController();
    ref.onDispose(() {
      _autoScrollTimer?.cancel();
      _hideTimer?.cancel();
      scrollController.dispose();
    });
    return AutoScrollState(
      scrollController: scrollController,
    );
  }

  void setScrollController(ScrollController controller) {
    scrollController = controller;
  }

  Future<void> jumpToCurrentPage(int currentPage, double pageHeight) async {
    if (scrollController.hasClients) {
      final offset = (currentPage - 1) * pageHeight;
      scrollController.jumpTo(offset);
    }
  }

  void toggleAutoScroll(int currentPage, double pageHeight) {
    if (state.isAutoScrolling) {
      stopAutoScroll();
    } else {
      startAutoScroll(currentPage, pageHeight);
    }
  }

  Future<void> startAutoScroll(int currentPage, double pageHeight) async {
    // Cancel any existing timers
    _autoScrollTimer?.cancel();
    _hideTimer?.cancel();

    // Reset state with clear initialization
    state = state.copyWith(
      isSinglePageView: true,
      isLoading: true,
      fontSize: 1.0,
      currentPage: currentPage,
      isPlaying: false, // Start as not playing
    );

    try {
      // Use Future.wait to ensure all async operations complete
      await Future.wait([
        Future.microtask(() async {
          // Robust wait for scroll controller
          for (int i = 0; i < 50; i++) {
            // 5 seconds total wait time
            if (scrollController.hasClients && scrollController.position.hasContentDimensions) {
              _initializeScrollController(currentPage, pageHeight);
              break;
            }
            await Future.delayed(Duration(milliseconds: 100));
          }
        }),

        // Additional delay to ensure view is fully rendered
        Future.delayed(Duration(milliseconds: 500))
      ]);

      // Update state to start auto-scrolling
      state = state.copyWith(
        isLoading: false,
        isPlaying: true,
      );

      // Start scrolling with a slight delay
      await Future.delayed(Duration(milliseconds: 100));
      _startScrolling();
    } catch (e, stackTrace) {
      // Fallback state reset
      state = state.copyWith(
        isLoading: false,
        isPlaying: false,
      );
    }
  }

  void _initializeScrollController(int currentPage, double pageHeight) {
    final pageOffset = currentPage * pageHeight;
    // Set initial offset to correct position, account for rotation if necessary
    scrollController.jumpTo(pageOffset);
  }

  void _startScrolling() {
    // Cancel any existing timer to prevent multiple timers
    _autoScrollTimer?.cancel();

    // Validate initial state
    if (!state.isPlaying) {
      return;
    }

    // Additional safety checks
    if (scrollController == null) {
      return;
    }

    _autoScrollTimer = Timer.periodic(Duration(milliseconds: 50), (timer) {
      // Comprehensive client check
      if (scrollController.hasClients && scrollController.position.hasContentDimensions) {
        try {
          final maxScroll = scrollController.position.maxScrollExtent;
          final currentScroll = scrollController.offset;
          final delta = state.autoScrollSpeed;

          // Detailed logging for debugging

          if (currentScroll >= maxScroll) {
            stopAutoScroll();
            timer.cancel();
            return;
          }

          // Safe scroll operation
          scrollController.jumpTo(min(currentScroll + delta, maxScroll));

          // Page calculation
          final pageHeight = scrollController.position.viewportDimension;
          final newPage = _calculateCurrentPage(scrollController, pageHeight);

          if (newPage != state.currentPage) {
            state = state.copyWith(currentPage: newPage);
          }
        } catch (e) {
          timer.cancel();
          state = state.copyWith(isPlaying: false);
        }
      } else {}
    });
  }

  // Function to calculate current page during scrolling
  int _calculateCurrentPage(ScrollController scrollController, double pageHeight) {
    final viewportOffset = scrollController.offset % pageHeight;
    if (viewportOffset < (pageHeight / 2)) {
      // Scrolled to the left, check if it's possible to navigate to the previous page
      return (scrollController.offset / pageHeight).floor() + 1;
    } else {
      // Scrolled to the right, check if it's possible to navigate to the next page
      return (scrollController.offset / pageHeight).ceil() + 1;
    }
  }

  void stopAutoScroll({QuranReadingState? quranReadingState, bool isPortairt = false}) async {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = null;

    // Calculate current page before switching views
    int finalPage = state.currentPage;
    if (scrollController.hasClients) {
      final pageHeight = scrollController.position.viewportDimension;
      finalPage = _calculateCurrentPage(scrollController, pageHeight);
    }

    // First update state to disable auto-scroll
    state = state.copyWith(
      isSinglePageView: false,
      isPlaying: false,
    );

    // Then update the page after a small delay to allow view transition
    await Future.delayed(Duration(milliseconds: 100));

    // Update QuranReadingState with current page
    try {
      await ref.read(quranReadingNotifierProvider.notifier).updatePage(
            !isPortairt ? finalPage : quranReadingState!.currentPage,
            isPortairt: isPortairt,
          );
    } catch (e) {
      // Handle error silently or show a user-friendly message
      print('Error updating page: $e');
    }
  }

  void changeSpeed(double newSpeed) {
    state = state.copyWith(autoScrollSpeed: newSpeed.clamp(0.5, 4.0));
  }

  void showControls() {
    state = state.copyWith(isVisible: true);
    startHideTimer();
  }

  void startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(Duration(seconds: 12), () {
      state = state.copyWith(isVisible: false);
    });
  }

  void changeFontSize() {
    double newFontSize = state.fontSize + 0.2;
    if (newFontSize > state.maxFontSize) newFontSize = 1.0;
    state = state.copyWith(fontSize: newFontSize);
  }

  void increaseFontSize() {
    double newFontSize = state.fontSize + 0.2;
    if (newFontSize > state.maxFontSize) newFontSize = state.maxFontSize;
    state = state.copyWith(fontSize: newFontSize);
  }

  void decreaseFontSize() {
    double newFontSize = state.fontSize - 0.2;
    if (newFontSize < 1.0) newFontSize = 1.0;
    state = state.copyWith(fontSize: newFontSize);
  }

  void cycleFontSize() {
    if (state.fontSize >= state.maxFontSize) {
      state = state.copyWith(fontSize: 1.0);
    } else {
      state = state.copyWith(fontSize: state.fontSize + 0.2);
    }
  }

  void cycleSpeed(int currentPage, double pageHeight) {
    double newSpeed;
    if (state.autoScrollSpeed >= 2.0) {
      newSpeed = 0.5;
    } else if (state.autoScrollSpeed >= 1.5) {
      newSpeed = 2.0;
    } else if (state.autoScrollSpeed >= 1.0) {
      newSpeed = 1.5;
    } else {
      newSpeed = 1.0;
    }
    state = state.copyWith(autoScrollSpeed: newSpeed);
    if (state.isAutoScrolling) {
      _startScrolling(); // Only restart the scrolling timer
    }
  }

  void pauseAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = null;
    state = state.copyWith(
      isPlaying: false,
    );
  }

  void resumeAutoScroll() {
    if (!state.isPlaying) {
      state = state.copyWith(
        isPlaying: true,
      );
      _startScrolling();
    }
  }
}

final autoScrollNotifierProvider = AutoDisposeNotifierProvider<AutoScrollNotifier, AutoScrollState>(
  AutoScrollNotifier.new,
);
