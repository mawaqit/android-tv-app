import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/src/state_management/quran/auto_scroll_quran/autoscroll_state.dart';

class AutoScrollNotifier extends StateNotifier<AutoScrollState> {
  AutoScrollNotifier() : super(AutoScrollState());

  Timer? _autoScrollTimer;
  Timer? _hideTimer;
  final ScrollController scrollController = ScrollController();

  void toggleAutoScroll() {
    state = state.copyWith(
      isSinglePageView: !state.isSinglePageView,
      isAutoScrolling: !state.isSinglePageView,
      showSpeedControl: !state.isSinglePageView,
    );

    if (state.isAutoScrolling) {
      startAutoScroll();
    } else {
      stopAutoScroll();
    }
  }

  void startAutoScroll() {
    _autoScrollTimer?.cancel();
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
    state = state.copyWith(
      isAutoScrolling: false,
      showSpeedControl: false,
    );
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

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _hideTimer?.cancel();
    scrollController.dispose();
    super.dispose();
  }
}

final autoScrollProvider = StateNotifierProvider<AutoScrollNotifier, AutoScrollState>((ref) {
  return AutoScrollNotifier();
});
