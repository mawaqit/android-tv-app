import 'dart:async';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/address_model.dart';

import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart' ;

/// This class listens to connectivity changes and notifies its listeners.
class ConnectivityProvider extends StreamNotifier<ConnectivityStatus> {

  /// Overriding the [build] method to define how the stream of connectivity status is created.
  /// default time for checking connection is 2 seconds.
  @override
  Stream<ConnectivityStatus> build() {
    return ref
        .watch(connectivityStreamProvider.future).asStream();
  }

  /// [checkInternetConnection] Check the internet connection status.
  ///
  /// This method checks the internet connection status and updates the state accordingly.
  Future<void> checkInternetConnection() async {
    state = AsyncLoading();
    state = await AsyncValue.guard(() async {
      final internet = InternetConnectionCheckerPlus();
      final status = await internet.hasConnection;
      if (status) {
        return ConnectivityStatus.connected;
      } else {
        return ConnectivityStatus.disconnected;
      }
    });
  }
}

/// transform the stream of connectivity status to a stream of [ConnectivityStatus].
///
/// This provider listens to the stream of connectivity status and transforms it to a stream of [ConnectivityStatus].
final connectivityStreamProvider = StreamProvider<ConnectivityStatus>((ref) {
  final internet = InternetConnectionCheckerPlus();
  return internet.onStatusChange.transform(
    StreamTransformer.fromHandlers(
      handleDone: (sink) {
        sink.close();
      },
      handleError: (error, stackTrace, sink) {
        log('[internet_connectivity]: $error',);
        sink.add(ConnectivityStatus.disconnected);
      },
      handleData: (status, sink) {
        if (status == InternetConnectionStatus.connected) {
          sink.add(ConnectivityStatus.connected);
        } else {
          sink.add(ConnectivityStatus.disconnected);
        }
      },
    ),
  );
});


/// Global provider for [ConnectivityProvider].
/// This provider allows access to the connectivity status stream from anywhere in the app.
final connectivityProvider =
StreamNotifierProvider<ConnectivityProvider, ConnectivityStatus>(ConnectivityProvider.new);
