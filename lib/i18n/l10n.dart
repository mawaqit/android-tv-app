import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class S {
  S();

  static AppLocalizations? _current;

  static AppLocalizations get current {
    assert(
        _current != null, 'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static AppLocalizations of(BuildContext context) {
    _current = AppLocalizations.of(context);

    assert(_current != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return _current!;
  }

  static AppLocalizations? maybeOf(BuildContext context) => AppLocalizations.of(context);

  static LocalizationsDelegate<AppLocalizations> get delegate => AppLocalizations.delegate;

  static List<Locale> get supportedLocales => AppLocalizations.supportedLocales;
}
