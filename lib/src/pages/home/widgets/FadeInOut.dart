import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class FadeInOutWidget extends StatefulWidget {
  const FadeInOutWidget({
    Key? key,
    required this.first,
    required this.duration,
    required this.second,
    this.secondDuration,
    this.showSecond = false,
  }) : super(key: key);

  final Widget first;
  final Duration duration;
  final Widget second;
  final Duration? secondDuration;
  final bool showSecond;

  @override
  State<FadeInOutWidget> createState() => _FadeInOutWidgetState();
}

class _FadeInOutWidgetState extends State<FadeInOutWidget> {
  bool _showSecond = false;

  @override
  void initState() {
    _showSecond = widget.showSecond;
    Future.delayed(widget.duration, showNextItem);

    print('FadeInOutWidget: initState()');

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        widget.first.animate(target: _showSecond ? 0 : 1).fadeIn().slideY(),
        widget.second.animate(target: _showSecond ? 1 : 0).fadeIn().slideY(begin: 100),
      ],
    );
  }

  void showNextItem() {
    if (!mounted) return;

    setState(() => _showSecond = !_showSecond);

    final nextDuration = _showSecond
        ? widget.secondDuration ?? widget.duration
        : widget.duration;

    Future.delayed(nextDuration, showNextItem);
  }
}
