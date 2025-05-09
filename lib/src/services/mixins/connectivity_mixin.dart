import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:mawaqit/src/helpers/Api.dart';

mixin NetworkConnectivity on ChangeNotifier {
  bool isOnline = true;

  final _connectivity = Connectivity();

  /// check for connectivity each minute
  final _duration = Duration(minutes: 1);

  /// check for connectivity each minute
  StreamSubscription? _connectivitySubscription;

  /// check for connectivity on hardware change
  StreamSubscription? _connectivityHardwareSubscription;

  Future<void> checkIsOnline() async {
    final value = await Api.checkTheInternetConnection();

    isOnline = value;
    notifyListeners();
  }

  void listenToConnectivity() {
    checkIsOnline();
    _connectivityHardwareSubscription = _connectivity.onConnectivityChanged.listen((result) {
      // Handle connectivity change
      checkIsOnline();
    });

    _connectivitySubscription = Stream.periodic(_duration).listen((event) => checkIsOnline());
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    _connectivityHardwareSubscription?.cancel();
    super.dispose();
  }
}
