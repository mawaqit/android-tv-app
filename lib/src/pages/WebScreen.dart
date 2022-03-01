import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:android_intent/android_intent.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flyweb/generated/l10n.dart';
import 'package:flyweb/src/elements/Loader.dart';
import 'package:flyweb/src/elements/RaisedGradientButton.dart';
import 'package:flyweb/src/enum/connectivity_status.dart';
import 'package:flyweb/src/helpers/HexColor.dart';
import 'package:flyweb/src/helpers/OneSignalHelper.dart';
import 'package:flyweb/src/models/settings.dart';
import 'package:flyweb/src/position/PositionOptions.dart';
import 'package:flyweb/src/position/PositionResponse.dart';
import 'package:flyweb/src/services/settings_manager.dart';
import 'package:flyweb/src/services/theme_manager.dart';
import 'package:flyweb/src/themes/UIImages.dart';
import 'package:geolocator/geolocator.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:location/location.dart' hide LocationAccuracy;
import 'package:provider/provider.dart';
import 'package:store_redirect/store_redirect.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';

class WebScreen extends StatefulWidget {
  final String? url;

  const WebScreen(this.url);

  @override
  State<StatefulWidget> createState() {
    return new _WebScreen();
  }
}

class _WebScreen extends State<WebScreen> {
  static GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  InAppWebViewController? _webViewController;
  String url = "";
  final GlobalKey webViewKey = GlobalKey();
  PullToRefreshController? pullToRefreshController;

  List<StreamSubscription<Position>> webViewGPSPositionStreams = [];
  late bool isLoading;

  Uri? _initialUri;
  Uri? _latestUri;
  StreamSubscription? _sub;

  final Set<Factory<OneSequenceGestureRecognizer>> _gSet = [
    Factory<VerticalDragGestureRecognizer>(() => VerticalDragGestureRecognizer()),
    Factory<ScaleGestureRecognizer>(() => ScaleGestureRecognizer()),
    Factory<PanGestureRecognizer>(() => PanGestureRecognizer()),
  ].toSet();

