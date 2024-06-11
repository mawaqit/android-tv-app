import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:wifi_scan/wifi_scan.dart';

import '../../../../main.dart';

const String nativeMethodsChannel = 'nativeMethodsChannel';

class OnBoardingWifiSelector extends StatefulWidget {
  const OnBoardingWifiSelector({Key? key, required this.onSelect})
      : super(key: key);

  final void Function() onSelect;

  @override
  _OnBoardingWifiSelectorState createState() => _OnBoardingWifiSelectorState();
}

class _OnBoardingWifiSelectorState extends State<OnBoardingWifiSelector> {
  late List<WiFiAccessPoint> accessPoints = [];
  StreamSubscription<List<WiFiAccessPoint>>? subscription;
  bool shouldCheckCan = true;
  bool _hasPermission = false;

  bool get isStreaming => subscription != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      await _startScan();
    });
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }

  Future<void> _startScan() async {
    if (shouldCheckCan) {
      final can = await WiFiScan.instance.canStartScan();
      if (can != CanStartScan.yes) {
        if (mounted) return;
      }
    }

    if (mounted) setState(() => accessPoints = []);
    if (await _canGetScannedResults()) {
      final results = await WiFiScan.instance.getScannedResults();
      setState(() => accessPoints = results);
    }
  }

  Future<bool> _canGetScannedResults() async {
    if (shouldCheckCan) {
      final can = await WiFiScan.instance.canGetScannedResults();
      if (can != CanGetScannedResults.yes) {
        if (mounted) accessPoints = [];
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    return Column(
      children: [
        SizedBox(height: 10),
        Text(
          S.of(context).appWifi,
          style: TextStyle(
            fontSize: 25.0,
            fontWeight: FontWeight.w700,
            color: themeData.brightness == Brightness.dark
                ? null
                : themeData.primaryColor,
          ),
        ),
        const SizedBox(height: 10),
        Divider(
          thickness: 1,
          color: themeData.brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
        ),
        const SizedBox(height: 10),
        Text(
          S.of(context).descWifi,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: themeData.brightness == Brightness.dark
                ? null
                : themeData.primaryColor,
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
              onPressed: () async => _startScan(),
            ),
          ],
        ),
        SizedBox(height: 20),
        Expanded(
          child: accessPoints.isEmpty
              ? Text(S.of(context).noScannedResultsFound)
              : _buildAccessPointsList(),
        ),
      ],
    );
  }

  Widget _buildAccessPointsList() {
    return Container(
      padding: EdgeInsets.only(top: 5),
      child: ListView.builder(
        padding: EdgeInsets.only(
          top: 5,
          bottom: 5,
        ),
        itemCount: accessPoints.length,
        itemBuilder: (context, i) => _AccessPointTile(
          onSelect: widget.onSelect,
          accessPoint: accessPoints[i],
          hasPermission: _hasPermission,
        ),
      ),
    );
  }
}

class _AccessPointTile extends StatefulWidget {
  final WiFiAccessPoint accessPoint;
  final bool hasPermission;
  final void Function() onSelect;

  _AccessPointTile({
    Key? key,
    required this.onSelect,
    required this.accessPoint,
    required this.hasPermission,
  }) : super(key: key);

  @override
  _AccessPointTileState createState() => _AccessPointTileState();
}

class _AccessPointTileState extends State<_AccessPointTile> {
  final TextEditingController passwordController = TextEditingController();
  bool _showPassword = false;
  static const platform = MethodChannel('nativeMethodsChannel');

  Future<void> connectToWifi(
      String ssid, String security, String password) async {
    try {
      bool isSuccess = await platform.invokeMethod('connectToWifi', {
        "ssid": ssid,
        "password": password,
        "security": security,
      });
      if (isSuccess) {
        _showToast(S.of(context).wifiSuccess);
        Navigator.pop(context);
        widget.onSelect?.call();
      } else {
        _showToast(S.of(context).wifiFailure);
        Navigator.pop(context);
      }
    } on PlatformException catch (e) {
      _showToast(S.of(context).wifiFailure);
    }
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.accessPoint.ssid.isNotEmpty
        ? widget.accessPoint.ssid
        : S.of(context).noSSID;
    final signalIcon = widget.accessPoint.level >= -80
        ? Icons.signal_wifi_4_bar
        : Icons.signal_wifi_0_bar;
    return ListTile(
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
                    try {
                      await connectToWifi(
                        widget.accessPoint.ssid,
                        widget.accessPoint.capabilities,
                        passwordController.text,
                      );
                    } catch (e, stack) {
                      logger.e(e, stackTrace: stack);
                    }
                  },
                  child: Text(S.of(context).connect),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
