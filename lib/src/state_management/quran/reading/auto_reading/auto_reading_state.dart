import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class AutoScrollState extends Equatable {
  final bool isSinglePageView;
  final double autoScrollSpeed;
  final bool isVisible;
  final double fontSize;
  final double maxFontSize;
  final ScrollController scrollController;
  final bool isPlaying;
  final bool isLoading;
  final int currentPage;

  AutoScrollState({
    required this.scrollController,
    this.isSinglePageView = false,
    this.autoScrollSpeed = 0.5,
    this.isVisible = true,
    this.fontSize = 1.0,
    this.maxFontSize = 3.0,
    this.isPlaying = false,
    this.isLoading = false,
    this.currentPage = 1,
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
    bool? isPlaying,
    bool? isLoading,
    int? currentPage,
  }) {
    return AutoScrollState(
      isSinglePageView: isSinglePageView ?? this.isSinglePageView,
      autoScrollSpeed: autoScrollSpeed ?? this.autoScrollSpeed,
      isVisible: isVisible ?? this.isVisible,
      fontSize: fontSize ?? this.fontSize,
      maxFontSize: maxFontSize ?? this.maxFontSize,
      scrollController: scrollController ?? this.scrollController,
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
      currentPage: currentPage ?? this.currentPage,
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
        'showSpeedControl: $showSpeedControl,'
        'isPlaying: $isPlaying'
        ')';
  }

  @override
  List<Object?> get props => [
        isSinglePageView,
        autoScrollSpeed,
        isVisible,
        fontSize,
        maxFontSize,
        scrollController,
        isPlaying,
        isLoading,
        currentPage,
      ];
}
