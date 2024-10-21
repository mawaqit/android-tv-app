class AutoScrollState {
  final bool isSinglePageView;
  final double autoScrollSpeed;
  final bool isVisible;
  final double fontSize;
  final double maxFontSize;

  AutoScrollState({
    this.isSinglePageView = false,
    this.autoScrollSpeed = 1.0,
    this.isVisible = true,
    this.fontSize = 1.0,
    this.maxFontSize = 3.0,
  });

  // Derived properties
  bool get isAutoScrolling => !isSinglePageView;
  bool get showSpeedControl => !isSinglePageView;

  AutoScrollState copyWith({
    bool? isSinglePageView,
    double? autoScrollSpeed,
    bool? isVisible,
    double? fontSize,
    double? maxFontSize,
  }) {
    return AutoScrollState(
      isSinglePageView: isSinglePageView ?? this.isSinglePageView,
      autoScrollSpeed: autoScrollSpeed ?? this.autoScrollSpeed,
      isVisible: isVisible ?? this.isVisible,
      fontSize: fontSize ?? this.fontSize,
      maxFontSize: maxFontSize ?? this.maxFontSize,
    );
  }
}
