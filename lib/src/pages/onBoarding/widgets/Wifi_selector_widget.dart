import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/main.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';
import 'package:mawaqit/src/helpers/TimeShiftManager.dart';
import 'package:mawaqit/src/pages/onBoarding/widgets/onboarding_timezone_selector.dart';
import 'package:mawaqit/src/state_management/kiosk_mode/wifi_scan/wifi_scan_notifier.dart';
import 'package:mawaqit/src/state_management/kiosk_mode/wifi_scan/wifi_scan_state.dart';
import 'package:wifi_hunter/wifi_hunter_result.dart';
import 'package:wifi_scan/wifi_scan.dart';

const String nativeMethodsChannel = 'nativeMethodsChannel';

class OnBoardingWifiSelector extends ConsumerStatefulWidget {
  const OnBoardingWifiSelector({Key? key, required this.onSelect}) : super(key: key);

  final void Function() onSelect;

  @override
  _OnBoardingWifiSelectorState createState() => _OnBoardingWifiSelectorState();
}

class _OnBoardingWifiSelectorState extends ConsumerState<OnBoardingWifiSelector> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(wifiScanNotifierProvider.notifier).retry();
    });
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
        SizedBox(height: 10),
        Text(
          S.of(context).appWifi,
          style: TextStyle(
            fontSize: 25.0,
            fontWeight: FontWeight.w700,
            color: themeData.brightness == Brightness.dark ? null : themeData.primaryColor,
          ),
        ),
        const SizedBox(height: 10),
        Divider(
          thickness: 1,
          color: themeData.brightness == Brightness.dark ? Colors.white : Colors.black,
        ),
        const SizedBox(height: 10),
        Text(
          S.of(context).descWifi,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: themeData.brightness == Brightness.dark ? null : themeData.primaryColor,
          ),
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              style: ButtonStyle(
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
              icon: const Icon(Icons.refresh),
              label: Text(S.of(context).scanAgain),
              onPressed: () async => await ref.read(wifiScanNotifierProvider.notifier).retry(),
            ),
          ],
        ),
        SizedBox(height: 20),
        Expanded(
          child: wifiScanState.when(
            data: (state) => state.accessPoints.isEmpty
                ? Text(S.of(context).noScannedResultsFound)
                : _buildAccessPointsList(state.accessPoints, state.hasPermission, accessPointsFocusNode),
            error: (error, s) {
              _showToast('Error fetching access points');

              return Container();
            },
            loading: () => Align(
              child: SizedBox(
                child: CircularProgressIndicator(
                  strokeWidth: 3,
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
      padding: EdgeInsets.only(top: 5),
      child: ListView.builder(
        padding: EdgeInsets.only(
          top: 5,
          bottom: 5,
        ),
        itemCount: filteredAccessPoints.length,
        itemBuilder: (context, i) => _AccessPointTile(
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
  final bool hasPermission;
  final void Function() onSelect;
  final FocusNode focusNode;
  _AccessPointTile({
    Key? key,
    required this.focusNode,
    required this.onSelect,
    required this.accessPoint,
    required this.hasPermission,
  }) : super(key: key);

  @override
  _AccessPointTileState createState() => _AccessPointTileState();
}

class _AccessPointTileState extends ConsumerState<_AccessPointTile> {
  final TextEditingController passwordController = TextEditingController();
  bool _showPassword = false;
  void _showToast(String message) {
/*     Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0,
    ); */
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
    Future<void> _simulateTabPress() async {
      try {
        await platform.invokeMethod('sendTabKeyEvent');
      } on PlatformException catch (e) {
        logger.e(e);
      }
    }

    Future<void> _simulateDownArrow() async {
      try {
        await platform.invokeMethod('sendDownArrowEvent');
      } on PlatformException catch (e) {
        logger.e(e);
      }
    }

    KeyEventResult _handleKeyEvent(FocusNode focusNode, RawKeyEvent event) {
      if (event is RawKeyDownEvent) {
        if (event.logicalKey == LogicalKeyboardKey.arrowRight || event.logicalKey == LogicalKeyboardKey.arrowLeft) {
          _simulateTabPress();
          _simulateDownArrow();

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
        leading: Icon(signalIcon),
        title: Text(title),
        onTap: () => showDialog(
          context: context,
          builder: (context) => StatefulBuilder(
            builder: (context, setState) => AlertDialog(
              title: Text(title),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: passwordController,
                    obscureText: !_showPassword,
                    decoration: InputDecoration(
                      labelText: S.of(context).wifiPassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showPassword ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _showPassword = !_showPassword;
                          });
                        },
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.of(context).pop();

                      await ref.read(wifiScanNotifierProvider.notifier).connectToWifi(
                            widget.accessPoint.ssid,
                            widget.accessPoint.capabilities,
                            passwordController.text,
                          );
                    },
                    child: Text(S.of(context).connect),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
