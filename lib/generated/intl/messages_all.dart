// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that looks up messages for specific locales by
// delegating to the appropriate library.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:implementation_imports, file_names, unnecessary_new
// ignore_for_file:unnecessary_brace_in_string_interps, directives_ordering
// ignore_for_file:argument_type_not_assignable, invalid_assignment
// ignore_for_file:prefer_single_quotes, prefer_generic_function_type_aliases
// ignore_for_file:comment_references

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';
import 'package:intl/src/intl_helpers.dart';

import 'messages_ar.dart' as messages_ar;
import 'messages_bn.dart' as messages_bn;
import 'messages_de.dart' as messages_de;
import 'messages_en.dart' as messages_en;
import 'messages_es.dart' as messages_es;
import 'messages_fr.dart' as messages_fr;
import 'messages_hr.dart' as messages_hr;
import 'messages_it.dart' as messages_it;
import 'messages_ml.dart' as messages_ml;
import 'messages_nl.dart' as messages_nl;
import 'messages_pt.dart' as messages_pt;
import 'messages_sq.dart' as messages_sq;
import 'messages_ta.dart' as messages_ta;
import 'messages_tr.dart' as messages_tr;
import 'messages_ur.dart' as messages_ur;

typedef Future<dynamic> LibraryLoader();
Map<String, LibraryLoader> _deferredLibraries = {
  'ar': () => new SynchronousFuture(null),
  'bn': () => new SynchronousFuture(null),
  'de': () => new SynchronousFuture(null),
  'en': () => new SynchronousFuture(null),
  'es': () => new SynchronousFuture(null),
  'fr': () => new SynchronousFuture(null),
  'hr': () => new SynchronousFuture(null),
  'it': () => new SynchronousFuture(null),
  'ml': () => new SynchronousFuture(null),
  'nl': () => new SynchronousFuture(null),
  'pt': () => new SynchronousFuture(null),
  'sq': () => new SynchronousFuture(null),
  'ta': () => new SynchronousFuture(null),
  'tr': () => new SynchronousFuture(null),
  'ur': () => new SynchronousFuture(null),
};

MessageLookupByLibrary? _findExact(String localeName) {
  switch (localeName) {
    case 'ar':
      return messages_ar.messages;
    case 'bn':
      return messages_bn.messages;
    case 'de':
      return messages_de.messages;
    case 'en':
      return messages_en.messages;
    case 'es':
      return messages_es.messages;
    case 'fr':
      return messages_fr.messages;
    case 'hr':
      return messages_hr.messages;
    case 'it':
      return messages_it.messages;
    case 'ml':
      return messages_ml.messages;
    case 'nl':
      return messages_nl.messages;
    case 'pt':
      return messages_pt.messages;
    case 'sq':
      return messages_sq.messages;
    case 'ta':
      return messages_ta.messages;
    case 'tr':
      return messages_tr.messages;
    case 'ur':
      return messages_ur.messages;
    default:
      return null;
  }
}

/// User programs should call this before using [localeName] for messages.
Future<bool> initializeMessages(String localeName) {
  var availableLocale = Intl.verifiedLocale(
      localeName, (locale) => _deferredLibraries[locale] != null,
      onFailure: (_) => null);
  if (availableLocale == null) {
    return new SynchronousFuture(false);
  }
  var lib = _deferredLibraries[availableLocale];
  lib == null ? new SynchronousFuture(false) : lib();
  initializeInternalMessageLookup(() => new CompositeMessageLookup());
  messageLookup.addLocale(availableLocale, _findGeneratedMessagesFor);
  return new SynchronousFuture(true);
}

bool _messagesExistFor(String locale) {
  try {
    return _findExact(locale) != null;
  } catch (e) {
    return false;
  }
}

MessageLookupByLibrary? _findGeneratedMessagesFor(String locale) {
  var actualLocale =
      Intl.verifiedLocale(locale, _messagesExistFor, onFailure: (_) => null);
  if (actualLocale == null) return null;
  return _findExact(actualLocale);
}
