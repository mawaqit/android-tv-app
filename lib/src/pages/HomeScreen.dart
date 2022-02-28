import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:android_intent/android_intent.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flyweb/i18n/AppLanguage.dart';
import 'package:flyweb/i18n/i18n.dart';
import 'package:flyweb/src/elements/DrawerListTitle.dart';
import 'package:flyweb/src/elements/Loader.dart';
import 'package:flyweb/src/elements/RaisedGradientButton.dart';
import 'package:flyweb/src/enum/connectivity_status.dart';
import 'package:flyweb/src/helpers/AppRouter.dart';
import 'package:flyweb/src/helpers/HexColor.dart';
import 'package:flyweb/src/helpers/OneSignalHelper.dart';
import 'package:flyweb/src/helpers/SharedPref.dart';
import 'package:flyweb/src/models/floating.dart';
import 'package:flyweb/src/models/menu.dart';
import 'package:flyweb/src/models/navigationIcon.dart';
import 'package:flyweb/src/models/page.dart';
import 'package:flyweb/src/models/settings.dart';
import 'package:flyweb/src/pages/LanguageScreen.dart';
import 'package:flyweb/src/pages/MosqueSearchScreen.dart';
import 'package:flyweb/src/pages/PageScreen.dart';
import 'package:flyweb/src/pages/WebScreen.dart';
import 'package:flyweb/src/position/PositionOptions.dart';
import 'package:flyweb/src/position/PositionResponse.dart';
import 'package:flyweb/src/services/mosque_manager.dart';
import 'package:flyweb/src/services/settings_manager.dart';
import 'package:flyweb/src/services/theme_manager.dart';
import 'package:flyweb/src/themes/UIImages.dart';
import 'package:flyweb/src/widgets/InfoWidget.dart';
import 'package:geolocator/geolocator.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:launch_review/launch_review.dart';
import 'package:location/location.dart' hide LocationAccuracy;
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:store_redirect/store_redirect.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';

import 'AboutScreen.dart';

GlobalKey<_WebViewScreen> key0 = GlobalKey();
GlobalKey<_WebViewScreen> key1 = GlobalKey();
GlobalKey<_WebViewScreen> key2 = GlobalKey();
GlobalKey<_WebViewScreen> key3 = GlobalKey();
GlobalKey<_WebViewScreen> key4 = GlobalKey();
GlobalKey<_WebViewScreen> keyMain = GlobalKey();
GlobalKey<_WebViewScreen> keyWebView = GlobalKey();
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

