import 'package:flutter/material.dart';

mixin PostFrameCallback<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) => afterFirstFrame());
    super.initState();
  }

  void afterFirstFrame() {}
}
