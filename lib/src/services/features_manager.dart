import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mawaqit/main.dart';

// Manager responsible for managing feature status (enabled or disabled).

class FeatureManager extends ChangeNotifier {
  Map<String, bool> _featureFlags = {};

  // Getter for accessing feature flags
  Map<String, bool> get featureFlags => _featureFlags;

  // Fetch feature flags
  Future<void> fetchFeatureFlags() async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://cdn.mawaqit.net/android/tv/android-tv-feature-flag.json'),
      );

      // If the request is successful
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Clear existing flags
        _featureFlags.clear();

        // Parse and update feature flags
        data.forEach((key, value) {
          if (value is bool) {
            _featureFlags[key] = value;
          }
        });

        notifyListeners();
      } else {
        throw Exception('Failed to load feature flags');
      }
    } catch (error, stackTrace) {
      logger.e(error, stackTrace: stackTrace);
    }
  }

  // Check if a feature is enabled
  bool isFeatureEnabled(String featureName) {
    return _featureFlags[featureName] ?? false;
  }
}
