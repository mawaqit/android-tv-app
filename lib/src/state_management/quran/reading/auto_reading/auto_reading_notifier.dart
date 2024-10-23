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
    state = state.copyWith(
      isSinglePageView: true,
    );

    // Ensure the ListView is built
    await Future.delayed(Duration(milliseconds: 50));

    // Jump to the current page
    if (scrollController.hasClients) {
      final offset = (currentPage - 1) * pageHeight;
      scrollController.jumpTo(offset);
    }

    _startScrolling();
  }



  void _startScrolling() {
    const duration = Duration(milliseconds: 50);
    _autoScrollTimer = Timer.periodic(duration, (timer) {
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
      startAutoScroll(currentPage, pageHeight);
    }
  }

  void decreaseSpeed(int currentPage, double pageHeight) {
    double newSpeed = state.autoScrollSpeed - 0.1;
    if (newSpeed < 0.1) newSpeed = 0.1;
    state = state.copyWith(autoScrollSpeed: newSpeed);
    if (state.isAutoScrolling) {
      startAutoScroll(currentPage, pageHeight);
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
}

final autoScrollNotifierProvider = AutoDisposeNotifierProvider<AutoScrollNotifier, AutoScrollState>(
  AutoScrollNotifier.new,
);
