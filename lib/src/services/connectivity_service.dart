import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/address_model.dart';

/// [ConnectivityService] is responsible for checking the network connectivity status.
/// It performs checks against a list of specified internet addresses.
class ConnectivityService {
  /// Default port to check connection.
  final int defaultPort = 53;

  /// Default timeout to check connection.
  final Duration defaultTimeout;

  /// Default interval to recheck connection status.
  final Duration defaultInterval;

  /// Default addresses to test against.
  final List<AddressCheckOptions> defaultAddresses = List<AddressCheckOptions>.unmodifiable(
    <AddressCheckOptions>[
      AddressCheckOptions(
        InternetAddress(
          '2606:4700:4700::1111', // CloudFlare
          type: InternetAddressType.IPv6,
        ),
      ),
      AddressCheckOptions(
        InternetAddress(
          '8.8.4.4', // Google
          type: InternetAddressType.IPv4,
        ),
      ),
      AddressCheckOptions(
        InternetAddress(
          '2001:4860:4860::8888', // Google
          type: InternetAddressType.IPv6,
        ),
      ),
    ],
  );

  ConnectivityService({
    Duration? interval,
    Duration? defaultTimeout,
  })  : defaultInterval = interval ?? const Duration(seconds: 3),
        defaultTimeout = defaultTimeout ?? const Duration(seconds: 1) {
    _statusController.onListen = () {
      _maybeEmitStatusUpdate();
    };
    _statusController.onCancel = () {
      _timerHandle?.cancel();
      _lastStatus = null; // reset last status
    };
  }
  /// [isHostReachable] returns a [Future] that completes with a [AddressCheckResult] object.
  /// [isHostReachable] Method to check if a specific host is reachable.
  Future<AddressCheckResult> isHostReachable(
    AddressCheckOptions options,
  ) async {
    Socket? sock;
    try {
      sock = await Socket.connect(
        options.address,
        defaultPort,
        timeout: defaultTimeout,
      );
      sock.destroy();
      return AddressCheckResult(options, true);
    } catch (e) {
      sock?.destroy();
      return AddressCheckResult(options, false);
    }
  }

  /// [hasConnection] returns a [Future] that completes with a [bool] object.
  /// [hasConnection] Method to check if the default addresses are reachable.
  Future<bool> get hasConnection async {
    final Completer<bool> result = Completer<bool>();
    int length = defaultAddresses.length;

    for (final AddressCheckOptions addressOptions in defaultAddresses) {
      isHostReachable(addressOptions).then(
        (AddressCheckResult request) {
          length -= 1;
          if (!result.isCompleted) {
            if (request.isSuccess) {
              result.complete(true);
            } else if (length == 0) {
              result.complete(false);
            }
          }
        },
      );
    }
    return result.future;
  }

  /// [connectionStatus] returns a [Future] that completes with a [ConnectivityStatus] object.
  /// [connectionStatus] Method to check the current connectivity status.
  Future<ConnectivityStatus> get connectionStatus async {
    return await hasConnection ? ConnectivityStatus.connected : ConnectivityStatus.disconnected;
  }
  /// [_maybeEmitStatusUpdate]
  Future<void> _maybeEmitStatusUpdate([Timer? timer]) async {
    _timerHandle?.cancel();
    timer?.cancel();
    final ConnectivityStatus currentStatus = await connectionStatus;

    if (_lastStatus != currentStatus && _statusController.hasListener) {
      _statusController.add(currentStatus);
    }

    if (!_statusController.hasListener) return;
    _timerHandle = Timer(defaultInterval, _maybeEmitStatusUpdate);

    _lastStatus = currentStatus;
  }

  ConnectivityStatus? _lastStatus;
  Timer? _timerHandle;

  final StreamController<ConnectivityStatus> _statusController = StreamController.broadcast();

  Stream<ConnectivityStatus> get onStatusChange => _statusController.stream;

  bool get hasListeners => _statusController.hasListener;

  bool get isActivelyChecking => _statusController.hasListener;
}

/// Singleton instance of [ConnectivityService] using Riverpod.
final connectivityServiceProvider =
Provider.family<ConnectivityService, ConnectivityServiceParams>((
  ref,
  params,
) {
  final ConnectivityService service = ConnectivityService(
    interval: params.interval,
    defaultTimeout: params.timeout,
  );
  return service;
});

/// [AddressCheckOptions] is a class that holds the address to check against.
class ConnectivityServiceParams {
  final Duration interval;
  final Duration timeout;

  const ConnectivityServiceParams({
    Duration? interval,
    Duration? timeout,
  })  : interval = interval ?? const Duration(seconds: 3),
        timeout = timeout ?? const Duration(seconds: 1);
}
