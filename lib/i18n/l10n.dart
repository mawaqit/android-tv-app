import 'package:flutter/material.dart';
import 'package:mawaqit_tv_l10n/mawaqit_tv_l10n.dart';

class S {
  S();

  static MawaqitTvLocalizations? _current;

  static MawaqitTvLocalizations get current {
    assert(
        _current != null, 'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static MawaqitTvLocalizations of(BuildContext context) {
    _current = MawaqitTvLocalizations.of(context);

    assert(_current != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return _current!;
  }

  static MawaqitTvLocalizations? maybeOf(BuildContext context) => MawaqitTvLocalizations.of(context);

  static LocalizationsDelegate<MawaqitTvLocalizations> get delegate => MawaqitTvLocalizations.delegate;

  static List<Locale> get supportedLocales => MawaqitTvLocalizations.supportedLocales;

  // Add this method to manually set the current localization.
  static void setCurrent(MawaqitTvLocalizations localizations) {
    _current = localizations;
  }
}