  @override
  void initState() {
    isLoading = true;
    super.initState();

    pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(
        color: Colors.blue,
      ),
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
        if (!mounted) return;
        print('got uri: $uri');
        setState(() {
          _latestUri = uri;
        });
        var link = uri.toString().replaceAll('${GlobalConfiguration().getValue('deeplink')}://url/', '');
        _webViewController?.loadUrl(urlRequest: URLRequest(url: Uri.parse(link)));
      }, onError: (Object err) {
        if (!mounted) return;
        print('got err: $err');
        setState(() {
          _latestUri = null;
        });
      });
    }
  }

  @override
  void dispose() {
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

    var themeProvider = Provider.of<ThemeNotifier>(context);
    //var onesignalProvider = Provider.of<OneSignalHelper>(context);
    //OneSignalHelper oneSignalHelper = new OneSignalHelper();
    if (connectionStatus == ConnectivityStatus.Offline) return _offline(bottomPadding, settings);

    final _oneSignalHelper = OneSignalHelper();
    void _listenerOneSignal() {
      _webViewController?.loadUrl(urlRequest: URLRequest(url: Uri.parse(_oneSignalHelper.url!)));
    }

    _oneSignalHelper.addListener(_listenerOneSignal);

    return WillPopScope(
      onWillPop: () async {
        return _onBackPressed(context);
      },
      child: Container(
          decoration: BoxDecoration(color: HexColor("#f5f4f4")),
          padding: EdgeInsets.only(bottom: bottomPadding),
          child: Scaffold(
              key: _scaffoldKey,
              appBar: _renderAppBar(context, settings) as PreferredSizeWidget?,
              body: Stack(
                fit: StackFit.expand,
                children: [
                  Column(children: [
                    Expanded(
                        child: InAppWebView(
                      key: webViewKey,
                      // contextMenu: contextMenu,
                      initialUrlRequest: URLRequest(url: Uri.parse(widget.url!)),
                      gestureRecognizers: _gSet,
                      initialOptions: InAppWebViewGroupOptions(
                          crossPlatform: InAppWebViewOptions(
                              supportZoom: false,
                              useShouldOverrideUrlLoading: true,
                              useOnDownloadStart: true,
                              mediaPlaybackRequiresUserGesture: false,
                              userAgent: Platform.isAndroid
                                  ? settings.userAgent!.valueAndroid!
                                  : settings.userAgent!.valueIOS!),
                          android: AndroidInAppWebViewOptions(
                            useHybridComposition: true,
                          ),
                          ios: IOSInAppWebViewOptions(
                            allowsInlineMediaPlayback: true,
                          )),
                      pullToRefreshController: settings.pullRefresh == "1" ? pullToRefreshController : null,
                      onWebViewCreated: (InAppWebViewController controller) {
                        controller.addJavaScriptHandler(
                            handlerName: '_flutterGeolocation',
                            callback: (args) {
                              dynamic geolocationData;
                              // try to decode json
                              try {
                                geolocationData = json.decode(args[0]);
                                //geolocationData = json.decode(args[0].message);
                              } catch (e) {
                                // empty or what ever
                                return;
                              }
                              // Get action from JSON
                              final String action = geolocationData['action'] ?? "";

                              switch (action) {
                                case "clearWatch":
                                  _geolocationClearWatch(parseInt(geolocationData['flutterGeolocationIndex'] ?? 0)!);
                                  break;

                                case "getCurrentPosition":
                                  _geolocationGetCurrentPosition(
                                      parseInt(geolocationData['flutterGeolocationIndex'] ?? 0),
                                      PositionOptions().from(geolocationData['option'] ?? null));
                                  break;

                                case "watchPosition":
                                  _geolocationWatchPosition(parseInt(geolocationData['flutterGeolocationIndex'] ?? 0)!,
                                      PositionOptions().from(geolocationData['option'] ?? null));
                                  break;
                                default:
                              }
                            });
                        _webViewController = controller;
                      },
                      androidOnPermissionRequest:
                          (InAppWebViewController controller, String origin, List<String> resources) async {
                        return PermissionRequestResponse(
                            resources: resources, action: PermissionRequestResponseAction.GRANT);
                      },
                      shouldOverrideUrlLoading: (controller, navigationAction) async {
                        var uri = navigationAction.request.url;
                        if (Platform.isAndroid && ["intent"].contains(uri!.scheme)) {
                          if (uri.toString().indexOf("maps") != -1) {
                            var link = uri.toString().substring(uri.toString().indexOf('?link=') + 6);
                            print(link);
                            AndroidIntent intent = AndroidIntent(action: 'action_view', data: link);
                            await intent.launch();
                          } else {
                            String id = uri
                                .toString()
                                .substring(uri.toString().indexOf('id%3D') + 5, uri.toString().indexOf('#Intent'));
                            await StoreRedirect.redirect(androidAppId: id);
                          }

                          return NavigationActionPolicy.CANCEL;
                        } else if (!["http", "https", "chrome", "data", "javascript", "file", "about"]
                            .contains(uri!.scheme)) {
                          if (await canLaunch(uri.toString())) {
                            // Launch the App
                            await launch(
                              uri.toString(),
                            );
                            // and cancel the request
                            return NavigationActionPolicy.CANCEL;
                          }
                        }
                        return NavigationActionPolicy.ALLOW;
                      },
                      onLoadStart: (controller, url) {
                        setState(() {
                          this.url = url.toString();
                          isLoading = true;
                        });
                      },
                      onLoadStop: (controller, url) async {
                        pullToRefreshController!.endRefreshing();
                        Future.delayed(const Duration(milliseconds: 500), () {
                          _geolocationAlertFix();
                        });

                        this.setState(() {
                          this.url = url.toString();
                          isLoading = false;
                        });
                      },
                      onDownloadStart: (controller, url) async {
                        await launch(
                          url.toString(),
                        );
                      },
                      onLoadError: (controller, url, code, message) {
                        pullToRefreshController!.endRefreshing();
                      },
                      onProgressChanged: (controller, progress) {
                        if (progress == 100) {
                          pullToRefreshController!.endRefreshing();
                        }
                      },
                      onUpdateVisitedHistory: (controller, url, androidIsReload) {
                        setState(() {
                          this.url = url.toString();
                        });
                      },
                      onConsoleMessage: (controller, consoleMessage) {
                        print(consoleMessage);
                      },
                    )),
                  ]),
                  (isLoading && settings.loader != "empty")
                      ? Positioned(
                          top: 0,
                          bottom: 0,
                          right: 0,
                          left: 0,
                          child: Loader(
                              type: settings.loader,
                              color: themeProvider.isLightTheme!
                                  ? HexColor(settings.loaderColor)
                                  : themeProvider.darkTheme.primaryColor))
                      : Container()
                ],
              ))),
    );
  }

  Widget _offline(bottomPadding, Settings settings) {
    return WillPopScope(
      onWillPop: () async {
        return _onBackPressed(context);
      },
      child: Container(
          decoration: BoxDecoration(color: HexColor("#f5f4f4")),
          padding: EdgeInsets.only(bottom: bottomPadding),
          child: Scaffold(
            key: _scaffoldKey,
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
                    S.current.whoops,
                    style: TextStyle(color: Colors.black45, fontSize: 40.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Text(
                    S.current.noInternet,
                    style: TextStyle(color: Colors.black87, fontSize: 15.0),
                  ),
                  SizedBox(height: 5),
                  SizedBox(height: 60),
                  RaisedGradientButton(
                      child: Text(
                        S.current.tryAgain,
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

  int? parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;

    return int.tryParse(value) ?? null;
  }

  Future<PositionResponse> getCurrentPosition(PositionOptions positionOptions) async {
    PositionResponse positionResponse = PositionResponse();

    int? timeout = 30000;
    if (positionOptions.timeout! > 0) timeout = positionOptions.timeout;

    try {
      LocationPermission geolocationStatus = await Geolocator.requestPermission();

      if (geolocationStatus == LocationPermission.always || geolocationStatus == LocationPermission.whileInUse) {
        positionResponse.position = await Future.any([
          Geolocator.getCurrentPosition(
              desiredAccuracy: (positionOptions.enableHighAccuracy ? LocationAccuracy.best : LocationAccuracy.medium)),
          Future.delayed(Duration(milliseconds: timeout!), () {
            if (positionOptions.timeout! > 0) positionResponse.timedOut = true;
            return;
          })
        ]);
      } else {
        Location location = new Location();
        bool _serviceEnabled;

        _serviceEnabled = await location.serviceEnabled();
        if (!_serviceEnabled) {
          _serviceEnabled = await location.requestService();
          if (!_serviceEnabled) {}
        }
      }
    } catch (e) {
      Location location = new Location();
      bool _serviceEnabled;

      _serviceEnabled = await location.serviceEnabled();
      if (!_serviceEnabled) {
        _serviceEnabled = await location.requestService();
        if (!_serviceEnabled) {}
      }
    }

    return positionResponse;
  }

  void _geolocationAlertFix() {
    String javascript = '''
      var _flutterGeolocationIndex = 0;
      var _flutterGeolocationSuccess = [];
      var _flutterGeolocationError = [];

      function _flutterGeolocationAlertFix() {

        navigator.geolocation = {};
        navigator.geolocation.clearWatch = function(watchId) {
          _flutterGeolocation.postMessage(JSON.stringify({ action: 'clearWatch', flutterGeolocationIndex: watchId, option: {}}));
        };
        navigator.geolocation.getCurrentPosition = function(geolocationSuccess,geolocationError = null, geolocationOptionen = null) {
          _flutterGeolocationIndex++;
          _flutterGeolocationSuccess[_flutterGeolocationIndex] = geolocationSuccess;
          _flutterGeolocationError[_flutterGeolocationIndex] = geolocationError;
          _flutterGeolocation.postMessage(JSON.stringify({ action: 'getCurrentPosition', flutterGeolocationIndex: _flutterGeolocationIndex, option: geolocationOptionen}));
        };
        navigator.geolocation.watchPosition = function(geolocationSuccess,geolocationError = null, geolocationOptionen = {}) {
          _flutterGeolocationIndex++;
          _flutterGeolocationSuccess[_flutterGeolocationIndex] = geolocationSuccess;
          _flutterGeolocationError[_flutterGeolocationIndex] = geolocationError;
          _flutterGeolocation.postMessage(JSON.stringify({ action: 'watchPosition', flutterGeolocationIndex: _flutterGeolocationIndex, option: geolocationOptionen}));
          return _flutterGeolocationIndex;
        };
        return true;
      };
      setTimeout(function(){ _flutterGeolocationAlertFix(); }, 100);
    ''';

    _webViewController!.evaluateJavascript(source: javascript);

    _webViewController!.evaluateJavascript(source: """

      function _flutterGeolocationAlertFix() {

        navigator.geolocation = {};
        navigator.geolocation.clearWatch = function(watchId) {

  window.flutter_inappwebview.callHandler('_flutterGeolocation',      JSON.stringify({ action: 'clearWatch', flutterGeolocationIndex: watchId, option: {}})      ).then(function(result) {
      //alert(result);
    });

        };


        navigator.geolocation.getCurrentPosition = function(geolocationSuccess,geolocationError = null, geolocationOptionen = null) {

     _flutterGeolocationIndex++;
          _flutterGeolocationSuccess[_flutterGeolocationIndex] = geolocationSuccess;
          _flutterGeolocationError[_flutterGeolocationIndex] = geolocationError;



  window.flutter_inappwebview.callHandler('_flutterGeolocation',       JSON.stringify({ action: 'getCurrentPosition', flutterGeolocationIndex: _flutterGeolocationIndex, option: geolocationOptionen})      ).then(function(result) {
     });


     };
        navigator.geolocation.watchPosition = function(geolocationSuccess,geolocationError = null, geolocationOptionen = {}) {

         _flutterGeolocationIndex++;
          _flutterGeolocationSuccess[_flutterGeolocationIndex] = geolocationSuccess;
          _flutterGeolocationError[_flutterGeolocationIndex] = geolocationError;

  window.flutter_inappwebview.callHandler('_flutterGeolocation',      JSON.stringify({ action: 'watchPosition', flutterGeolocationIndex: _flutterGeolocationIndex, option: geolocationOptionen})      ).then(function(result) {
     });

          return _flutterGeolocationIndex;

        };
        return true;


    }
          setTimeout(function(){ _flutterGeolocationAlertFix(); }, 100);

  """);
  }

  void _geolocationClearWatch(int flutterGeolocationIndex) {
    // Stop gps position stream
    webViewGPSPositionStreams[flutterGeolocationIndex].cancel();

    // remove watcher from list
    webViewGPSPositionStreams.remove(flutterGeolocationIndex);

    // Remove functions from array
    String javascript = '''
      function _flutterGeolocationResponse() {
        _flutterGeolocationSuccess[''' +
        flutterGeolocationIndex.toString() +
        '''] = null;
        _flutterGeolocationError[''' +
        flutterGeolocationIndex.toString() +
        '''] = null;
        return true;
      };
      _flutterGeolocationResponse();
    ''';

    _webViewController!.evaluateJavascript(source: javascript);
  }

  void _geolocationGetCurrentPosition(int? flutterGeolocationIndex, PositionOptions positionOptions) async {
    PositionResponse positionResponse = await getCurrentPosition(positionOptions);

    _geolocationResponse(flutterGeolocationIndex, positionOptions, positionResponse, false);
  }

  void _geolocationResponse(
      int? flutterGeolocationIndex, PositionOptions positionOptions, PositionResponse positionResponse, bool watcher) {
    if (positionResponse.position != null) {
      String javascript = '''
        function _flutterGeolocationResponse() {
          _flutterGeolocationSuccess[''' +
          flutterGeolocationIndex.toString() +
          ''']({
            coords: {
              accuracy: ''' +
          positionResponse.position!.accuracy.toString() +
          ''',
              altitude: ''' +
          positionResponse.position!.altitude.toString() +
          ''',
              altitudeAccuracy: null,
              heading: null,
              latitude: ''' +
          positionResponse.position!.latitude.toString() +
          ''',
              longitude: ''' +
          positionResponse.position!.longitude.toString() +
          ''',
              speed: ''' +
          positionResponse.position!.speed.toString() +
          '''
            },
            timestamp: ''' +
          positionResponse.position!.timestamp!.millisecondsSinceEpoch.toString() +
          '''
          });''' +
          (!watcher ? "  _flutterGeolocationSuccess[" + flutterGeolocationIndex.toString() + "] = null; " : "") +
          (!watcher ? "  _flutterGeolocationError[" + flutterGeolocationIndex.toString() + "] = null; " : "") +
          '''
          return true;
        };
        _flutterGeolocationResponse();
      ''';

      _webViewController!.evaluateJavascript(source: javascript);
    } else {
      // TODO: Return correct error code
      String javascript = '''
        function _flutterGeolocationResponse() {
          if (_flutterGeolocationError[''' +
          flutterGeolocationIndex.toString() +
          '''] != null) {''' +
          (positionResponse.timedOut
              ? "_flutterGeolocationError[" +
                  flutterGeolocationIndex.toString() +
                  "]({code: 3, message: 'Request timed out', PERMISSION_DENIED: 1, POSITION_UNAVAILABLE: 2, TIMEOUT: 3}); "
              : "_flutterGeolocationError[" +
                  flutterGeolocationIndex.toString() +
                  "]({code: 1, message: 'User denied Geolocationg', PERMISSION_DENIED: 1, POSITION_UNAVAILABLE: 2, TIMEOUT: 3}); ") +
          "}" +
          (!watcher ? "  _flutterGeolocationSuccess[" + flutterGeolocationIndex.toString() + "] = null; " : "") +
          (!watcher ? "  _flutterGeolocationError[" + flutterGeolocationIndex.toString() + "] = null; " : "") +
          '''
          return true;
        };
        _flutterGeolocationResponse();
      ''';

      _webViewController!.evaluateJavascript(source: javascript);
    }
  }

  void _geolocationWatchPosition(int flutterGeolocationIndex, PositionOptions positionOptions) {
    // init new strem
    var locationOptions = LocationSettings(
        accuracy: (positionOptions.enableHighAccuracy ? LocationAccuracy.best : LocationAccuracy.medium),
        distanceFilter: 10);

    webViewGPSPositionStreams[flutterGeolocationIndex] =
        Geolocator.getPositionStream(locationSettings: locationOptions).listen((Position position) {
      // Send data to each warcher
      PositionResponse positionResponse = PositionResponse()..position = position;
      _geolocationResponse(flutterGeolocationIndex, positionOptions, positionResponse, true);
    });
  }

  Widget _renderAppBar(context, Settings settings) {
    var themeProvider = Provider.of<ThemeNotifier>(context);
    return AppBar(
        title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              IconButton(
                padding: const EdgeInsets.all(0.0),
                icon: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationY(math.pi * (Directionality.of(context) == TextDirection.ltr ? 2 : 1)),
                    child: Icon(
                      Icons.arrow_back,
                    )),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ]),
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: <Color>[
                themeProvider.isLightTheme! ? HexColor(settings.firstColor) : themeProvider.darkTheme.primaryColor,
                themeProvider.isLightTheme! ? HexColor(settings.secondColor) : themeProvider.darkTheme.primaryColor,
              ],
            ),
          ),
        ));
  }

  Future<bool> _onBackPressed(context) async {
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
