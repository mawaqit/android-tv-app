import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/address_model.dart';
import '../services/connectivity_service.dart';

/// This class listens to connectivity changes and notifies its listeners.
class ConnectivityProvider extends StreamNotifier<ConnectivityStatus> {

  /// Overriding the [build] method to define how the stream of connectivity status is created.
  /// default time for checking connection is 2 seconds.
  @override
  Stream<ConnectivityStatus> build() {
    return ref
        .watch(connectivityServiceProvider(ConnectivityServiceParams(
          interval: const Duration(seconds: 10),
        )))
        .onStatusChange;
  }
}
/// Global provider for [ConnectivityProvider].
/// This provider allows access to the connectivity status stream from anywhere in the app.
final connectivityProvider =
StreamNotifierProvider<ConnectivityProvider, ConnectivityStatus>(ConnectivityProvider.new);
