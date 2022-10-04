import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:geolocator/geolocator.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:mawaqit/generated/l10n.dart';
import 'package:mawaqit/i18n/AppLanguage.dart';
import 'package:mawaqit/src/enum/connectivity_status.dart';
import 'package:mawaqit/src/helpers/AppRouter.dart';
import 'package:mawaqit/src/helpers/HexColor.dart';
import 'package:mawaqit/src/helpers/SharedPref.dart';
import 'package:mawaqit/src/models/floating.dart';
import 'package:mawaqit/src/models/navigationIcon.dart';
import 'package:mawaqit/src/models/settings.dart';
import 'package:mawaqit/src/pages/OfflineScreen.dart';
import 'package:mawaqit/src/pages/WebScreen.dart';
import 'package:mawaqit/src/pages/home/OfflineHomeScreen.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:mawaqit/src/services/settings_manager.dart';
import 'package:mawaqit/src/themes/UIImages.dart';
import 'package:mawaqit/src/widgets/MawaqitDrawer.dart';
import 'package:mawaqit/src/widgets/MawaqitWebViewWidget.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:uni_links/uni_links.dart';

GlobalKey<MawaqitWebViewWidgetState> key0 = GlobalKey();
GlobalKey<MawaqitWebViewWidgetState> key1 = GlobalKey();
GlobalKey<MawaqitWebViewWidgetState> key2 = GlobalKey();
GlobalKey<MawaqitWebViewWidgetState> key3 = GlobalKey();
GlobalKey<MawaqitWebViewWidgetState> key4 = GlobalKey();
GlobalKey<MawaqitWebViewWidgetState> keyMain = GlobalKey();
GlobalKey<MawaqitWebViewWidgetState> keyWebView = GlobalKey();
List<GlobalKey> listKey = [key0, key1, key2, key3, key4];

StreamController<int> _controllerStream0 = StreamController<int>();
StreamController<int> _controllerStream1 = StreamController<int>();
StreamController<int> _controllerStream2 = StreamController<int>();
StreamController<int> _controllerStream3 = StreamController<int>();
StreamController<int> _controllerStream4 = StreamController<int>();
List<StreamController<int>> listStream = [
  _controllerStream0,
  _controllerStream1,
  _controllerStream2,
  _controllerStream3,
  _controllerStream4
];

class HomeScreen extends StatefulWidget {
  final Settings settings;

  const HomeScreen(this.settings);

  @override
  State<StatefulWidget> createState() {
    return new _HomeScreen();
  }
}

class _HomeScreen extends State<HomeScreen> with SingleTickerProviderStateMixin {
  SharedPref sharedPref = SharedPref();

  static GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  Uri? _latestUri;
  StreamSubscription? _sub;
  bool goToWeb = true;

  List<StreamSubscription<Position>> webViewGPSPositionStreams = [];

  TabController? tabController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    _handleIncomingLinks();

