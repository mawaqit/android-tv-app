import 'package:flutter/material.dart';

class RelativeSizes {
  RelativeSizes._();

  static RelativeSizes instance = RelativeSizes._();

  Size _size = Size(100000, 10000);

  set size(Size size) {
    _size = size;
  }

  Orientation get orientation => _size.width >= _size.height ? Orientation.landscape : Orientation.portrait;
}

extension RelativePixels on num {
  double get vw => RelativeSizes.instance._size.width / 100 * this;

  double get vh => RelativeSizes.instance._size.height / 100 * this;
}
