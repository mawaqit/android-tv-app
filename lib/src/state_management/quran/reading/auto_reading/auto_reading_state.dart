import 'package:flutter/material.dart';

class AutoScrollState {
  final bool isSinglePageView;
  final double autoScrollSpeed;
  final bool isVisible;
  final double fontSize;
  final double maxFontSize;
  final ScrollController scrollController;

  AutoScrollState({
    required this.scrollController,
    this.isSinglePageView = false,
    this.autoScrollSpeed = 0.1,
    this.isVisible = true,
    this.fontSize = 1.0,
    this.maxFontSize = 3.0,
  });

  bool get isAutoScrolling => isSinglePageView;

  bool get showSpeedControl => !isSinglePageView;

  AutoScrollState copyWith({
    bool? isSinglePageView,
    double? autoScrollSpeed,
    bool? isVisible,
    double? fontSize,
    double? maxFontSize,
    ScrollController? scrollController,
  }) {
    return AutoScrollState(
      isSinglePageView: isSinglePageView ?? this.isSinglePageView,
      autoScrollSpeed: autoScrollSpeed ?? this.autoScrollSpeed,
      isVisible: isVisible ?? this.isVisible,
      fontSize: fontSize ?? this.fontSize,
      maxFontSize: maxFontSize ?? this.maxFontSize,
      scrollController: scrollController ?? this.scrollController,
    );
  }

  @override
  String toString() {
    return 'AutoScrollState('
        'isSinglePageView: $isSinglePageView, '
        'autoScrollSpeed: $autoScrollSpeed, '
        'isVisible: $isVisible, '
        'fontSize: $fontSize, '
        'maxFontSize: $maxFontSize, '
        'isAutoScrolling: $isAutoScrolling, '
        'showSpeedControl: $showSpeedControl'
        ')';
  }
}