    tabController = new TabController(
      initialIndex: 0,
      length: widget.settings.tabNavigationEnable == "1" ? widget.settings.tab!.length : 1,
      vsync: this,
    );
    tabController!.addListener(_handleTabSelection);
  }

  void _handleIncomingLinks() {
    if (!kIsWeb) {
      _sub = uriLinkStream.listen((Uri? uri) async {
        if (!mounted) return;
        print('got uri: $uri');
        setState(() {
          _latestUri = uri;
        });
        var link = uri.toString().replaceAll('${GlobalConfiguration().getValue('deeplink')}://url/', '');

        if (widget.settings.tabNavigationEnable == "1") {
          if (goToWeb) {
            setState(() {
              goToWeb = false;
            });
            AppRouter.push(WebScreen(link));

            setState(() {
              goToWeb = true;
            });
          }
        } else {
          key0.currentState!.webViewController?.loadUrl(
            urlRequest: URLRequest(
              url: Uri.parse(link),
            ),
          );
        }
      }, onError: (Object err) {
        if (!mounted) return;
        print('got err: $err');
        setState(() {
          _latestUri = null;
        });
      });
    }
  }

  _handleTabSelection() {
    setState(() => _currentIndex = tabController!.index);
  }

  @override
  void dispose() {
    webViewGPSPositionStreams
        .forEach((StreamSubscription<Position> _flutterGeolocationStream) => _flutterGeolocationStream.cancel());

    super.dispose();
  } 

  @override
  Widget build(BuildContext context) {
    final appLanguage = context.watch<AppLanguage>();
    final mosqueManager = context.watch<MosqueManager>();
    final settingsManager = context.read<SettingsManager>();
    final settings = settingsManager.settings;

    var url = mosqueManager.buildUrl(appLanguage.appLocal.languageCode);

    var bottomPadding = MediaQuery.of(context).padding.bottom;
    var connectionStatus = Provider.of<ConnectivityStatus>(context);

    if (connectionStatus == ConnectivityStatus.Offline)
      return WillPopScope(
        onWillPop: _onBackPressed,
        child: OfflineScreen(),
      );

    return WillPopScope(
      onWillPop: _onBackPressed,
      child: CallbackShortcuts(
        bindings: {
          SingleActivator(LogicalKeyboardKey.arrowLeft): () => _scaffoldKey.currentState?.openDrawer(),
          SingleActivator(LogicalKeyboardKey.arrowRight): () => _scaffoldKey.currentState?.openDrawer(),
        },
        child: Container(
            decoration: BoxDecoration(color: HexColor("#f5f4f4")),
            padding: EdgeInsets.only(bottom: bottomPadding),
            child: Scaffold(
              key: _scaffoldKey,
              appBar: _renderAppBar(context, settings) as PreferredSizeWidget?,
              drawer: (widget.settings.leftNavigationIcon!.value == "icon_menu" ||
                      widget.settings.rightNavigationIcon!.value == "icon_menu")
                  ? MawaqitDrawer(webViewKey: key0)
                  : null,
              body: Stack(
                fit: StackFit.expand,
                children: [
                  Column(children: [
                    Expanded(
                      child: widget.settings.tabNavigationEnable == "1"
                          ? TabBarView(
                              controller: tabController,
                              physics: NeverScrollableScrollPhysics(),
                              children: List.generate(
                                widget.settings.tab!.length,
                                (index) => MawaqitWebViewWidget(
                                  key: listKey[index],
                                  path: widget.settings.tab![index].url,
                                ),
                              ),
                            )
                          : MawaqitWebViewWidget(
                              key: listKey[0],
                              path: url,
                            ),
                    ),
                  ]),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      width: 100,
                      height: 60,
                      child: InkWell(onTap: () => _scaffoldKey.currentState?.openDrawer()),
                    ),
                  ),
                ],
              ),
              bottomNavigationBar: widget.settings.tabNavigationEnable == "1"
                  ? new Material(
                      color: Colors.white,
                      child: new Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0, 3), // changes position of shadow
                              ),
                            ],
                          ),
                          height: 60.0,
                          child: _buildTabItem(context, settings)),
                    )
                  : Container(height: 0),
              // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
              floatingActionButton: widget.settings.floating!.length != 0
                  ? SpeedDial(
                      icon: Icons.add,
                      backgroundColor: HexColor(widget.settings.firstColor),
                      foregroundColor: Colors.white,
                      children: _renderFloating(widget.settings.floating!, context),
                    )
                  : SizedBox(),
            )),
      ),
    );
  }

  Widget _buildTabItem(context, Settings settings) {
    Color tabColor = HexColor(widget.settings.colorTab);
    Color unselectedColor = Colors.black26;
    return new TabBar(
      onTap: (index) {
        for (int i = 0; i < listStream.length; i++) {
          listStream[i].add(index);
        }
      },
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(
          color: Theme.of(context).brightness == Brightness.light ? tabColor : Theme.of(context).primaryColor,
          width: 2.5,
        ),
        //insets: EdgeInsets.symmetric(horizontal:16.0)
      ),
      controller: tabController,
      labelColor: tabColor,
      unselectedLabelColor: Colors.black26,
      tabs: List.generate(
        widget.settings.tab!.length,
        (index) {
          return new Tab(
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                new Image.network(settings.tab![index].icon_url!,
                    width: 25,
                    height: 25,
                    color: _currentIndex == index
                        ? Theme.of(context).brightness == Brightness.light
                            ? tabColor
                            : Theme.of(context).primaryColor
                        : unselectedColor),
                new SizedBox(height: 5),
                new Flexible(
                  child: new Text(
                    settings.tab![index].title!,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: widget.settings.tab!.length == 5 ? 8 : 10,
                      color: _currentIndex == index
                          ? Theme.of(context).brightness == Brightness.light
                              ? tabColor
                              : Theme.of(context).primaryColor
                          : unselectedColor,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<SpeedDialChild> _renderFloating(List<Floating> floatings, context) {
    return floatings
        .map(
          (Floating floating) => SpeedDialChild(
              child: Container(
                padding: EdgeInsets.all(13.0),
                child: Image.network(floating.iconUrl!, width: 15, height: 15, color: HexColor(floating.iconColor)),
              ),
              label: floating.title,
              backgroundColor: HexColor(floating.backgroundColor),
              foregroundColor: HexColor(floating.iconColor),
              //onTap: () => print('THIRD CHILD'),
              onTap: () async {
                if (widget.settings.tabNavigationEnable == "1") {
                  if (goToWeb) {
                    setState(() {
                      goToWeb = false;
                    });

                    AppRouter.push(WebScreen(floating.url), name: floating.title);

                    setState(() => goToWeb = true);
                  }
                } else {
                  key0.currentState!.webViewController?.loadUrl(
                    urlRequest: URLRequest(
                      url: Uri.parse(floating.url!),
                    ),
                  );

                  //Navigator.pop(context);
                }
              }),
        )
        .toList();
  }

  Widget _renderAppBar(context, Settings settings) {
    return (settings.navigatinBarStyle != "empty")
        ? AppBar(
            title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  _renderMenuIcon(context, widget.settings.leftNavigationIcon!, widget.settings.rightNavigationIcon,
                      widget.settings.navigatinBarStyle, widget.settings, "left"),
                  _renderTitle(widget.settings.navigatinBarStyle, widget.settings),
                  Row(
                      children: _renderMenuIconList(
                          context,
                          widget.settings.rightNavigationIconList!,
                          widget.settings.leftNavigationIcon,
                          widget.settings.navigatinBarStyle,
                          widget.settings,
                          "right")),
                ]),
            automaticallyImplyLeading: false,
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
            ))
        : PreferredSize(
            preferredSize: Size(0.0, 0.0),
            child: Container(
              color: HexColor(settings.secondColor),
            ));
  }

  Widget _renderTitle(String? type, Settings settings) {
    var direction = MainAxisAlignment.start;

    switch (type) {
      case "left":
        direction = MainAxisAlignment.start;
        break;
      case "right":
        direction = MainAxisAlignment.end;
        break;
      case "center":
        direction = MainAxisAlignment.center;
        break;
      default:
        direction = MainAxisAlignment.center;
    }

    return Expanded(
      child: Row(
        mainAxisAlignment: direction,
        children: [
          Flexible(
            child: Container(
              child: settings.typeHeader == "text"
                  ? Text(
                      settings.title!,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.white, fontSize: 22.0, fontWeight: FontWeight.bold),
                    )
                  : settings.typeHeader == "image"
                      ? Image.network(settings.logoHeaderUrl!, height: 40)
                      : Container(),
            ),
          )
        ],
      ),
    );
  }

  Widget _renderMenuIcon(BuildContext context, NavigationIcon navigationIcon, NavigationIcon? navigationOtherIcon,
      String? navigatinBarStyle, Settings settings, String direction) {
    return navigationIcon.value != "icon_empty"
        ? Container(
            padding: direction == "right" ? new EdgeInsets.only(left: 0) : new EdgeInsets.only(right: 0),
            child: navigationIcon.value != "icon_back_forward"
                ? Row(children: <Widget>[
                    IconButton(
                      padding: const EdgeInsets.all(0.0),
                      icon: Transform(
                          alignment: Alignment.center,
                          transform:
                              Matrix4.rotationY(math.pi * (Directionality.of(context) == TextDirection.ltr ? 2 : 1)),
                          child: new Image.network(navigationIcon.iconUrl!, height: 25, width: 25, color: Colors.white)
                          /*Image.asset(
                              UIImages.imageDir +
                                  "/" +
                                  navigationIcon.value +
                                  ".png",
                              height: 25,
                              width: 25,
                              color: Colors.white)*/
                          ),
                      onPressed: () {
                        actionButtonMenu(navigationIcon, settings, context);
                      },
                    ),
                    Container(
                      width:
                          (navigatinBarStyle == "center" && navigationOtherIcon!.value == "icon_back_forward") ? 50 : 0,
                    )
                  ])
                : Row(
                    children: <Widget>[
                      IconButton(
                        color: Colors.red,
                        padding: const EdgeInsets.all(0.0),
                        icon: Transform(
                            alignment: Alignment.center,
                            transform:
                                Matrix4.rotationY(math.pi * (Directionality.of(context) == TextDirection.ltr ? 2 : 1)),
                            child: Image.asset(UIImages.imageDir + "/icon_back.png",
                                height: 25, width: 25, color: Colors.white)),
                        onPressed: () {
                          switch (_currentIndex) {
                            case 0:
                              {
                                key0.currentState!.webViewController?.goBack();
                              }
                              break;

                            case 1:
                              {
                                key1.currentState!.webViewController?.goBack();
                              }
                              break;

                            case 2:
                              {
                                key2.currentState!.webViewController?.goBack();
                              }
                              break;
                            case 3:
                              {
                                key3.currentState!.webViewController?.goBack();
                              }
                              break;
                            case 4:
                              {
                                key4.currentState!.webViewController?.goBack();
                              }
                              break;
                            default:
                              {
                                //statements;
                              }
                              break;
                          }
                        },
                      ),
                      IconButton(
                        padding: const EdgeInsets.all(0.0),
                        icon: Transform(
                            alignment: Alignment.center,
                            transform:
                                Matrix4.rotationY(math.pi * (Directionality.of(context) == TextDirection.ltr ? 2 : 1)),
                            child: Image.asset(UIImages.imageDir + "/icon_forward.png",
                                height: 25, width: 25, color: Colors.white)),
                        onPressed: () {
                          getCurrentKey().currentState!.webViewController?.goForward();
                        },
                      ),
                    ],
                  ),
          )
        : Container(
            width: navigatinBarStyle == "center" ? 50 : 0,
          );
  }

  List<Widget> _renderMenuIconList(BuildContext context, List<NavigationIcon> navigationIcon,
      NavigationIcon? navigationOtherIcon, String? navigatinBarStyle, Settings settings, String direction) {
    return navigationIcon
        .map(
          (NavigationIcon navigationIcon) =>
              _renderMenuIcon(context, navigationIcon, navigationOtherIcon, navigatinBarStyle, settings, direction),
        )
        .toList();
  }

  Future<bool> _onBackPressed() async {
    if (_scaffoldKey.currentState?.isDrawerOpen == true) {
      Navigator.pop(context);

      return false;
    }
    return getCurrentKey().currentState!.goBack();
  }

  _showDialog() {
    return showDialog(
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
            onPressed: () => exit(0),
            child: new Text(S.of(context).ok),
          ),
        ],
      ),
    );
  }

  actionButtonMenu(NavigationIcon navigationIcon, Settings settings, BuildContext context) async {
    print("navigationIcon.type");
    print(navigationIcon.type);
    if (navigationIcon.type == "url") {
      if (widget.settings.tabNavigationEnable == "1") {
        if (goToWeb) {
          setState(() {
            goToWeb = false;
          });
          AppRouter.push(
            WebScreen(navigationIcon.url),
            name: navigationIcon.title,
          );

          setState(() {
            goToWeb = false;
          });
        }
      } else {
        key0.currentState!.webViewController?.loadUrl(urlRequest: URLRequest(url: Uri.parse(navigationIcon.url!)));
      }
    } else {
      switch (navigationIcon.value) {
        case "icon_menu":
          _HomeScreen._scaffoldKey.currentState!.openDrawer();
          break;
        case "icon_home":
          if (widget.settings.tabNavigationEnable == "1") {
            if (goToWeb) {
              setState(() {
                goToWeb = false;
              });
              AppRouter.push(WebScreen(settings.url));

              setState(() {
                goToWeb = true;
              });
            }
          } else {
            key0.currentState!.webViewController?.loadUrl(urlRequest: URLRequest(url: Uri.parse(settings.url!)));
          }
          break;
        case "icon_reload":
          getCurrentKey().currentState!.webViewController?.reload();
          break;
        case "icon_share":
          shareApp(context, settings.title, settings.share!);
          break;
        case "icon_back":
          getCurrentKey().currentState!.webViewController?.goBack();
          break;
        case "icon_forward":
          getCurrentKey().currentState!.webViewController?.goForward();
          break;
        case "icon_exit":
          _showDialog();
          break;

        default:
          break;
      }
    }
  }

  shareApp(BuildContext context, String? text, String share) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    Share.share(share, subject: text, sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
  }

  GlobalKey<MawaqitWebViewWidgetState> getCurrentKey() {
    switch (_currentIndex) {
      case 0:
        return key0;
      case 1:
        return key1;
      case 2:
        return key2;
      case 3:
        return key3;
      case 4:
        return key4;
      default:
        return key0;
    }
  }
}
