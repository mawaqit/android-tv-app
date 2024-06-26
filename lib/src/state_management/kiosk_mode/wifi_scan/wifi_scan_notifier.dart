import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/main.dart';
import 'package:mawaqit/src/helpers/TimeShiftManager.dart';
import 'package:mawaqit/src/state_management/kiosk_mode/wifi_scan/wifi_scan_state.dart';
import 'package:wifi_scan/wifi_scan.dart';

import '../../../pages/onBoarding/widgets/onboarding_timezone_selector.dart';

class WifiScanNotifier extends AsyncNotifier<WifiScanState> {
  final TimeShiftManager _timeManager = TimeShiftManager();

  @override
  WifiScanState build() {
    _scan();

    return WifiScanState(
      accessPoints: [],
      hasPermission: false,
    );
  }

  Future<void> _scan() async {
    state = AsyncLoading();
    try {
      final can = await WiFiScan.instance.canStartScan();
      if (can != CanStartScan.yes) {
        logger.e("kiosk mode: wifi_scan: can't start scan");
        return;
      }
      final canGetScannedResults =
          await WiFiScan.instance.canGetScannedResults();
      if (canGetScannedResults != CanGetScannedResults.yes) {
        logger.e("kiosk mode: wifi_scan: can't get scanned results");
        return;
      }
      final results = await WiFiScan.instance.getScannedResults();
      state = AsyncData(
        state.value!.copyWith(
          accessPoints: results,
          hasPermission: true,
        ),
      );
    } catch (e, s) {
      logger.e("kiosk mode: wifi_scan: error: $e");
      state = AsyncError(e, s);
    }
  }

  Future<void> connectToWifi(
      String ssid, String security, String password) async {
    try {
      bool isSuccess = false;
      if (_timeManager.deviceModel == "MAWAQITBOX V2") {
        isSuccess = await platform.invokeMethod('connectToNetworkWPA', {
          "ssid": ssid,
          "password": password,
        });
      } else {
        isSuccess = await platform.invokeMethod('connectToWifi', {
          "ssid": ssid,
          "password": password,
        });
      }
      if (isSuccess) {
        logger.i("kiosk mode: wifi_scan: connected to wifi");
        sleep(Duration(seconds: 5));

        state = AsyncData(state.value!.copyWith(status: Status.connected));
      } else {
        logger.e("kiosk mode: wifi_scan: error: can't connect to wifi");
        state = AsyncData(state.value!.copyWith(status: Status.error));
      }
    } on PlatformException catch (e, s) {
      logger.e("kiosk mode: wifi_scan: error: $e");
      state = AsyncError(e, s);
    }
  }

  Future<void> retry() async {
    state = AsyncLoading();
    await _scan();
  }
}

final wifiScanNotifierProvider =
    AsyncNotifierProvider<WifiScanNotifier, WifiScanState>(
        WifiScanNotifier.new);
