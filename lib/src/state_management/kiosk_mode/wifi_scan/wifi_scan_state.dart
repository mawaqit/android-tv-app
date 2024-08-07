import 'package:equatable/equatable.dart';
import 'package:wifi_hunter/wifi_hunter_result.dart';
import 'package:wifi_scan/wifi_scan.dart';

enum Status {
  connecting,
  connected,
  error,
}

class WifiScanState extends Equatable {
  final List<WiFiHunterResultEntry> accessPoints;
  final bool hasPermission;
  final Status status;

  WifiScanState({
    required this.accessPoints,
    required this.hasPermission,
    this.status = Status.connecting,
  });

  WifiScanState copyWith({
    List<WiFiHunterResultEntry>? accessPoints,
    bool? shouldCheckCan,
    Status? status,
    bool? hasPermission,
  }) {
    return WifiScanState(
      status: status ?? this.status,
      accessPoints: accessPoints ?? this.accessPoints,
      hasPermission: hasPermission ?? this.hasPermission,
    );
  }

  @override
  List get props => [
        accessPoints,
        hasPermission,
        status,
      ];
}