class _HomeScreen extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  SharedPref sharedPref = SharedPref();

  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;
  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdReady = false;

  static GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String url = "";

  Uri? _initialUri;
  Uri? _latestUri;
  StreamSubscription? _sub;
  bool goToWeb = true;

  List<StreamSubscription<Position>> webViewGPSPositionStreams = [];

  final Set<Factory<OneSequenceGestureRecognizer>> _gSet = [
    Factory<VerticalDragGestureRecognizer>(
        () => VerticalDragGestureRecognizer()),
    Factory<ScaleGestureRecognizer>(() => ScaleGestureRecognizer()),
    Factory<PanGestureRecognizer>(() => PanGestureRecognizer()),
  ].toSet();

  // PackageInfo _packageInfo = PackageInfo(
  //   appName: 'Unknown',
  //   packageName: 'Unknown',
  //   version: 'Unknown',
  //   buildNumber: 'Unknown',
  // );

  TabController? tabController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // _initPackageInfo();

    _handleIncomingLinks();

    tabController = new TabController(
      initialIndex: 0,
      length: widget.settings.tabNavigationEnable == "1"
          ? widget.settings.tab!.length
          : 1,
      vsync: this,
    );
    tabController!.addListener(_handleTabSelection);

    if (widget.settings.adBanner == "1") {
      String adBannerId = Platform.isAndroid
          ? widget.settings.admobKeyAdBanner!
          : widget.settings.admobKeyAdBannerIos!;
      // TODO: Initialize _bannerAd
      _bannerAd = BannerAd(
        adUnitId: adBannerId,
        request: AdRequest(),
        size: AdSize.banner,
        listener: BannerAdListener(
          onAdLoaded: (_) {
            setState(() {
              _isBannerAdReady = true;
            });
          },
          onAdFailedToLoad: (ad, err) {
            print('Failed to load a banner ad: ${err.message}');
            _isBannerAdReady = false;
            ad.dispose();
          },
        ),
      );

      _bannerAd!.load();
    }

    if (widget.settings.adInterstitial == "1") {
      String? adInterstitialId = Platform.isAndroid
          ? widget.settings.admobKeyAdInterstitial
          : widget.settings.admobKeyAdInterstitialIos;

      Timer.periodic(
          new Duration(seconds: int.parse(widget.settings.admobDealy!)),
          (timer) {
        InterstitialAd.load(
          adUnitId: adInterstitialId!,
          request: AdRequest(),
          adLoadCallback: InterstitialAdLoadCallback(
            onAdLoaded: (ad) {
              _isInterstitialAdReady = true;
              _interstitialAd = ad;
              ad.show();
            },
            onAdFailedToLoad: (err) {
              print('Failed to load an interstitial ad: ${err.message}');
              _isInterstitialAdReady = false;
              // ad.dispose();
            },
          ),
        );
        // _interstitialAd?.load();
        // _interstitialAd?.show();
      });
    }
  }

  void _handleIncomingLinks() {
    if (!kIsWeb) {
      _sub = uriLinkStream.listen((Uri? uri) async {
        if (!mounted) return;
        print('got uri: $uri');
        setState(() {
          _latestUri = uri;
        });
        var link = uri.toString().replaceAll(
            '${GlobalConfiguration().getValue('deeplink')}://url/', '');

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
          key0.currentState!._webViewController?.loadUrl(
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
    _bannerAd?.dispose();
    _interstitialAd?.dispose();

    webViewGPSPositionStreams.forEach(
        (StreamSubscription<Position> _flutterGeolocationStream) =>
            _flutterGeolocationStream.cancel());

    super.dispose();
  }

  // Future<void> _initPackageInfo() async {
  //   final PackageInfo info = await PackageInfo.fromPlatform();
  //   setState(() {
  //     _packageInfo = info;
  //   });
  // }

  Future<InitializationStatus> _initGoogleMobileAds() {
    // TODO: Initialize Google Mobile Ads SDK
    return MobileAds.instance.initialize();
  }

  @override
  Widget build(BuildContext context) {
    final appLanguage = context.watch<AppLanguage>();
    final mosqueManager = context.watch<MosqueManager>();
    final settingsManager = context.read<SettingsManager>();
    final settings = settingsManager.settings;

    var url =
        'https://mawaqit.net/${appLanguage.appLocal.languageCode}/id/${mosqueManager.mosqueId}?view=desktop';

    print(url);
    var bottomPadding = MediaQuery.of(context).padding.bottom;
    var connectionStatus = Provider.of<ConnectivityStatus>(context);

    var themeProvider = Provider.of<ThemeNotifier>(context);

    if (connectionStatus == ConnectivityStatus.Offline)
      return _offline(bottomPadding, settings);

    final _oneSignalHelper = OneSignalHelper();
    Future<void> _listenerOneSignal() async {
      print(_oneSignalHelper.url);
      if (settings.tabNavigationEnable == "1") {
        if (goToWeb) {
          setState(() {
            goToWeb = false;
          });

          AppRouter.push(WebScreen(_oneSignalHelper.url));

          setState(() {
            goToWeb = true;
          });
        }
      } else {
        key0.currentState!._webViewController?.loadUrl(
          urlRequest: URLRequest(
            url: Uri.parse(
              _oneSignalHelper.url!,
            ),
          ),
        );
      }
    }

    _oneSignalHelper.addListener(_listenerOneSignal);

    // final List<Widget> _children = [];

    return WillPopScope(
      onWillPop: () async {
        if (_scaffoldKey.currentState?.isDrawerOpen == true) {
          Navigator.pop(context);

          return false;
        }
        return getCurrentKey().currentState!.goBack();
      },
      child: CallbackShortcuts(
        bindings: {
          SingleActivator(LogicalKeyboardKey.arrowLeft): () =>
              _scaffoldKey.currentState?.openDrawer(),
          SingleActivator(LogicalKeyboardKey.arrowRight): () =>
              _scaffoldKey.currentState?.openDrawer(),
        },
        child: Container(
            decoration: BoxDecoration(color: HexColor("#f5f4f4")),
            padding: EdgeInsets.only(bottom: bottomPadding),
            child: Scaffold(
              key: _scaffoldKey,
              appBar: _renderAppBar(context, settings) as PreferredSizeWidget?,
              drawer: (widget.settings.leftNavigationIcon!.value ==
                          "icon_menu" ||
                      widget.settings.rightNavigationIcon!.value == "icon_menu")
                  ? Drawer(
                      child: ListView(
                        padding: const EdgeInsets.all(0.0),
                        children: <Widget>[
                          DrawerHeader(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: <Color>[
                                    themeProvider.isLightTheme!
                                        ? HexColor(settings.firstColor)
                                        : themeProvider.darkTheme.primaryColor,
                                    themeProvider.isLightTheme!
                                        ? HexColor(settings.secondColor)
                                        : themeProvider.darkTheme.primaryColor,
                                  ],
                                ),
                              ),
                              child: Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      width: 70.0,
                                      height: 70.0,
                                      child: Image.network(
                                        settings.logoHeaderUrl!,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top: 5),
                                    child: Text(settings.title!,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 16)),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top: 5),
                                    child: Text(settings.subTitle!,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 14)),
                                  )
                                ],
                              ),
                            )),
                        DrawerListTitle(
                            icon: Icons.home,
                            text: I18n.current!.home,
                            onTap: () async {
                              if (widget.settings.tabNavigationEnable == "1") {
                                if (goToWeb) {
                                  setState(() => goToWeb = false);
                                  AppRouter.popAndPush(
                                      WebScreen(widget.settings.url),
                                      name: 'HomeScreen');

                                  Navigator.pop(context);
                                }
                              } else {
                                key0.currentState!._webViewController?.loadUrl(
                                  urlRequest: URLRequest(
                                    url: Uri.parse(url),
                                  ),
                                );

                                Navigator.pop(context);
                              }
                            }),
                        _renderMenuDrawer(settings.menus!, context),
                        Padding(
                          padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                          child: Divider(height: 1, color: Colors.grey[400]),
                        ),
                        _renderPageDrawer(settings.pages!, context),
                        settings.pages!.length != 0
                            ? Padding(
                                padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                                child:
                                    Divider(height: 1, color: Colors.grey[400]),
                              )
                            : Container(height: 0),
                        DrawerListTitle(
                            icon: Icons.brightness_medium,
                            text: themeProvider.isLightTheme!
                                ? I18n.current!.darkMode
                                : I18n.current!.lightMode,
                            onTap: () {
                              if (themeProvider.isLightTheme!) {
                                themeProvider.setDarkMode();
                              } else {
                                themeProvider.setLightMode();
                              }
                            }),
                        DrawerListTitle(
                          icon: Icons.translate,
                          text: I18n.current!.languages,
                          onTap: () => AppRouter.popAndPush(LanguageScreen()),
                        ),
                        DrawerListTitle(
                          icon: Icons.museum_outlined,
                          text: 'Change Mosque',
                          onTap: () =>
                              AppRouter.popAndPush(MosqueSearchScreen()),
                        ),
                        DrawerListTitle(
                          icon: Icons.info,
                          text: I18n.current!.about,
                          onTap: () => AppRouter.popAndPush(AboutScreen()),
                        ),
                        DrawerListTitle(
                            icon: Icons.share,
                            text: I18n.current!.share,
                            onTap: () {
                              shareApp(
                                  context, settings.title, settings.share!);
                            }),
                        DrawerListTitle(
                          icon: Icons.star,
                          text: I18n.current!.rate,
                          onTap: () => LaunchReview.launch(
                            androidAppId: settings.androidId,
                            iOSAppId: settings.iosId,
                          ),
                          _renderPageDrawer(settings.pages!, context),
                          settings.pages!.length != 0
                              ? Padding(
                                  padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                                  child: Divider(
                                      height: 1, color: Colors.grey[400]),
                                )
                              : Container(height: 0),
                          DrawerListTitle(
                              icon: Icons.brightness_medium,
                              text: themeProvider.isLightTheme!
                                  ? I18n.current!.darkMode
                                  : I18n.current!.lightMode,
                              onTap: () {
                                if (themeProvider.isLightTheme!) {
                                  themeProvider.setDarkMode();
                                } else {
                                  themeProvider.setLightMode();
                                }
                              }),
                          DrawerListTitle(
                            icon: Icons.translate,
                            text: I18n.current!.languages,
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                PageTransition(
                                  type: pageTransitionAnimation(context),
                                  child: LanguageScreen(),
                                ),
                              );
                            },
                          ),
                          DrawerListTitle(
                            icon: Icons.museum_outlined,
                            text: 'Change Mosque',
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                PageTransition(
                                  type: pageTransitionAnimation(context),
                                  child: MosqueSearchScreen(),
                                ),
                              );
                            },
                          ),
                          DrawerListTitle(
                            icon: Icons.info,
                            text: I18n.current!.about,
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                PageTransition(
                                  type: pageTransitionAnimation(context),
                                  child: AboutScreen(),
                                ),
                              );
                            },
                          ),
                          DrawerListTitle(
                              icon: Icons.share,
                              text: I18n.current!.share,
                              onTap: () {
                                shareApp(
                                    context, settings.title, settings.share!);
                              }),
                          DrawerListTitle(
                            icon: Icons.star,
                            text: I18n.current!.rate,
                            onTap: () => LaunchReview.launch(
                              androidAppId: settings.androidId,
                              iOSAppId: settings.iosId,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                            child: Divider(
                              height: 1,
                              color: Colors.grey[400],
                            ),
                          ),
                          ListTile(
                            leading: Icon(Icons.system_update),
                            isThreeLine: true,
                            dense: true,
                            title: Text(I18n.current!.update),
                            subtitle: VersionWidget(),
                          ),
                        ],
                      ),
                    )
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
                                (index) => WebViewScreen(
                                    key: listKey[index],
                                    path: widget.settings.tab![index].url,
                                    pos: index,
                                    settings: widget.settings,
                                    stream: listStream[index].stream),
                              ),
                            )
                          : WebViewScreen(
                              key: listKey[0],
                              path: url,
                              pos: 0,
                              settings: widget.settings,
                              stream: listStream[0].stream,
                            ),
                    ),
                    if (widget.settings.adBanner == "1" && _isBannerAdReady)
                      Container(
                        height: 50,
                        child: AdWidget(ad: _bannerAd!),
                      )
                  ]),
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
                                offset:
                                    Offset(0, 3), // changes position of shadow
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
                      children:
                          _renderFloating(widget.settings.floating!, context),
                    )
                  : Padding(
                      padding: const EdgeInsets.only(bottom: 40),
                      child: FloatingActionButton(
                        onPressed: () =>
                            _scaffoldKey.currentState?.openDrawer(),
                        child: Icon(Icons.menu),
                      ),
                    ),
              /*bottomNavigationBar: Container(
                  height: settings.adBanner == "1"
                      ? Platform.isAndroid
                          ? 50
                          : 80
                      : 0),
                      */
            )),
      ),
    );
  }

  Widget _buildTabItem(context, Settings settings) {
    var themeProvider = Provider.of<ThemeNotifier>(context);
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
          color: themeProvider.isLightTheme!
              ? tabColor
              : themeProvider.darkTheme.primaryColor,
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
                        ? themeProvider.isLightTheme!
                            ? tabColor
                            : themeProvider.darkTheme.primaryColor
                        : unselectedColor),
                new SizedBox(height: 5),
                new Flexible(
                  child: new Text(
                    settings.tab![index].title!,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: widget.settings.tab!.length == 5 ? 8 : 10,
                      color: _currentIndex == index
                          ? themeProvider.isLightTheme!
                              ? tabColor
                              : themeProvider.darkTheme.primaryColor
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
                Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
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
                        I18n.current!.whoops,
                        style: TextStyle(
                            color: Colors.black45,
                            fontSize: 40.0,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 20),
                      Text(
                        I18n.current!.noInternet,
                        style: TextStyle(color: Colors.black87, fontSize: 15.0),
                      ),
                      SizedBox(height: 5),
                      SizedBox(height: 60),
                      RaisedGradientButton(
                          child: Text(
                            I18n.current!.tryAgain,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold),
                          ),
                          width: 250,
                          gradient: LinearGradient(
                            colors: <Color>[
                              HexColor(settings.secondColor),
                              HexColor(settings.firstColor)
                            ],
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

  /*
  InterstitialAd createInterstitialAd() {
    return InterstitialAd(
      adUnitId: Platform.isAndroid
          ? settings.admobKeyAdInterstitial
          : settings.admobKeyAdInterstitialIos, //InterstitialAd.testAdUnitId
      listener: (MobileAdEvent event) {},
    );
  }
   */

  int? parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;

    return int.tryParse(value) ?? null;
  }

  Future<PositionResponse> getCurrentPosition(
      PositionOptions positionOptions) async {
    PositionResponse positionResponse = PositionResponse();

    int? timeout = 30000;
    if (positionOptions.timeout! > 0) timeout = positionOptions.timeout;

    try {
      // Geolocator geolocator = Geolocator()..forceAndroidLocationManager = true;
      LocationPermission geolocationStatus =
          await GeolocatorPlatform.instance.requestPermission();

      if (geolocationStatus == LocationPermission.always ||
          geolocationStatus == LocationPermission.whileInUse) {
        positionResponse.position = await Future.any([
          GeolocatorPlatform.instance.getCurrentPosition(
            locationSettings: LocationSettings(
                accuracy: (positionOptions.enableHighAccuracy
                    ? LocationAccuracy.best
                    : LocationAccuracy.medium)),
          ),
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

  pageTransitionAnimation(BuildContext context) {
    return Directionality.of(context) == TextDirection.ltr
        ? PageTransitionType.leftToRight
        : PageTransitionType.rightToLeft;
  }

  Widget _renderMenuDrawer(List<Menu> menus, BuildContext context) {
    return new Column(
      children: menus
          .map(
            (Menu menu) => DrawerListTitle(
                iconUrl: menu.iconUrl,
                text: menu.title,
                onTap: () async {
                  if (widget.settings.tabNavigationEnable == "1") {
                    if (goToWeb) {
                      setState(() {
                        goToWeb = false;
                      });
                      AppRouter.push(WebScreen(menu.url), name: menu.title);

                      setState(() {
                        goToWeb = true;
                      });
                    }
                  } else {
                    key0.currentState!._webViewController?.loadUrl(
                        urlRequest: URLRequest(url: Uri.parse(menu.url!)));

                    Navigator.pop(context);
                  }
                }),
          )
          .toList(),
    );
  }

  List<SpeedDialChild> _renderFloating(List<Floating> floatings, context) {
    return floatings
        .map(
          (Floating floating) => SpeedDialChild(
              child: Container(
                padding: EdgeInsets.all(13.0),
                child: Image.network(floating.iconUrl!,
                    width: 15, height: 15, color: HexColor(floating.iconColor)),
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

                    AppRouter.push(WebScreen(floating.url),
                        name: floating.title);

                    setState(() => goToWeb = true);
                  }
                } else {
                  key0.currentState!._webViewController?.loadUrl(
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

  Widget _renderPageDrawer(List<Page> pages, context) {
    print(pages.map((e) => e.icon));
    return new Column(
      children: pages
          .map(
            (Page page) => DrawerListTitle(
              forceThemeColor: true,
              iconUrl: page.iconUrl,
              text: page.title,
              onTap: () =>
                  AppRouter.popAndPush(PageScreen(page), name: page.title),
            ),
          )
          .toList(),
    );
  }

  Widget _renderAppBar(context, Settings settings) {
    var themeProvider = Provider.of<ThemeNotifier>(context);
    return (settings.navigatinBarStyle != "empty")
        ? AppBar(
            title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  _renderMenuIcon(
                      context,
                      widget.settings.leftNavigationIcon!,
                      widget.settings.rightNavigationIcon,
                      widget.settings.navigatinBarStyle,
                      widget.settings,
                      "left"),
                  _renderTitle(
                      widget.settings.navigatinBarStyle, widget.settings),
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
                    themeProvider.isLightTheme!
                        ? HexColor(settings.firstColor)
                        : themeProvider.darkTheme.primaryColor,
                    themeProvider.isLightTheme!
                        ? HexColor(settings.secondColor)
                        : themeProvider.darkTheme.primaryColor,
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
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22.0,
                          fontWeight: FontWeight.bold),
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

  Widget _renderMenuIcon(
      BuildContext context,
      NavigationIcon navigationIcon,
      NavigationIcon? navigationOtherIcon,
      String? navigatinBarStyle,
      Settings settings,
      String direction) {
    return navigationIcon.value != "icon_empty"
        ? Container(
            padding: direction == "right"
                ? new EdgeInsets.only(left: 0)
                : new EdgeInsets.only(right: 0),
            child: navigationIcon.value != "icon_back_forward"
                ? Row(children: <Widget>[
                    IconButton(
                      padding: const EdgeInsets.all(0.0),
                      icon: Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.rotationY(math.pi *
                              (I18n.current!.textDirection == TextDirection.ltr
                                  ? 2
                                  : 1)),
                          child: new Image.network(navigationIcon.iconUrl!,
                              height: 25, width: 25, color: Colors.white)
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
                      width: (navigatinBarStyle == "center" &&
                              navigationOtherIcon!.value == "icon_back_forward")
                          ? 50
                          : 0,
                    )
                  ])
                : Row(
                    children: <Widget>[
                      IconButton(
                        color: Colors.red,
                        padding: const EdgeInsets.all(0.0),
                        icon: Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.rotationY(math.pi *
                                (I18n.current!.textDirection ==
                                        TextDirection.ltr
                                    ? 2
                                    : 1)),
                            child: Image.asset(
                                UIImages.imageDir + "/icon_back.png",
                                height: 25,
                                width: 25,
                                color: Colors.white)),
                        onPressed: () {
                          switch (_currentIndex) {
                            case 0:
                              {
                                key0.currentState!._webViewController?.goBack();
                              }
                              break;

                            case 1:
                              {
                                key1.currentState!._webViewController?.goBack();
                              }
                              break;

                            case 2:
                              {
                                key2.currentState!._webViewController?.goBack();
                              }
                              break;
                            case 3:
                              {
                                key3.currentState!._webViewController?.goBack();
                              }
                              break;
                            case 4:
                              {
                                key4.currentState!._webViewController?.goBack();
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
                            transform: Matrix4.rotationY(math.pi *
                                (I18n.current!.textDirection ==
                                        TextDirection.ltr
                                    ? 2
                                    : 1)),
                            child: Image.asset(
                                UIImages.imageDir + "/icon_forward.png",
                                height: 25,
                                width: 25,
                                color: Colors.white)),
                        onPressed: () {
                          getCurrentKey()
                              .currentState!
                              ._webViewController
                              ?.goForward();
                        },
                      ),
                    ],
                  ),
          )
        : Container(
            width: navigatinBarStyle == "center" ? 50 : 0,
          );
  }

  List<Widget> _renderMenuIconList(
      BuildContext context,
      List<NavigationIcon> navigationIcon,
      NavigationIcon? navigationOtherIcon,
      String? navigatinBarStyle,
      Settings settings,
      String direction) {
    return navigationIcon
        .map(
          (NavigationIcon navigationIcon) => _renderMenuIcon(
              context,
              navigationIcon,
              navigationOtherIcon,
              navigatinBarStyle,
              settings,
              direction),
        )
        .toList();
    ;
  }

  Future<bool> _onBackPressed(context) async {
    try {
      if (getCurrentKey().currentState!._webViewController != null) {
        if (await getCurrentKey()
            .currentState!
            ._webViewController!
            .canGoBack()) {
          getCurrentKey().currentState!._webViewController!.goBack();
          return false;
        } else {
          _showDialog(context);
        }
      }
    } catch (e) {
      _showDialog(context);
    }

    return true;
  }

  _showDialog(context) {
    return showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text(I18n.current!.closeApp),
        content: new Text(I18n.current!.sureCloseApp),
        actions: <Widget>[
          new FlatButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: new Text(I18n.current!.cancel),
          ),
          SizedBox(height: 16),
          new FlatButton(
            onPressed: () => exit(0),
            child: new Text(I18n.current!.ok),
          ),
        ],
      ),
    );
  }

  actionButtonMenu(NavigationIcon navigationIcon, Settings settings,
      BuildContext context) async {
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
        key0.currentState!._webViewController?.loadUrl(
            urlRequest: URLRequest(url: Uri.parse(navigationIcon.url!)));
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
            key0.currentState!._webViewController?.loadUrl(
                urlRequest: URLRequest(url: Uri.parse(settings.url!)));
          }
          break;
        case "icon_reload":
          getCurrentKey().currentState!._webViewController?.reload();
          break;
        case "icon_share":
          shareApp(context, settings.title, settings.share!);
          break;
        case "icon_back":
          getCurrentKey().currentState!._webViewController?.goBack();
          break;
        case "icon_forward":
          getCurrentKey().currentState!._webViewController?.goForward();
          break;
        case "icon_exit":
          _showDialog(context);
          break;

        default:
          () {};
          break;
      }
    }
  }

  shareApp(BuildContext context, String? text, String share) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    Share.share(share,
        subject: text,
        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
  }

  GlobalKey<_WebViewScreen> getCurrentKey() {
    switch (_currentIndex) {
      case 0:
        {
          return key0;
        }
        break;

      case 1:
        {
          return key1;
        }
        break;

      case 2:
        {
          return key2;
        }
        break;
      case 3:
        {
          return key3;
        }
        break;
      case 4:
        {
          return key4;
        }
        break;
      default:
        {
          return key0;
        }
        break;
    }
  }
}

class WebViewScreen extends StatefulWidget {
  final GlobalKey? webKey;
  final String? path;
  final int? pos;
  final Settings? settings;
  final InAppWebViewController? webViewController;
  final Stream<int>? stream;

  WebViewScreen({
    Key? key,
    this.path,
    this.webKey,
    this.pos,
    this.settings,
    this.webViewController,
    this.stream,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new _WebViewScreen();
  }
}

class _WebViewScreen extends State<WebViewScreen>
    with AutomaticKeepAliveClientMixin<WebViewScreen>, WidgetsBindingObserver {
  @override
  bool get wantKeepAlive => true;

  InAppWebViewController? _webViewController;
  String url = "";
  PullToRefreshController? pullToRefreshController;
  static GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  List<StreamSubscription<Position>> webViewGPSPositionStreams = [];
  late bool isLoading;

  final Set<Factory<OneSequenceGestureRecognizer>> _gSet = [
    Factory<VerticalDragGestureRecognizer>(
        () => VerticalDragGestureRecognizer()),
    Factory<ScaleGestureRecognizer>(() => ScaleGestureRecognizer()),
    Factory<PanGestureRecognizer>(() => PanGestureRecognizer()),
  ].toSet();

  @override
  void initState() {
    WidgetsBinding.instance!.addObserver(this);
    super.initState();
    isLoading = true;

    pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(
        color: Colors.blue,
      ),
      onRefresh: () async {
        if (Platform.isAndroid) {
          _webViewController?.reload();
        } else if (Platform.isIOS) {
          _webViewController?.loadUrl(
              urlRequest: URLRequest(url: await _webViewController?.getUrl()));
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
  void didUpdateWidget(covariant WebViewScreen oldWidget) {
    if (oldWidget.path != widget.path) {
      _webViewController!.loadUrl(
        urlRequest: URLRequest(
          url: Uri.parse(widget.path!),
        ),
      );
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    /*if (_webViewController != null) {
      if (state == AppLifecycleState.paused) {
        if (Platform.isAndroid) {
          _webViewController.pauseTimers(); // Pause timers only for android
          _webViewController.android.pause();
        }
      } else {
        if (Platform.isAndroid) {
          _webViewController.resumeTimers(); // Resume timers only for android
          _webViewController.android.resume();
        }
      }
    }*/
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    webViewGPSPositionStreams.forEach(
        (StreamSubscription<Position> _flutterGeolocationStream) =>
            _flutterGeolocationStream.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeNotifier>(context);

    return Stack(
      fit: StackFit.expand,
      children: [
        InAppWebView(
          // contextMenu: contextMenu,
          initialUrlRequest: URLRequest(url: Uri.parse(widget.path!)),
          gestureRecognizers: _gSet,
          initialOptions: InAppWebViewGroupOptions(
              crossPlatform: InAppWebViewOptions(
                supportZoom: false,
                useShouldOverrideUrlLoading: true,
                useOnDownloadStart: true,
                mediaPlaybackRequiresUserGesture: false,
                userAgent: Platform.isAndroid
                    ? widget.settings!.userAgent!.valueAndroid!
                    : widget.settings!.userAgent!.valueIOS!,
              ),
              android: AndroidInAppWebViewOptions(
                useHybridComposition: true,
              ),
              ios: IOSInAppWebViewOptions(
                allowsInlineMediaPlayback: true,
              )),
          pullToRefreshController: widget.settings!.pullRefresh == "1"
              ? pullToRefreshController
              : null,
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
                      _geolocationClearWatch(parseInt(
                          geolocationData['flutterGeolocationIndex'] ?? 0)!);
                      break;

                    case "getCurrentPosition":
                      _geolocationGetCurrentPosition(
                          parseInt(
                              geolocationData['flutterGeolocationIndex'] ?? 0),
                          PositionOptions()
                              .from(geolocationData['option'] ?? null));
                      break;

                    case "watchPosition":
                      _geolocationWatchPosition(
                          parseInt(
                              geolocationData['flutterGeolocationIndex'] ?? 0)!,
                          PositionOptions()
                              .from(geolocationData['option'] ?? null));
                      break;
                    default:
                  }
                });
            _webViewController = controller;
          },
          androidOnPermissionRequest: (InAppWebViewController controller,
              String origin, List<String> resources) async {
            return PermissionRequestResponse(
                resources: resources,
                action: PermissionRequestResponseAction.GRANT);
          },
          shouldOverrideUrlLoading: (controller, navigationAction) async {
            var uri = navigationAction.request.url!;
            print("uri.scheme");
            print(uri.scheme);
            if (Platform.isAndroid && ["intent"].contains(uri.scheme)) {
              if (uri.toString().indexOf("maps") != -1) {
                var link = uri
                    .toString()
                    .substring(uri.toString().indexOf('?link=') + 6);
                print(link);
                AndroidIntent intent =
                    AndroidIntent(action: 'action_view', data: link);
                await intent.launch();
              } else {
                String id = uri.toString().substring(
                    uri.toString().indexOf('id%3D') + 5,
                    uri.toString().indexOf('#Intent'));
                await StoreRedirect.redirect(androidAppId: id);
              }
              return NavigationActionPolicy.CANCEL;
            } else if (![
              "http",
              "https",
              "chrome",
              "data",
              "javascript",
              "file",
              "about"
            ].contains(uri.scheme)) {
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
        ),
        (isLoading && widget.settings!.loader != "empty")
            ? Positioned(
                top: 0,
                bottom: 0,
                right: 0,
                left: 0,
                child: Loader(
                    type: widget.settings!.loader,
                    color: themeProvider.isLightTheme!
                        ? HexColor(widget.settings!.loaderColor)
                        : themeProvider.darkTheme.primaryColor))
            : Container()
      ],
    );
  }

  int? parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;

    return int.tryParse(value) ?? null;
  }

  Future<PositionResponse> getCurrentPosition(
      PositionOptions positionOptions) async {
    PositionResponse positionResponse = PositionResponse();

    int? timeout = 30000;
    if (positionOptions.timeout! > 0) timeout = positionOptions.timeout;

    try {
      LocationPermission geolocationStatus =
          await GeolocatorPlatform.instance.requestPermission();

      if (geolocationStatus == LocationPermission.always ||
          geolocationStatus == LocationPermission.whileInUse) {
        positionResponse.position = await Future.any([
          Geolocator.getCurrentPosition(
              desiredAccuracy: (positionOptions.enableHighAccuracy
                  ? LocationAccuracy.best
                  : LocationAccuracy.medium)),
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

  void _geolocationGetCurrentPosition(
      int? flutterGeolocationIndex, PositionOptions positionOptions) async {
    PositionResponse positionResponse =
        await getCurrentPosition(positionOptions);

    _geolocationResponse(
        flutterGeolocationIndex, positionOptions, positionResponse, false);
  }

  void _geolocationResponse(
      int? flutterGeolocationIndex,
      PositionOptions positionOptions,
      PositionResponse positionResponse,
      bool watcher) {
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
          positionResponse.position!.timestamp!.millisecondsSinceEpoch
              .toString() +
          '''
          });''' +
          (!watcher
              ? "  _flutterGeolocationSuccess[" +
                  flutterGeolocationIndex.toString() +
                  "] = null; "
              : "") +
          (!watcher
              ? "  _flutterGeolocationError[" +
                  flutterGeolocationIndex.toString() +
                  "] = null; "
              : "") +
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
          (!watcher
              ? "  _flutterGeolocationSuccess[" +
                  flutterGeolocationIndex.toString() +
                  "] = null; "
              : "") +
          (!watcher
              ? "  _flutterGeolocationError[" +
                  flutterGeolocationIndex.toString() +
                  "] = null; "
              : "") +
          '''
          return true;
        };
        _flutterGeolocationResponse();
      ''';

      _webViewController!.evaluateJavascript(source: javascript);
    }
  }

  void _geolocationWatchPosition(
    int flutterGeolocationIndex,
    PositionOptions positionOptions,
  ) {
    // init new strem
    var locationOptions = LocationSettings(
        accuracy: (positionOptions.enableHighAccuracy
            ? LocationAccuracy.best
            : LocationAccuracy.medium),
        distanceFilter: 10);

    webViewGPSPositionStreams[flutterGeolocationIndex] =
        Geolocator.getPositionStream(locationSettings: locationOptions)
            .listen((Position position) {
      // Send data to each warcher
      PositionResponse positionResponse = PositionResponse()
        ..position = position;
      _geolocationResponse(
          flutterGeolocationIndex, positionOptions, positionResponse, true);
    });
  }

  Future<bool> goBack() async {
    if (_webViewController != null) {
      if (await _webViewController!.canGoBack()) {
        _webViewController!.goBack();
        return false;
      } else {
        return showDialog(
              context: context,
              builder: (context) => new AlertDialog(
                title: new Text('Close APP'),
                content:
                    new Text('Are you sure want to quit this application ?'),
                actions: <Widget>[
                  new FlatButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: new Text("CANCEL"),
                  ),
                  SizedBox(height: 16),
                  new FlatButton(
                    onPressed: () => exit(0),
                    child: new Text("OK"),
                  ),
                ],
              ),
            ) as FutureOr<bool>? ??
            false;
      }
    }
    return true;
  }
}
