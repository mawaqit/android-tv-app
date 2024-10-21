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
    return AutoScrollState();
  }

  void toggleAutoScroll() {
    state = state.copyWith(
      isSinglePageView: !state.isSinglePageView,
    );

    if (state.isAutoScrolling) {
      startAutoScroll();
    } else {
      stopAutoScroll();
    }
  }

  void startAutoScroll() {
    _autoScrollTimer?.cancel();
    state = state.copyWith(
      isSinglePageView: true,
    );
    _autoScrollTimer = Timer.periodic(Duration(milliseconds: 50), (timer) {
      if (scrollController.position.pixels < scrollController.position.maxScrollExtent) {
        scrollController.jumpTo(scrollController.position.pixels + (state.autoScrollSpeed * 2));
      } else {
        stopAutoScroll();
      }
    });
  }

  void stopAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = null;
  }

  void changeSpeed(double newSpeed) {
    state = state.copyWith(autoScrollSpeed: newSpeed.clamp(0.1, 5.0));
    if (state.isAutoScrolling) {
      startAutoScroll();
    }
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

  void increaseSpeed() {
    double newSpeed = state.autoScrollSpeed + 0.1;
    if (newSpeed > 5.0) newSpeed = 5.0;
    state = state.copyWith(autoScrollSpeed: newSpeed);
    if (state.isAutoScrolling) {
      startAutoScroll();
    }
  }

  void decreaseSpeed() {
    double newSpeed = state.autoScrollSpeed - 0.1;
    if (newSpeed < 0.1) newSpeed = 0.1;
    state = state.copyWith(autoScrollSpeed: newSpeed);
    if (state.isAutoScrolling) {
      startAutoScroll();
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
