import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart' hide Page;
import 'package:flutter/rendering.dart';
import 'package:flyweb/src/elements/Loader.dart';
import 'package:flyweb/src/helpers/HexColor.dart';
import 'package:flyweb/src/models/page.dart';
import 'package:flyweb/src/models/settings.dart';
import 'package:flyweb/src/services/theme_manager.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class PageScreen extends StatefulWidget {
  final Page page;
  final Settings settings;

  const PageScreen(this.page, this.settings);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new _PageScreen();
  }
}

class _PageScreen extends State<PageScreen> {
  InAppWebViewController _webViewController;
  bool isLoading;

  @override
  void initState() {
    super.initState();
    isLoading = true;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    var themeProvider = Provider.of<ThemeNotifier>(context);

    return Scaffold(
        appBar: _renderAppBar(context, widget.settings, widget.page),
        body: Stack(fit: StackFit.expand, children: [
          InAppWebView(
            // contextMenu: contextMenu,
            initialUrlRequest: URLRequest(url: Uri.parse(widget.page.url)),
            initialOptions: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(
                    supportZoom: false,
                    useShouldOverrideUrlLoading: true,
                    useOnDownloadStart: true,
                    mediaPlaybackRequiresUserGesture: false,
                    userAgent: Platform.isAndroid
                        ? widget.settings.userAgent.valueAndroid
                        : widget.settings.userAgent.valueIOS),
                android: AndroidInAppWebViewOptions(
                  useHybridComposition: true,
                ),
                ios: IOSInAppWebViewOptions(
                  allowsInlineMediaPlayback: true,
                )),
            onWebViewCreated: (InAppWebViewController controller) {
              _webViewController = controller;
            },
            androidOnPermissionRequest: (InAppWebViewController controller,
                String origin, List<String> resources) async {
              return PermissionRequestResponse(
                  resources: resources,
                  action: PermissionRequestResponseAction.GRANT);
            },
            onLoadStart: (controller, url) {
              setState(() {
                //this.url = url.toString();
                isLoading = true;
              });
            },
            onLoadStop: (controller, url) async {
              this.setState(() {
                isLoading = false;
              });
            },
            onDownloadStart: (controller, url) async {
              await launch(
                url.toString(),
              );
            },
            onLoadError: (controller, url, code, message) {
              // pullToRefreshController.endRefreshing();
            },
            onProgressChanged: (controller, progress) {
              if (progress == 100) {
                //pullToRefreshController.endRefreshing();
              }
            },
            onUpdateVisitedHistory: (controller, url, androidIsReload) {
              setState(() {
                // this.url = url.toString();
              });
            },
            onConsoleMessage: (controller, consoleMessage) {
              print(consoleMessage);
            },
          ),
          (isLoading && widget.settings.loader != "empty")
              ? Positioned(
                  top: 0,
                  bottom: 0,
                  right: 0,
                  left: 0,
                  child: Loader(
                      type: widget.settings.loader,
                      color: themeProvider.isLightTheme
                          ? HexColor(widget.settings.loaderColor)
                          : themeProvider.darkTheme.primaryColor))
              : Container()
        ]));
  }
}

Widget _renderAppBar(context, Settings settings, Page page) {
  var themeProvider = Provider.of<ThemeNotifier>(context);
  return AppBar(
      title: Text(
        page.title,
        style: TextStyle(
            color: Colors.white, fontSize: 22.0, fontWeight: FontWeight.bold),
      ),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: <Color>[
              themeProvider.isLightTheme
                  ? HexColor(settings.firstColor)
                  : themeProvider.darkTheme.primaryColor,
              themeProvider.isLightTheme
                  ? HexColor(settings.secondColor)
                  : themeProvider.darkTheme.primaryColor,
            ],
          ),
        ),
      ));
}
