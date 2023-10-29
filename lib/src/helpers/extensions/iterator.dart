import 'package:flutter/material.dart';

extension IteratorExtension<T> on Iterable<T> {
  Iterable<T> _addPadding(T Function() builder) sync* {
    for (var item in this) {
      yield item;

      if (item != this.last) yield builder();
    }
  }
}

extension WidgetIteratorExtension on Iterable<Widget> {
  List<Widget> addPadding({double width = 0, double height = 0}) =>
      _addPadding(() => SizedBox(width: width, height: height)).toList();
}
