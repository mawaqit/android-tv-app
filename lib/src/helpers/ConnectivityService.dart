import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:mawaqit/src/domain/model/connectivity_status.dart';
import 'dart:developer' as developer;

class ConnectivityService {
  final StreamController<ConnectivityStatus> connectionStatusController = StreamController<ConnectivityStatus>();

  late final StreamSubscription<List<ConnectivityResult>> _subscription;

  ConnectivityService() {
    _subscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      // Debug logging to see what connectivity results we're getting
      developer.log('ConnectivityService: Received results: $results');

      // Determine the current status based on the list of connectivity results
      final status = _getStatusFromResults(results);
      developer.log('ConnectivityService: Mapped to status: $status');

      connectionStatusController.add(status);
    });
  }

  ConnectivityStatus _getStatusFromResults(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.mobile)) {
      return ConnectivityStatus.Cellular;
    } else if (results.contains(ConnectivityResult.wifi)) {
      return ConnectivityStatus.Wifi;
    } else if (results.contains(ConnectivityResult.ethernet)) {
      return ConnectivityStatus.Wifi; // Treat ethernet as connected (same as WiFi for UI purposes)
    } else {
      return ConnectivityStatus.Offline;
    }
  }

  void dispose() {
    _subscription.cancel();
    connectionStatusController.close();
  }
}
