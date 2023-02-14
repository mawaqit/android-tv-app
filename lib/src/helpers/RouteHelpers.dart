import 'package:flutter/material.dart';

extension RouteExtension on Widget {
  Route<T> buildRoute<T>() => MaterialPageRoute(builder: (context) => this);
}
