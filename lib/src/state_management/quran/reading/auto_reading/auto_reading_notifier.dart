import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mawaqit/src/state_management/quran/reading/auto_reading/auto_reading_state.dart';
import 'package:mawaqit/src/state_management/quran/reading/quran_reading_notifer.dart';
import 'package:mawaqit/src/state_management/quran/reading/quran_reading_state.dart';

class AutoScrollNotifier extends AutoDisposeNotifier<AutoScrollState> {
  Timer? _autoScrollTimer;
  Timer? _hideTimer;
  late final ScrollController scrollController;

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
    _autoScrollTimer?.cancel();

    state = state.copyWith(
      isSinglePageView: true,
      isLoading: true,
      fontSize: 1.0,
      currentPage: currentPage,
    );

    try {
      await Future.microtask(() async {
        for (int i = 0; i < 50; i++) {
          if (scrollController.hasClients) {
            _initializeScrollController(currentPage, pageHeight);
            break;
        }
          await Future.delayed(Duration(milliseconds: 100));
        }

        state = state.copyWith(
          isLoading: false,
          isPlaying: true,
        );

        _startScrolling();
      }).timeout(Duration(seconds: 5), onTimeout: () {
        print('Auto-scroll initialization timed out');
        state = state.copyWith(
          isLoading: false,
          isPlaying: false,
        );
      });
    } catch (e) {
      print('Error in startAutoScroll: $e');
      state = state.copyWith(
        isLoading: false,
        isPlaying: false,
      );
    }
}

  void _initializeScrollController(int currentPage, double pageHeight) {
    final pageOffset = (currentPage - 1) * pageHeight;
    // Set initial offset to correct position, account for rotation if necessary
    scrollController.jumpTo(pageOffset);
  }

  void _startScrolling() {
    print('Starting auto-scrolling...');
    if (!state.isPlaying) return;

    const duration = Duration(milliseconds: 50);
    _autoScrollTimer = Timer.periodic(duration, (timer) {
      if (!state.isPlaying) {
        timer.cancel();
        return;
      }
      print('Scrolling... before');

      if (scrollController.hasClients) {
        print('Scrolling...');
        final maxScroll = scrollController.position.maxScrollExtent;
        final currentScroll = scrollController.offset;
        final delta = state.autoScrollSpeed;

        if (currentScroll >= maxScroll) {
          stopAutoScroll();
        } else {
          print('Scrolling... after');
          scrollController.jumpTo(currentScroll + delta);
          print('Scrolling... after 2');
          // Update current page during scrolling
          final pageHeight = scrollController.position.viewportDimension;
          final newPage = _calculateCurrentPage(scrollController, pageHeight);
          if (newPage != state.currentPage) {
            state = state.copyWith(currentPage: newPage);
          }
        }
      }
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
    if (scrollController.hasClients) {
      final pageHeight = scrollController.position.viewportDimension;
      // Use floor instead of ceil and don't add 1 to stay on current page
      // if scroll hasn't moved significantly
      final currentPage = _calculateCurrentPage(scrollController, pageHeight);
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
              !isPortairt ? currentPage : quranReadingState!.currentPage,
              isPortairt: isPortairt,
            );
      } catch (e) {
        // Handle error silently or show a user-friendly message
        print('Error updating page: $e');
      }
    } else {
      state = state.copyWith(
        isSinglePageView: false,
        isPlaying: false,
      );
    }
  }

  void changeSpeed(double newSpeed) {
    state = state.copyWith(autoScrollSpeed: newSpeed.clamp(0.1, 5.0));
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

  void increaseSpeed(int currentPage, double pageHeight) {
    double newSpeed = state.autoScrollSpeed + 0.1;
    if (newSpeed > 5.0) newSpeed = 5.0;
    state = state.copyWith(autoScrollSpeed: newSpeed);
    if (state.isAutoScrolling) {
      _startScrolling(); // Only restart the scrolling timer
    }
  }

  void decreaseSpeed(int currentPage, double pageHeight) {
    double newSpeed = state.autoScrollSpeed - 0.1;
    if (newSpeed < 0.1) newSpeed = 0.1;
    state = state.copyWith(autoScrollSpeed: newSpeed);
    if (state.isAutoScrolling) {
      _startScrolling(); // Only restart the scrolling timer
    }
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
    if (state.autoScrollSpeed >= 0.5) {
      newSpeed = 0.1;
    } else {
      newSpeed = state.autoScrollSpeed + 0.1;
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
