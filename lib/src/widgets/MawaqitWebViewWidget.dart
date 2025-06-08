import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mawaqit/const/resource.dart';
//import 'package:location/location.dart' hide LocationAccuracy;
import 'package:mawaqit/i18n/l10n.dart';
import 'package:mawaqit/src/const/constants.dart';
import 'package:mawaqit/src/domain/model/position/PositionResponse.dart';
import 'package:mawaqit/src/elements/Loader.dart';
import 'package:mawaqit/src/helpers/HexColor.dart';
import 'package:mawaqit/src/pages/OfflineScreen.dart';
import 'package:provider/provider.dart';
import 'package:store_redirect/store_redirect.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:mawaqit/src/domain/model/position/PositionOptions.dart';
import 'package:mawaqit/src/services/user_preferences_manager.dart';

/// responsible for rendering a web-view for mawaqit
class MawaqitWebViewWidget extends StatefulWidget {
  final String? path;

  /// clean up web specific component like header - footer - breadcrumb
  final bool clean;

  MawaqitWebViewWidget({Key? key, this.path, this.clean = false}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new MawaqitWebViewWidgetState();
  }
}

class MawaqitWebViewWidgetState extends State<MawaqitWebViewWidget>
    with AutomaticKeepAliveClientMixin<MawaqitWebViewWidget> {
  @override
  bool get wantKeepAlive => true;

  InAppWebViewController? webViewController;

  PullToRefreshController? pullToRefreshController;

  List<StreamSubscription<Position>> webViewGPSPositionStreams = [];
  late bool isLoading;

  bool hasError = false;

  final Set<Factory<OneSequenceGestureRecognizer>> _gSet = [
    Factory<VerticalDragGestureRecognizer>(() => VerticalDragGestureRecognizer()),
    Factory<ScaleGestureRecognizer>(() => ScaleGestureRecognizer()),
    Factory<PanGestureRecognizer>(() => PanGestureRecognizer()),
  ].toSet();

  @override
  void initState() {
    super.initState();
    isLoading = true;

    pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(
        color: Colors.blue,
      ),
      onRefresh: () async {
        if (Platform.isAndroid) {
          webViewController?.reload();
        } else if (Platform.isIOS) {
          webViewController?.loadUrl(urlRequest: URLRequest(url: await webViewController?.getUrl()));
        }
      },
    );

    /*widget.stream.listen((currentIndex) {
      if (widget.pos != currentIndex) {
        if (Platform.isAndroid) {
          try {
            _webViewController.pauseTimers(); // Pause timers only for android
            _webViewController.android.pause();
          } catch (e) {}
        }
      } else {
        if (Platform.isAndroid) {
          try {
            _webViewController.resumeTimers();
            _webViewController.android.resume();
          } catch (e) {}
        }
      }
    });*/
  }

  @override
  void didUpdateWidget(covariant MawaqitWebViewWidget oldWidget) {
    if (oldWidget.path != widget.path) {
      webViewController!.loadUrl(
        urlRequest: URLRequest(
          url: WebUri.uri(Uri.parse(widget.path!)),
        ),
      );
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    webViewGPSPositionStreams
        .forEach((StreamSubscription<Position> _flutterGeolocationStream) => _flutterGeolocationStream.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    print(widget.path);
    final userPreferences = context.watch<UserPreferencesManager>();

    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
          webViewController?.scrollBy(x: 0, y: 100);
          return KeyEventResult.handled;
        } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
          webViewController?.scrollBy(x: 0, y: -100);
          return KeyEventResult.handled;
        }

        return KeyEventResult.ignored;
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (hasError)
            buildErrorWidget(userPreferences)
          else
            InAppWebView(
              key: ValueKey(widget.path),
              initialUrlRequest: URLRequest(url: WebUri.uri((Uri.parse(widget.path!)))),
              gestureRecognizers: _gSet,
              initialOptions: InAppWebViewGroupOptions(
                  crossPlatform: InAppWebViewOptions(
                    supportZoom: false,
                    useShouldOverrideUrlLoading: true,
                    useOnDownloadStart: true,
                    mediaPlaybackRequiresUserGesture: false,
                    userAgent: Platform.isAndroid
                        ? MawaqitBackendSettingsConstant.kSettingsAndroidUserAgent
                        : MawaqitBackendSettingsConstant.kSettingsIosUserAgent,
                  ),
                  android: AndroidInAppWebViewOptions(
                    useHybridComposition: true,
                  ),
                  ios: IOSInAppWebViewOptions(
                    allowsInlineMediaPlayback: true,
                  )),
              onWebViewCreated: (InAppWebViewController controller) {
                webViewController = controller;
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
                          _geolocationGetCurrentPosition(parseInt(geolocationData['flutterGeolocationIndex'] ?? 0),
                              PositionOptions().from(geolocationData['option'] ?? null));
                          break;

                        case "watchPosition":
                          _geolocationWatchPosition(parseInt(geolocationData['flutterGeolocationIndex'] ?? 0)!,
                              PositionOptions().from(geolocationData['option'] ?? null));
                          break;
                        default:
                      }
                    });
              },
              androidOnPermissionRequest:
                  (InAppWebViewController controller, String origin, List<String> resources) async =>
                      PermissionRequestResponse(
                resources: resources,
                action: PermissionRequestResponseAction.GRANT,
              ),
              shouldOverrideUrlLoading: (controller, navigationAction) async {
                var uri = navigationAction.request.url!;
                print("uri.scheme");
                print(uri.scheme);
                if (Platform.isAndroid && ["intent"].contains(uri.scheme)) {
                  if (uri.toString().indexOf("maps") != -1) {
                    var link = uri.toString().substring(uri.toString().indexOf('?link=') + 6);
                    // print(link);
                    AndroidIntent intent = AndroidIntent(action: 'action_view', data: link);
                    await intent.launch();
                  } else {
                    String id = uri
                        .toString()
                        .substring(uri.toString().indexOf('id%3D') + 5, uri.toString().indexOf('#Intent'));
                    await StoreRedirect.redirect(androidAppId: id);
                  }
                  return NavigationActionPolicy.CANCEL;
                } else if (!["http", "https", "chrome", "data", "javascript", "file", "about"].contains(uri.scheme)) {
                  if (await canLaunchUrl(uri)) {
                    // Launch the App
                    await launchUrl(uri);
                    // and cancel the request
                    return NavigationActionPolicy.CANCEL;
                  }
                }
                return NavigationActionPolicy.ALLOW;
              },
              onLoadStart: (controller, url) {
                setState(() => isLoading = true);
              },
              onLoadStop: (controller, url) async {
                pullToRefreshController!.endRefreshing();
                Future.delayed(const Duration(milliseconds: 500), () => _geolocationAlertFix());
                if (widget.clean) {
                  await webViewController!.injectJavascriptFileFromAsset(
                    assetFilePath: R.ASSETS_SCRIPTS_CLEAN_JS,
                  );
                }
                this.setState(() => isLoading = false);
              },
              onDownloadStart: (controller, url) async {
                if (await canLaunch(url.toString())) {
                  // Launch the App
                  await launch(
                    url.toString(),
                  );
                  // and cancel the request
                }
              },
              onLoadError: (controller, url, code, message) {
                pullToRefreshController!.endRefreshing();
                setState(() {
                  hasError = true;
                });
              },
              onProgressChanged: (controller, progress) {
                if (progress == 100) {
                  pullToRefreshController!.endRefreshing();
                }
              },
              onUpdateVisitedHistory: (controller, url, androidIsReload) {},
              onConsoleMessage: (controller, consoleMessage) {
                print(consoleMessage);
              },
            ),
          (isLoading)
              ? Positioned(
                  top: 0,
                  bottom: 0,
                  right: 0,
                  left: 0,
                  child: Container(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: Loader(
                        type: "Circle",
                        color: Theme.of(context).brightness == Brightness.light
                            ? HexColor("#490094")
                            : Theme.of(context).primaryColor),
                  ),
                )
              : Container()
        ],
      ),
    );
  }

  Widget buildErrorWidget(userPreferences) {
    return WillPopScope(
      child: OfflineScreen(onPressedTryAgain: () {
        userPreferences.webViewMode = false;
      }),
      onWillPop: () async {
        // print('will pop');
        if (await webViewController?.canGoBack() == true) {
          setState(() {
            hasError = false;
            isLoading = true;
          });
          await webViewController!.goBack();
          return false;
        }

        return true;
      },
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
      LocationPermission geolocationStatus = await GeolocatorPlatform.instance.requestPermission();

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
        //Location location = new Location();
        //bool _serviceEnabled;

        // _serviceEnabled = await location.serviceEnabled();
        // if (!_serviceEnabled) {
        //   _serviceEnabled = await location.requestService();
        //   if (!_serviceEnabled) {}
        // }
      }
    } catch (e) {
      // Location location = new Location();
      // bool _serviceEnabled;
      //
      // _serviceEnabled = await location.serviceEnabled();
      // if (!_serviceEnabled) {
      //   _serviceEnabled = await location.requestService();
      //   if (!_serviceEnabled) {}
      // }
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

    webViewController!.evaluateJavascript(source: javascript);

    webViewController!.evaluateJavascript(source: """
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

    webViewController!.evaluateJavascript(source: javascript);
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

      webViewController!.evaluateJavascript(source: javascript);
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

      webViewController!.evaluateJavascript(source: javascript);
    }
  }

  void _geolocationWatchPosition(
    int flutterGeolocationIndex,
    PositionOptions positionOptions,
  ) {
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

  Future<void> goHome() async {
    if (webViewController == null) return;
    while (await webViewController!.canGoBack()) {
      await webViewController!.goBack();
    }
  }

  Future<bool> goBack() async {
    // print(await webViewController!.canGoBack());

    if (webViewController != null) {
      if (await webViewController!.canGoBack()) {
        webViewController!.goBack();
        return false;
      } else {
        return await showDialog<bool>(
              context: context,
              builder: (context) => new AlertDialog(
                title: new Text(S.of(context).closeApp),
                content: new Text(S.of(context).sureCloseApp),
                actions: <Widget>[
                  new TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: new Text(S.of(context).cancel),
                  ),
                  SizedBox(height: 16),
                  new TextButton(
                    onPressed: () => SystemNavigator.pop(),
                    child: new Text(S.of(context).ok),
                  ),
                ],
              ),
            ) ??
            false;
      }
    }
    return true;
  }
}
