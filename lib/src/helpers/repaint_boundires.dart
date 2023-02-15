import 'package:flutter/material.dart';

extension RepaintBoundaryExtension on Widget {
  Widget addRepaintBoundary() => RepaintBoundary(child: this);
}
