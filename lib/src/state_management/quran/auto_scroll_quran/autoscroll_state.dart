class AutoScrollState {
  final bool isSinglePageView;
  final bool isAutoScrolling;
  final bool showSpeedControl;
  final double autoScrollSpeed;
  final bool isVisible;
  final double fontSize;
  final double maxFontSize;

  AutoScrollState({
    this.isSinglePageView = false,
    this.isAutoScrolling = false,
    this.showSpeedControl = false,
    this.autoScrollSpeed = 1.0,
    this.isVisible = true,
    this.fontSize = 1.0,
    this.maxFontSize = 3.0,
  });

  AutoScrollState copyWith({
    bool? isSinglePageView,
    bool? isAutoScrolling,
    bool? showSpeedControl,
    double? autoScrollSpeed,
    bool? isVisible,
    double? fontSize,
    double? maxFontSize,
  }) {
    return AutoScrollState(
      isSinglePageView: isSinglePageView ?? this.isSinglePageView,
      isAutoScrolling: isAutoScrolling ?? this.isAutoScrolling,
      showSpeedControl: showSpeedControl ?? this.showSpeedControl,
      autoScrollSpeed: autoScrollSpeed ?? this.autoScrollSpeed,
      isVisible: isVisible ?? this.isVisible,
      fontSize: fontSize ?? this.fontSize,
      maxFontSize: maxFontSize ?? this.maxFontSize,
    );
  }
}
