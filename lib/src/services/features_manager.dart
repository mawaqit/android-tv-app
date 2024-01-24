import 'package:flutter/material.dart';
import 'package:mawaqit/main.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class FeatureManager extends ChangeNotifier {
  Map<String, bool> _featureFlags = {};

  Map<String, bool> get featureFlags => _featureFlags;

  Future<void> fetchFeatureFlags() async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://cdn.mawaqit.net/android/tv/android-tv-feature-flag.json'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Clear existing flags
        _featureFlags.clear();

        // Parse feature flags
        data.forEach((key, value) {
          if (value is bool) {
            _featureFlags[key] = value;
          }
        });

        // Notify listeners that the features have been updated
        notifyListeners();

        // Print feature flags for debugging
      } else {
        throw Exception('Failed to load feature flags');
      }
    } catch (error, stackTrace) {
      logger.e(error, stackTrace: stackTrace);
    }
  }

  bool isFeatureEnabled(String featureName) {
    return _featureFlags[featureName] ?? false;
  }
}
