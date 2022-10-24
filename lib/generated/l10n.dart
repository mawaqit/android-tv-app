// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Home`
  String get home {
    return Intl.message(
      'Home',
      name: 'home',
      desc: '',
      args: [],
    );
  }

  /// `Share`
  String get share {
    return Intl.message(
      'Share',
      name: 'share',
      desc: '',
      args: [],
    );
  }

  /// `About`
  String get about {
    return Intl.message(
      'About',
      name: 'about',
      desc: '',
      args: [],
    );
  }

  /// `Rate Us`
  String get rate {
    return Intl.message(
      'Rate Us',
      name: 'rate',
      desc: '',
      args: [],
    );
  }

  /// `Update Application`
  String get update {
    return Intl.message(
      'Update Application',
      name: 'update',
      desc: '',
      args: [],
    );
  }

  /// `Notifications`
  String get notification {
    return Intl.message(
      'Notifications',
      name: 'notification',
      desc: '',
      args: [],
    );
  }

  /// `Languages`
  String get languages {
    return Intl.message(
      'Languages',
      name: 'languages',
      desc: '',
      args: [],
    );
  }

  /// `App Language`
  String get appLang {
    return Intl.message(
      'App Language',
      name: 'appLang',
      desc: '',
      args: [],
    );
  }

  /// `Please select your preferred language`
  String get descLang {
    return Intl.message(
      'Please select your preferred language',
      name: 'descLang',
      desc: '',
      args: [],
    );
  }

  /// `Whoops!`
  String get whoops {
    return Intl.message(
      'Whoops!',
      name: 'whoops',
      desc: '',
      args: [],
    );
  }

  /// `No internet connection`
  String get noInternet {
    return Intl.message(
      'No internet connection',
      name: 'noInternet',
      desc: '',
      args: [],
    );
  }

  /// `Try Again`
  String get tryAgain {
    return Intl.message(
      'Try Again',
      name: 'tryAgain',
      desc: '',
      args: [],
    );
  }

  /// `Close app`
  String get closeApp {
    return Intl.message(
      'Close app',
      name: 'closeApp',
      desc: '',
      args: [],
    );
  }

  /// `Quit`
  String get quit {
    return Intl.message(
      'Quit',
      name: 'quit',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to quit the application?`
  String get sureCloseApp {
    return Intl.message(
      'Are you sure you want to quit the application?',
      name: 'sureCloseApp',
      desc: '',
      args: [],
    );
  }

  /// `OK`
  String get ok {
    return Intl.message(
      'OK',
      name: 'ok',
      desc: '',
      args: [],
    );
  }

  /// `CANCEL`
  String get cancel {
    return Intl.message(
      'CANCEL',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `Change Theme`
  String get changeTheme {
    return Intl.message(
      'Change Theme',
      name: 'changeTheme',
      desc: '',
      args: [],
    );
  }

  /// `Customize your own option`
  String get customizeYourOwnWay {
    return Intl.message(
      'Customize your own option',
      name: 'customizeYourOwnWay',
      desc: '',
      args: [],
    );
  }

  /// `Navigation bars style`
  String get navigationBarStyle {
    return Intl.message(
      'Navigation bars style',
      name: 'navigationBarStyle',
      desc: '',
      args: [],
    );
  }

  /// `Header type`
  String get headerType {
    return Intl.message(
      'Header type',
      name: 'headerType',
      desc: '',
      args: [],
    );
  }

  /// `Radio Button Options (left)`
  String get leftButtonOption {
    return Intl.message(
      'Radio Button Options (left)',
      name: 'leftButtonOption',
      desc: '',
      args: [],
    );
  }

  /// `Radio Button Options (right)`
  String get rightButtonOption {
    return Intl.message(
      'Radio Button Options (right)',
      name: 'rightButtonOption',
      desc: '',
      args: [],
    );
  }

  /// `Color Gradient`
  String get colorGradient {
    return Intl.message(
      'Color Gradient',
      name: 'colorGradient',
      desc: '',
      args: [],
    );
  }

  /// `Color Solid`
  String get colorSolid {
    return Intl.message(
      'Color Solid',
      name: 'colorSolid',
      desc: '',
      args: [],
    );
  }

  /// `Loading animation`
  String get loadingAnimation {
    return Intl.message(
      'Loading animation',
      name: 'loadingAnimation',
      desc: '',
      args: [],
    );
  }

  /// `Back to Homepage`
  String get backToHomePage {
    return Intl.message(
      'Back to Homepage',
      name: 'backToHomePage',
      desc: '',
      args: [],
    );
  }

  /// `Dark mode`
  String get darkMode {
    return Intl.message(
      'Dark mode',
      name: 'darkMode',
      desc: '',
      args: [],
    );
  }

  /// `Light mode`
  String get lightMode {
    return Intl.message(
      'Light mode',
      name: 'lightMode',
      desc: '',
      args: [],
    );
  }

  /// `Facebook`
  String get facebook {
    return Intl.message(
      'Facebook',
      name: 'facebook',
      desc: '',
      args: [],
    );
  }

  /// `Instagram`
  String get instagram {
    return Intl.message(
      'Instagram',
      name: 'instagram',
      desc: '',
      args: [],
    );
  }

  /// `Youtube`
  String get youtube {
    return Intl.message(
      'Youtube',
      name: 'youtube',
      desc: '',
      args: [],
    );
  }

  /// `Skype`
  String get skype {
    return Intl.message(
      'Skype',
      name: 'skype',
      desc: '',
      args: [],
    );
  }

  /// `Twitter`
  String get twitter {
    return Intl.message(
      'Twitter',
      name: 'twitter',
      desc: '',
      args: [],
    );
  }

  /// `WhatsApp`
  String get whatsApp {
    return Intl.message(
      'WhatsApp',
      name: 'whatsApp',
      desc: '',
      args: [],
    );
  }

  /// `messenger`
  String get messenger {
    return Intl.message(
      'messenger',
      name: 'messenger',
      desc: '',
      args: [],
    );
  }

  /// `Snapchat`
  String get snapchat {
    return Intl.message(
      'Snapchat',
      name: 'snapchat',
      desc: '',
      args: [],
    );
  }

  /// `Change Mosque`
  String get changeMosque {
    return Intl.message(
      'Change Mosque',
      name: 'changeMosque',
      desc: '',
      args: [],
    );
  }

  /// `Mosque`
  String get mosque {
    return Intl.message(
      'Mosque',
      name: 'mosque',
      desc: '',
      args: [],
    );
  }

  /// `Please enter the Mosque ID :`
  String get enterMosqueId {
    return Intl.message(
      'Please enter the Mosque ID :',
      name: 'enterMosqueId',
      desc: '',
      args: [],
    );
  }

  /// `Mosque ID`
  String get mosqueId {
    return Intl.message(
      'Mosque ID',
      name: 'mosqueId',
      desc: '',
      args: [],
    );
  }

  /// `Missing Mosque ID`
  String get missingMosqueId {
    return Intl.message(
      'Missing Mosque ID',
      name: 'missingMosqueId',
      desc: '',
      args: [],
    );
  }

  /// `Sorry, {mosqueId} isn't a valid mosque ID`
  String mosqueIdIsNotValid(Object mosqueId) {
    return Intl.message(
      'Sorry, $mosqueId isn\'t a valid mosque ID',
      name: 'mosqueIdIsNotValid',
      desc: '',
      args: [mosqueId],
    );
  }

  /// `Please enter your Mosque ID`
  String get selectMosqueId {
    return Intl.message(
      'Please enter your Mosque ID',
      name: 'selectMosqueId',
      desc: '',
      args: [],
    );
  }

  /// `Welcome to MAWAQIT`
  String get mawaqitWelcome {
    return Intl.message(
      'Welcome to MAWAQIT',
      name: 'mawaqitWelcome',
      desc: '',
      args: [],
    );
  }

  /// `MAWAQIT offers you a new way to track and manage prayer times, indeed we offer an end-to-end system that provides mosque managers with an online tool available 24/24h.`
  String get mawaqitDesc {
    return Intl.message(
      'MAWAQIT offers you a new way to track and manage prayer times, indeed we offer an end-to-end system that provides mosque managers with an online tool available 24/24h.',
      name: 'mawaqitDesc',
      desc: '',
      args: [],
    );
  }

  /// `Privacy policy`
  String get privacyPolicy {
    return Intl.message(
      'Privacy policy',
      name: 'privacyPolicy',
      desc: '',
      args: [],
    );
  }

  /// `Terms of Service`
  String get termsOfService {
    return Intl.message(
      'Terms of Service',
      name: 'termsOfService',
      desc: '',
      args: [],
    );
  }

  /// `Installation Guide`
  String get installationGuide {
    return Intl.message(
      'Installation Guide',
      name: 'installationGuide',
      desc: '',
      args: [],
    );
  }

  /// `MAWAQIT`
  String get drawerTitle {
    return Intl.message(
      'MAWAQIT',
      name: 'drawerTitle',
      desc: '',
      args: [],
    );
  }

  /// `Connecting Muslims to Mosques`
  String get drawerDesc {
    return Intl.message(
      'Connecting Muslims to Mosques',
      name: 'drawerDesc',
      desc: '',
      args: [],
    );
  }

  /// `Sorry, we could not connect to the server.\nPlease verify Internet connectivity or try again later.`
  String get backendError {
    return Intl.message(
      'Sorry, we could not connect to the server.\nPlease verify Internet connectivity or try again later.',
      name: 'backendError',
      desc: '',
      args: [],
    );
  }

  /// `Mosque Input`
  String get mosqueInput {
    return Intl.message(
      'Mosque Input',
      name: 'mosqueInput',
      desc: '',
      args: [],
    );
  }

  /// `Try: 256, It's the ID of the 'Mosquée de Paris'`
  String get selectWithMosqueId {
    return Intl.message(
      'Try: 256, It\'s the ID of the \'Mosquée de Paris\'',
      name: 'selectWithMosqueId',
      desc: '',
      args: [],
    );
  }

  /// `Which Mosque are you looking for ? (Name, City, Postal code...)`
  String get searchForMosque {
    return Intl.message(
      'Which Mosque are you looking for ? (Name, City, Postal code...)',
      name: 'searchForMosque',
      desc: '',
      args: [],
    );
  }

  /// `Search for a Mosque`
  String get searchMosque {
    return Intl.message(
      'Search for a Mosque',
      name: 'searchMosque',
      desc: '',
      args: [],
    );
  }

  /// `Cannot access current device location, please check that your device GPS is enabled`
  String get gpsError {
    return Intl.message(
      'Cannot access current device location, please check that your device GPS is enabled',
      name: 'gpsError',
      desc: '',
      args: [],
    );
  }

  /// `Enter the Mosque name`
  String get mosqueNameError {
    return Intl.message(
      'Enter the Mosque name',
      name: 'mosqueNameError',
      desc: '',
      args: [],
    );
  }

  /// `Isn't a valid mosque slug`
  String get slugError {
    return Intl.message(
      'Isn\'t a valid mosque slug',
      name: 'slugError',
      desc: '',
      args: [],
    );
  }

  /// `Do you know your installation ID or your Mosque ID?`
  String get doYouKnowMosqueId {
    return Intl.message(
      'Do you know your installation ID or your Mosque ID?',
      name: 'doYouKnowMosqueId',
      desc: '',
      args: [],
    );
  }

  /// `Yes`
  String get yes {
    return Intl.message(
      'Yes',
      name: 'yes',
      desc: '',
      args: [],
    );
  }

  /// `No`
  String get no {
    return Intl.message(
      'No',
      name: 'no',
      desc: '',
      args: [],
    );
  }

  /// `Network Status`
  String get networkStatus {
    return Intl.message(
      'Network Status',
      name: 'networkStatus',
      desc: '',
      args: [],
    );
  }

  /// `No more results`
  String get mosqueNoMore {
    return Intl.message(
      'No more results',
      name: 'mosqueNoMore',
      desc: '',
      args: [],
    );
  }

  /// `No results`
  String get mosqueNoResults {
    return Intl.message(
      'No results',
      name: 'mosqueNoResults',
      desc: '',
      args: [],
    );
  }

  /// `Offline`
  String get offline {
    return Intl.message(
      'Offline',
      name: 'offline',
      desc: '',
      args: [],
    );
  }

  /// `Imsak`
  String get imsak {
    return Intl.message(
      'Imsak',
      name: 'imsak',
      desc: '',
      args: [],
    );
  }

  /// `Jumua`
  String get jumua {
    return Intl.message(
      'Jumua',
      name: 'jumua',
      desc: '',
      args: [],
    );
  }

  /// `Duhr`
  String get duhr {
    return Intl.message(
      'Duhr',
      name: 'duhr',
      desc: '',
      args: [],
    );
  }

  /// `Fajr`
  String get fajr {
    return Intl.message(
      'Fajr',
      name: 'fajr',
      desc: '',
      args: [],
    );
  }

  /// `Asr`
  String get asr {
    return Intl.message(
      'Asr',
      name: 'asr',
      desc: '',
      args: [],
    );
  }

  /// `Maghrib`
  String get maghrib {
    return Intl.message(
      'Maghrib',
      name: 'maghrib',
      desc: '',
      args: [],
    );
  }

  /// `Isha`
  String get isha {
    return Intl.message(
      'Isha',
      name: 'isha',
      desc: '',
      args: [],
    );
  }

  /// `After salah Du'a`
  String get afterSalahHadithTitle {
    return Intl.message(
      'After salah Du`a',
      name: 'afterSalahHadithTitle',
      desc: '',
      args: [],
    );
  }

  /// `Allahumma Rabba hadhihid-da'wati-ttammati, was-salatil-qa'imati, ati Muhammadanil-wasilata wal-fadhilata, wab'athu maqaman mahmuda nilladhi wa 'adtahu [O Allah, Rubb of this perfect call (Da'wah) and of the established prayer (As-Salat), grant Muhammad the Wasilah and superiority, and raise him up to a praiseworthy position which You have promised him]`
  String get afterSalahHadith {
    return Intl.message(
      'Allahumma Rabba hadhihid-da\'wati-ttammati, was-salatil-qa\'imati, ati Muhammadanil-wasilata wal-fadhilata, wab\'athu maqaman mahmuda nilladhi wa \'adtahu [O Allah, Rubb of this perfect call (Da\'wah) and of the established prayer (As-Salat), grant Muhammad the Wasilah and superiority, and raise him up to a praiseworthy position which You have promised him]',
      name: 'afterSalahHadith',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ar'),
      Locale.fromSubtags(languageCode: 'bn'),
      Locale.fromSubtags(languageCode: 'de'),
      Locale.fromSubtags(languageCode: 'es'),
      Locale.fromSubtags(languageCode: 'fr'),
      Locale.fromSubtags(languageCode: 'hr'),
      Locale.fromSubtags(languageCode: 'it'),
      Locale.fromSubtags(languageCode: 'ml'),
      Locale.fromSubtags(languageCode: 'nl'),
      Locale.fromSubtags(languageCode: 'pt'),
      Locale.fromSubtags(languageCode: 'sq'),
      Locale.fromSubtags(languageCode: 'ta'),
      Locale.fromSubtags(languageCode: 'tr'),
      Locale.fromSubtags(languageCode: 'ur'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
