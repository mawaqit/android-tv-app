import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:wifi_scan/wifi_scan.dart';

import 'package:flutter/services.dart';

const String nativeFunctionsChannel = 'nativeFunctionsChannel';

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

  Future<void> _startScan() async {
    if (shouldCheckCan) {
      final can = await WiFiScan.instance.canStartScan();
      if (can != CanStartScan.yes) {
        if (mounted) print("Cannot start scan: $can");
        return;
      }
    }

    final result = await WiFiScan.instance.startScan();
    if (mounted) print("startScan: $result");
    setState(() => accessPoints = []);
    if (await _canGetScannedResults()) {
      final results = await WiFiScan.instance.getScannedResults();
      setState(() => accessPoints = results);
    }
  }

  Future<bool> _canGetScannedResults() async {
    if (shouldCheckCan) {
      final can = await WiFiScan.instance.canGetScannedResults();
      if (can != CanGetScannedResults.yes) {
        if (mounted) print("Cannot get scanned results: $can");
        accessPoints = [];
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
        SizedBox(height: 8),
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
              icon: const Icon(Icons.refresh),
              label: const Text('Scan Again'),
              onPressed: () async => _startScan(),
            ),
          ],
        ),
        SizedBox(height: 20),
        Expanded(
          child: accessPoints.isEmpty
              ? const Text("NO SCANNED RESULTS")
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

  _AccessPointTile({
    Key? key,
    required this.accessPoint,
    required this.hasPermission,
  }) : super(key: key);

  @override
  _AccessPointTileState createState() => _AccessPointTileState();
}

class _AccessPointTileState extends State<_AccessPointTile> {
  TextEditingController passwordController = TextEditingController();
  bool _showPassword = false;
  static const platform = MethodChannel(nativeFunctionsChannel);

  Future<void> connectToWifi(
      String ssid, String security, String password) async {
    try {
      await platform.invokeMethod('connectToWifi', {
        "ssid": ssid,
        "password": password,
        "security": security,
      });
    } on PlatformException catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.accessPoint.ssid.isNotEmpty
        ? widget.accessPoint.ssid
        : "**EMPTY**";
    final signalIcon = widget.accessPoint.level >= -80
        ? Icons.signal_wifi_4_bar
        : Icons.signal_wifi_0_bar;
    return ListTile(
      visualDensity: VisualDensity.compact,
      leading: Icon(signalIcon),
      title: Text(title),
      subtitle: Text(widget.accessPoint.capabilities),
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
                    labelText: 'Password',
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
                    print('pressed');
                    try {
                      await connectToWifi(
                        widget.accessPoint.ssid,
                        widget.accessPoint.capabilities,
                        passwordController.text,
                      );
                      Navigator.pop(context);
                    } catch (e, stack) {
                      print('Error: $e\n$stack');
                    }
                  },
                  child: Text('Connect'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
