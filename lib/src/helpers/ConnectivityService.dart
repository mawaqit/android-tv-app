import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:mawaqit/src/enum/connectivity_status.dart';

class ConnectivityService {
  StreamController<ConnectivityStatus> connectionStatusController =
  StreamController<ConnectivityStatus>();

  ConnectivityService() {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      var connectionsStatus = _getStatusFromResult(result);

      connectionStatusController.add(connectionsStatus);
    });
  }

  ConnectivityStatus _getStatusFromResult(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.mobile:
        return ConnectivityStatus.Cellular;
      case ConnectivityResult.wifi:
        return ConnectivityStatus.Wifi;
      case ConnectivityResult.none:
        return ConnectivityStatus.Offline;
      default:
        return ConnectivityStatus.Offline;
    }
  }
}
