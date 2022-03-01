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

  /// `Notification`
  String get notification {
    return Intl.message(
      'Notification',
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

  /// `Select your preferred languages`
  String get descLang {
    return Intl.message(
      'Select your preferred languages',
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

  /// `Close APP`
  String get closeApp {
    return Intl.message(
      'Close APP',
      name: 'closeApp',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure want to quit this application ?`
  String get sureCloseApp {
    return Intl.message(
      'Are you sure want to quit this application ?',
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

  /// `Customize your own way`
  String get customizeYourOwnWay {
    return Intl.message(
      'Customize your own way',
      name: 'customizeYourOwnWay',
      desc: '',
      args: [],
    );
  }

  /// `Navigation bar style`
  String get navigationBarStyle {
    return Intl.message(
      'Navigation bar style',
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

  /// `Left Button Option`
  String get leftButtonOption {
    return Intl.message(
      'Left Button Option',
      name: 'leftButtonOption',
      desc: '',
      args: [],
    );
  }

  /// `Right Button Option`
  String get rightButtonOption {
    return Intl.message(
      'Right Button Option',
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

  /// `Loading Animation`
  String get loadingAnimation {
    return Intl.message(
      'Loading Animation',
      name: 'loadingAnimation',
      desc: '',
      args: [],
    );
  }

  /// `Back to HomePage`
  String get backToHomePage {
    return Intl.message(
      'Back to HomePage',
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

  /// `Snap chat`
  String get snapchat {
    return Intl.message(
      'Snap chat',
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
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ar'),
      Locale.fromSubtags(languageCode: 'de'),
      Locale.fromSubtags(languageCode: 'es'),
      Locale.fromSubtags(languageCode: 'fr'),
      Locale.fromSubtags(languageCode: 'nl'),
      Locale.fromSubtags(languageCode: 'pt'),
      Locale.fromSubtags(languageCode: 'tr'),
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
