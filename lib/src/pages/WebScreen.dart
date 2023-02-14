import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:geolocator/geolocator.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/elements/RaisedGradientButton.dart';
import 'package:mawaqit/src/enum/connectivity_status.dart';
import 'package:mawaqit/src/helpers/HexColor.dart';
import 'package:mawaqit/src/models/settings.dart';
import 'package:mawaqit/src/services/settings_manager.dart';
import 'package:mawaqit/src/themes/UIImages.dart';
import 'package:mawaqit/src/widgets/MawaqitWebViewWidget.dart';
import 'package:provider/provider.dart';
import 'package:uni_links/uni_links.dart';

class WebScreen extends StatefulWidget {
  final String? url;

  const WebScreen(this.url);

  @override
  State<StatefulWidget> createState() {
    return new _WebScreen();
  }
}

class _WebScreen extends State<WebScreen> {
  InAppWebViewController? get _webViewController => webViewKey.currentState?.webViewController;
  final webViewKey = GlobalKey<MawaqitWebViewWidgetState>();

  PullToRefreshController? pullToRefreshController;

  List<StreamSubscription<Position>> webViewGPSPositionStreams = [];

  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();

    pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(color: Colors.blue),
      onRefresh: () async {
        if (Platform.isAndroid) {
          _webViewController?.reload();
        } else if (Platform.isIOS) {
          _webViewController?.loadUrl(urlRequest: URLRequest(url: await _webViewController?.getUrl()));
        }
      },
    );

    _handleIncomingLinks();
  }

  void _handleIncomingLinks() {
    if (!kIsWeb) {
      _sub = uriLinkStream.listen((Uri? uri) {
        var link = uri.toString().replaceAll('${GlobalConfiguration().getValue('deeplink')}://url/', '');
        _webViewController?.loadUrl(urlRequest: URLRequest(url: Uri.parse(link)));
      }, onError: (Object err) {});
    }
  }

  @override
  void dispose() {
    _sub?.cancel();

    webViewGPSPositionStreams
        .forEach((StreamSubscription<Position> _flutterGeolocationStream) => _flutterGeolocationStream.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    var bottomPadding = mediaQueryData.padding.bottom;
    var connectionStatus = Provider.of<ConnectivityStatus>(context);
    final settingsManager = Provider.of<SettingsManager>(context);
    final settings = settingsManager.settings;

    if (connectionStatus == ConnectivityStatus.Offline) return _offline(bottomPadding, settings);

    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Container(
        decoration: BoxDecoration(color: HexColor("#f5f4f4")),
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: Scaffold(
          appBar: _renderAppBar(context, settings),
          body: MawaqitWebViewWidget(path: widget.url, key: webViewKey),
        ),
      ),
    );
  }

  Widget _offline(bottomPadding, Settings settings) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Container(
          decoration: BoxDecoration(color: HexColor("#f5f4f4")),
          padding: EdgeInsets.only(bottom: bottomPadding),
          child: Scaffold(
            body: Column(
              children: <Widget>[
                Container(
                  height: 130,
                ),
                Column(crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
                  Container(
                      width: 100.0,
                      height: 100.0,
                      child: Image.asset(
                        UIImages.imageDir + "/wifi.png",
                        color: Colors.black26,
                        fit: BoxFit.contain,
                      )),
                  SizedBox(height: 40),
                  Text(
                    S.of(context).whoops,
                    style: TextStyle(color: Colors.black45, fontSize: 40.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Text(
                    S.of(context).noInternet,
                    style: TextStyle(color: Colors.black87, fontSize: 15.0),
                  ),
                  SizedBox(height: 5),
                  SizedBox(height: 60),
                  RaisedGradientButton(
                      child: Text(
                        S.of(context).tryAgain,
                        style: TextStyle(color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.bold),
                      ),
                      width: 250,
                      gradient: LinearGradient(
                        colors: <Color>[HexColor(settings.secondColor), HexColor(settings.firstColor)],
                      ),
                      onPressed: () {}),
                ]),
                Container(
                  height: 100,
                ),
              ],
            ),
          )),
    );
  }

  PreferredSizeWidget _renderAppBar(context, Settings settings) {
    return AppBar(
        flexibleSpace: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: <Color>[
            Theme.of(context).brightness == Brightness.light
                ? HexColor(settings.firstColor)
                : Theme.of(context).primaryColor,
            Theme.of(context).brightness == Brightness.light
                ? HexColor(settings.secondColor)
                : Theme.of(context).primaryColor,
          ],
        ),
      ),
    ));
  }

  Future<bool> _onBackPressed() async {
    try {
      if (_webViewController != null) {
        if (await _webViewController!.canGoBack()) {
          _webViewController!.goBack();
          return false;
        } else {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      Navigator.pop(context);
    }
    return true;
  }
}
