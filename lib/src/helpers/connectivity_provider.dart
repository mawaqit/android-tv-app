import 'dart:async';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import '../models/address_model.dart';
import '../services/connectivity_service.dart';

/// This class listens to internet‐connection changes and notifies its listeners.
class ConnectivityProvider extends StreamNotifier<ConnectivityStatus> {
  @override
  Stream<ConnectivityStatus> build() {
    // Use the InternetConnection API (not InternetConnectionCheckerPlus)
    final internetChecker = InternetConnection.createInstance(
      checkInterval: const Duration(seconds: 10),
    );

    return internetChecker.onStatusChange.transform(
      StreamTransformer.fromHandlers(
        handleDone: (sink) => sink.close(),
        handleError: (error, stackTrace, sink) {
          log('[internet_connectivity]: $error');
          sink.add(ConnectivityStatus.disconnected);
        },
        handleData: (status, sink) {
          // Map InternetStatus to your app’s ConnectivityStatus
          if (status == InternetStatus.connected) {
            sink.add(ConnectivityStatus.connected);
          } else {
            sink.add(ConnectivityStatus.disconnected);
          }
        },
      ),
    );
  }

  /// Programmatically check internet connection once.
  Future<void> checkInternetConnection() async {
    state = const AsyncLoading<ConnectivityStatus>();
    state = await AsyncValue.guard(() async {
      final internet = InternetConnection();
      final hasInternet = await internet.hasInternetAccess;
      return hasInternet ? ConnectivityStatus.connected : ConnectivityStatus.disconnected;
    });
  }
}

/// A standalone StreamProvider version, if you prefer not to use StreamNotifier.
final connectivityStreamProvider = StreamProvider<ConnectivityStatus>((ref) {
  final internetChecker = InternetConnection.createInstance(
    checkInterval: const Duration(seconds: 10),
  );

  return internetChecker.onStatusChange.transform(
    StreamTransformer.fromHandlers(
      handleDone: (sink) => sink.close(),
      handleError: (error, stackTrace, sink) {
        log('[internet_connectivity]: $error');
        sink.add(ConnectivityStatus.disconnected);
      },
      handleData: (status, sink) {
        if (status == InternetStatus.connected) {
          sink.add(ConnectivityStatus.connected);
        } else {
          sink.add(ConnectivityStatus.disconnected);
        }
      },
    ),
  );
});

/// Global provider for [ConnectivityProvider].
final connectivityProvider = StreamNotifierProvider<ConnectivityProvider, ConnectivityStatus>(
  ConnectivityProvider.new,
);
