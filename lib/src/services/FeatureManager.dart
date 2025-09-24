import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mawaqit/main.dart';
import 'package:provider/provider.dart';

import '../const/constants.dart';
import 'mosque_manager.dart';

class FeatureManager extends ChangeNotifier {
  static FeatureManager? _instance;
  Map<String, bool> _featureFlags = {};
  bool isConnectedToInternet = false;
  SharedPreferences? _prefs;
  bool _isInitialized = false;

  // Private constructor
  FeatureManager._internal();

  // Singleton instance getter
  static FeatureManager get instance {
    _instance ??= FeatureManager._internal();
    return _instance!;
  }

  // Factory constructor for Provider compatibility
  factory FeatureManager(BuildContext context) {
    final instance = FeatureManager.instance;
    if (!instance._isInitialized) {
      instance._initializeWithContext(context);
    }
    return instance;
  }

  // Initialize with default flags for early access
  void _initializeDefaults() {
    if (_isInitialized) return;

    // Set hardcoded defaults for early access (before Flutter bindings are ready)
    _featureFlags = {"timezone_shift": true};
    _isInitialized = true;
  }

  // Initialize with SharedPreferences when bindings are ready
  Future<void> _initializeWithSharedPreferences() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      final savedFlags = _prefs!.getString('featureFlags');
      if (savedFlags != null) {
        final loadedFlags = Map<String, bool>.from(json.decode(savedFlags));
        _featureFlags = loadedFlags;
      }
    } catch (error, stack) {
      logger.e(error, stackTrace: stack);
      // Keep existing defaults if SharedPreferences fails
    }
  }

  void _initializeWithContext(BuildContext context) {
    if (_isInitialized) {
      // If we only have defaults, try to load from SharedPreferences now
      if (_prefs == null) {
        _initializeWithSharedPreferences();
      }
    } else {
      _initializeDefaults();
    }

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
      _prefs ??= await SharedPreferences.getInstance();
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
      final response = await http.get(Uri.parse('https://cdn.mawaqit.net/android/tv/android-tv-feature-flag.json'));

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
        throw Exception('Failed to load feature flags. Status Code: ${response.statusCode}');
      }
    } catch (error, stackTrace) {
      logger.e(error, stackTrace: stackTrace);
    }
  }

  bool isFeatureEnabled(String featureName) {
    // Ensure we have defaults loaded for early access
    if (!_isInitialized) {
      _initializeDefaults();
    }
    return _featureFlags[featureName] ?? false;
  }
}
