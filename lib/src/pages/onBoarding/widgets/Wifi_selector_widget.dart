import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:mawaqit/const/resource.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/main.dart';
import 'package:mawaqit/src/state_management/kiosk_mode/wifi_scan/wifi_scan_notifier.dart';
import 'package:mawaqit/src/state_management/kiosk_mode/wifi_scan/wifi_scan_state.dart';
import 'package:mawaqit/src/widgets/ScreenWithAnimation.dart';
import 'package:wifi_hunter/wifi_hunter_result.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart' as fp;

import 'onboarding_timezone_selector.dart';
import 'tv_wifi_password_screen.dart';

const String nativeMethodsChannel = 'nativeMethodsChannel';

class OnBoardingWifiSelector extends ConsumerStatefulWidget {
  const OnBoardingWifiSelector({Key? key, required this.onSelect, this.focusNode}) : super(key: key);

  final void Function() onSelect;
  final FocusNode? focusNode;

  @override
  _OnBoardingWifiSelectorState createState() => _OnBoardingWifiSelectorState();
}

class _OnBoardingWifiSelectorState extends ConsumerState<OnBoardingWifiSelector> {
  // Add a focus node for the scan again button
  final FocusNode _scanAgainButtonFocusNode = FocusNode(debugLabel: 'scan_again_button');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _addLocationPermission();
      await _addFineLocationPermission();
      await ref.read(wifiScanNotifierProvider.notifier).retry();
    });
  }

  @override
  void dispose() {
    _scanAgainButtonFocusNode.dispose();
    super.dispose();
  }

  Future<void> _addLocationPermission() async {
    try {
      await platform.invokeMethod('addLocationPermission');
    } on PlatformException catch (e) {
      logger.e("kiosk mode: location permission: error: $e");
    }
  }

  Future<void> _addFineLocationPermission() async {
    try {
      await platform.invokeMethod('grantFineLocationPermission');
    } on PlatformException catch (e) {
      logger.e("kiosk mode: location permission: error: $e");
    }
  }

  void _showToast(String message) {
    showToast(
      message,
      context: context,
      position: StyledToastPosition.bottom,
      duration: Duration(seconds: 4),
      curve: Curves.elasticOut,
      reverseCurve: Curves.linear,
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final wifiScanState = ref.watch(wifiScanNotifierProvider);
    final FocusNode accessPointsFocusNode = FocusNode();

    return Column(
      children: [
        Text(
          S.of(context).appWifi,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: themeData.brightness == Brightness.dark ? null : themeData.primaryColor,
          ),
        ),
        SizedBox(height: 1.h),
        Divider(
          thickness: 0.1.h,
          color: themeData.brightness == Brightness.dark ? Colors.white : Colors.black,
        ),
        SizedBox(height: 1.h),
        Text(
          S.of(context).descWifi,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12.sp,
            color: themeData.brightness == Brightness.dark ? null : themeData.primaryColor,
          ),
        ),
        SizedBox(height: 2.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              focusNode: _scanAgainButtonFocusNode,
              style: ButtonStyle(
                padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h)),
                backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.focused)) {
                      return const Color(0xFF490094); // Focus color
                    }
                    return null; // Use the default color
                  },
                ),
                foregroundColor: MaterialStateProperty.resolveWith<Color?>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.focused)) {
                      return Colors.white; // Text and icon color when focused
                    }
                    return null; // Use the default color
                  },
                ),
              ),
              icon: Icon(Icons.refresh, size: 16.sp),
              label: Text(
                S.of(context).scanAgain,
                style: TextStyle(fontSize: 10.sp),
              ),
              onPressed: () async => await ref.read(wifiScanNotifierProvider.notifier).retry(),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        Expanded(
          child: wifiScanState.when(
            data: (state) => state.accessPoints.isEmpty
                ? Text(
                    S.of(context).noScannedResultsFound,
                    style: TextStyle(fontSize: 14.sp),
                  )
                : _buildAccessPointsList(state.accessPoints, state.hasPermission, accessPointsFocusNode),
            error: (error, s) {
              _showToast('Error fetching access points');

              return Container();
            },
            loading: () => Align(
              child: SizedBox(
                child: CircularProgressIndicator(
                  strokeWidth: 0.5.h,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<WiFiHunterResultEntry> _filterAccessPoints(List<WiFiHunterResultEntry> accessPoints) {
    final seenSSIDs = <String>{};
    return accessPoints.where((ap) {
      if (ap.ssid == "**Hidden SSID**") {
        return true;
      }
      if (!seenSSIDs.contains(ap.ssid)) {
        seenSSIDs.add(ap.ssid);
        return true;
      }
      return false;
    }).toList();
  }

  _buildAccessPointsList(List<WiFiHunterResultEntry> accessPoints, bool _hasPermission, FocusNode node) {
    final filteredAccessPoints = _filterAccessPoints(accessPoints);

    return Container(
      padding: EdgeInsets.only(top: 0.5.h),
      child: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 0.5.h),
        itemCount: filteredAccessPoints.length,
        itemBuilder: (context, i) => _AccessPointTile(
          scanAgainFocusNode: _scanAgainButtonFocusNode,
          skipButtonFocusNode: widget.focusNode ?? FocusNode(),
          focusNode: node,
          onSelect: widget.onSelect,
          accessPoint: filteredAccessPoints[i],
          hasPermission: _hasPermission,
        ),
      ),
    );
  }
}

class _AccessPointTile extends ConsumerStatefulWidget {
  final WiFiHunterResultEntry accessPoint;
  final FocusNode skipButtonFocusNode;
  final FocusNode scanAgainFocusNode;
  final bool hasPermission;
  final void Function() onSelect;
  final FocusNode focusNode;

  _AccessPointTile({
    Key? key,
    required this.focusNode,
    required this.skipButtonFocusNode,
    required this.scanAgainFocusNode,
    required this.onSelect,
    required this.accessPoint,
    required this.hasPermission,
  }) : super(key: key);

  @override
  _AccessPointTileState createState() => _AccessPointTileState();
}

class _AccessPointTileState extends ConsumerState<_AccessPointTile> {
  void _showToast(String message) {
    showToast(
      message,
      context: context,
      position: StyledToastPosition.bottom,
      duration: Duration(seconds: 4),
      curve: Curves.elasticOut,
      reverseCurve: Curves.linear,
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.accessPoint.ssid.isNotEmpty ? widget.accessPoint.ssid : S.of(context).noSSID;
    final signalIcon = widget.accessPoint.level >= -80 ? Icons.signal_wifi_4_bar : Icons.signal_wifi_0_bar;

    ref.listen(wifiScanNotifierProvider, (previous, next) {
      if (next.hasValue && !next.isRefreshing && next.value!.status == Status.connected) {
        _showToast(S.of(context).wifiSuccess);
      }
      if (next.value!.status == Status.error) {
        _showToast(S.of(context).wifiFailure);
      }
    });

    KeyEventResult _handleKeyEvent(FocusNode focusNode, RawKeyEvent event) {
      if (event is RawKeyDownEvent) {
        if (event.logicalKey == LogicalKeyboardKey.arrowRight || event.logicalKey == LogicalKeyboardKey.arrowLeft) {
          FocusScope.of(context).requestFocus(widget.skipButtonFocusNode);

          return KeyEventResult.handled;
        }
      }
      return KeyEventResult.ignored;
    }

    return Focus(
      focusNode: widget.focusNode,
      onKey: (node, event) => _handleKeyEvent(node, event),
      child: ListTile(
        visualDensity: VisualDensity.compact,
        leading: Icon(signalIcon, size: 16.sp),
        title: Text(title, style: TextStyle(fontSize: 12.sp)),
        contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.5.h),
        onTap: () {
          // Always use the TV-friendly Wi-Fi password screen
          Navigator.of(context)
              .push(
            MaterialPageRoute(
              builder: (context) => TvWifiPasswordScreen(
                ssid: widget.accessPoint.ssid,
                capabilities: widget.accessPoint.capabilities,
                returnFocusNode: fp.Option.of(widget.focusNode),
                onComplete: (success) {
                  // Handle completion
                  if (success) {
                    widget.onSelect();
                  }

                  // We don't need to request focus here - the TvWifiPasswordScreen
                  // will ensure focus is handled properly when returning
                },
              ),
            ),
          )
              .then((wasCancelled) {
            Future.delayed(
              Duration(milliseconds: 500),
              () {
                if (wasCancelled == true) {
                  widget.scanAgainFocusNode.requestFocus();
                } else {
                  widget.focusNode.requestFocus();
                }
              },
            );
          });
        },
      ),
    );
  }
}
