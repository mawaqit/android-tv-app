import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mawaqit/src/state_management/quran/reading/auto_reading/auto_reading_state.dart';

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

    // Store the current scroll position before making changes
    double? currentScrollPosition;
    if (scrollController.hasClients) {
      currentScrollPosition = scrollController.offset;
    }

    state = state.copyWith(
      isSinglePageView: true,
    );

    // Ensure the ListView is built
    await Future.delayed(Duration(milliseconds: 50));

    // Restore the previous scroll position if it exists,
    // otherwise jump to the current page
    if (scrollController.hasClients) {
      if (currentScrollPosition != null) {
        scrollController.jumpTo(currentScrollPosition);
      } else {
        final offset = (currentPage - 1) * pageHeight;
        scrollController.jumpTo(offset);
      }
    }

    _startScrolling();
  }



  void _startScrolling() {
    // Only start scrolling if we're in playing state
    if (!state.isPlaying) return;

    state = state.copyWith(
      isPlaying: true,
    );

    const duration = Duration(milliseconds: 50);
    _autoScrollTimer = Timer.periodic(duration, (timer) {
      // Check if we should be scrolling
      if (!state.isPlaying) {
        timer.cancel();
        return;
      }

      if (scrollController.hasClients) {
        final maxScroll = scrollController.position.maxScrollExtent;
        final currentScroll = scrollController.offset;
        final delta = state.autoScrollSpeed;

        if (currentScroll >= maxScroll) {
          stopAutoScroll();
        } else {
          scrollController.jumpTo(currentScroll + delta);
        }
      }
    });
  }

  void stopAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = null;
    state = state.copyWith(
      isSinglePageView: false,
    );
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
