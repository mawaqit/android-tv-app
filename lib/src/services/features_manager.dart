import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mawaqit/main.dart';
import 'package:provider/provider.dart';

import 'mosque_manager.dart';

class FeatureManager extends ChangeNotifier {
  Map<String, bool> _featureFlags = {};
  bool isConnectedToInternet = false;
  SharedPreferences? _prefs;

  FeatureManager(BuildContext context) {
    final mosqueProvider = Provider.of<MosqueManager>(context, listen: false);
    isConnectedToInternet = mosqueProvider.isOnline;
    mosqueProvider.addListener(() => _onMosqueManagerChanged(context));
    if (isConnectedToInternet) {
      fetchFeatureFlags(context);
    } else {
      _initPrefs();
    }
  }

  void _onMosqueManagerChanged(BuildContext context) {
    final mosqueProvider = Provider.of<MosqueManager>(context, listen: false);
    final newIsConnectedToInternet = mosqueProvider.isOnline;

    if (newIsConnectedToInternet != isConnectedToInternet) {
      isConnectedToInternet = newIsConnectedToInternet;

      if (isConnectedToInternet) {
        fetchFeatureFlags(context);
      } else {
        _initPrefs();
      }

      notifyListeners();
    }
  }

  Future<void> _initPrefs() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      final savedFlags = _prefs!.getString('featureFlags');
      if (savedFlags != null) {
        _featureFlags = Map<String, bool>.from(json.decode(savedFlags));
      } else {
        _featureFlags = {"timezone_shift": true};
      }
    } catch (error, stack) {
      logger.e(error, stackTrace: stack);
    }
  }

  Future<void> fetchFeatureFlags(BuildContext context) async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://cdn.mawaqit.net/android/tv/android-tv-feature-flag.json'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _featureFlags.clear();
        data.forEach((key, value) {
          if (value is bool) {
            _featureFlags[key] = value;
          }
        });
        notifyListeners();
        await _prefs?.setString('featureFlags', json.encode(_featureFlags));
      } else {
        throw Exception(
            'Failed to load feature flags. Status Code: ${response.statusCode}');
      }
    } catch (error, stackTrace) {
      logger.e(error, stackTrace: stackTrace);
    }
  }

  bool isFeatureEnabled(String featureName) {
    return _featureFlags[featureName] ?? false;
  }
}
