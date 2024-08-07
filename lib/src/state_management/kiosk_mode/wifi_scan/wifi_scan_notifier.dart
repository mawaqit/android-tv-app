import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/main.dart';
import 'package:mawaqit/src/helpers/TimeShiftManager.dart';
import 'package:mawaqit/src/state_management/kiosk_mode/wifi_scan/wifi_scan_state.dart';
import 'package:wifi_hunter/wifi_hunter.dart';
import 'package:wifi_hunter/wifi_hunter_result.dart';
import 'package:wifi_scan/wifi_scan.dart';

import '../../../pages/onBoarding/widgets/onboarding_timezone_selector.dart';

class WifiScanNotifier extends AsyncNotifier<WifiScanState> {
  final TimeShiftManager _timeManager = TimeShiftManager();
  WiFiHunterResult wiFiHunterResult = WiFiHunterResult();
  @override
  Future<WifiScanState> build() async {
    state = AsyncData(WifiScanState(
      accessPoints: [],
      hasPermission: false,
      status: Status.connecting,
    ));
    await _scan();
    return state.value!;
  }

  Future<void> huntWiFis() async {
    try {} on PlatformException catch (exception) {
      print(exception.toString());
    }
  }

  Future<void> _scan() async {
    state = AsyncLoading();
    try {
      final wiFiHunterResult = await WiFiHunter.huntWiFiNetworks;

      state = AsyncData(
        state.value!.copyWith(accessPoints: wiFiHunterResult!.results, hasPermission: true, status: Status.connecting),
      );
    } catch (e, s) {
      logger.e("kiosk mode: wifi_scan: error: $e");
      state = AsyncError(e, s);
    }
  }

  Future<void> connectToWifi(String ssid, String security, String password) async {
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
    if (state.value != null) {
      state = AsyncData(state.value!.copyWith(status: Status.connecting));
    } else {
      state = AsyncData(WifiScanState(
        accessPoints: [],
        hasPermission: false,
        status: Status.connecting,
      ));
    }
    await _scan();
  }
}

final wifiScanNotifierProvider = AsyncNotifierProvider<WifiScanNotifier, WifiScanState>(WifiScanNotifier.new);
