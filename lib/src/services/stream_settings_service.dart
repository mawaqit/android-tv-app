import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as dev;

import '../const/constants.dart';

/// Service for managing stream settings persistence
class StreamSettingsService {
  static const String _enabledKey = LiveStreamConstants.prefKeyEnabled;
  static const String _urlKey = LiveStreamConstants.prefKeyUrl;
  static const String _replaceWorkflowKey = LiveStreamConstants.prefKeyReplaceWorkflow;
  static const String _previousWorkflowKey = LiveStreamConstants.prefKeyPreviousWorkflowReplacement;

  /// Get stream enabled state
  Future<bool> isStreamEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(_enabledKey) ?? false;
    dev.log('📖 [SETTINGS_SERVICE] Stream enabled: $enabled');
    return enabled;
  }

  /// Set stream enabled state
  Future<void> setStreamEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, enabled);
    dev.log('💾 [SETTINGS_SERVICE] Stream enabled set to: $enabled');
  }

  /// Get stream URL
  Future<String?> getStreamUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final url = prefs.getString(_urlKey);
    dev.log('📖 [SETTINGS_SERVICE] Stream URL: $url');
    return url;
  }

  /// Set stream URL
  Future<void> setStreamUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_urlKey, url);
    dev.log('💾 [SETTINGS_SERVICE] Stream URL set to: $url');
  }

  /// Get replace workflow state
  Future<bool> isReplaceWorkflowEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(_replaceWorkflowKey) ?? false;
    dev.log('📖 [SETTINGS_SERVICE] Replace workflow enabled: $enabled');
    return enabled;
  }

  /// Set replace workflow state
  Future<void> setReplaceWorkflowEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_replaceWorkflowKey, enabled);
    dev.log('💾 [SETTINGS_SERVICE] Replace workflow set to: $enabled');
  }

  /// Get previous workflow state (for restoration after reconnection)
  Future<bool> getPreviousWorkflowState() async {
    final prefs = await SharedPreferences.getInstance();
    final state = prefs.getBool(_previousWorkflowKey) ?? false;
    dev.log('📖 [SETTINGS_SERVICE] Previous workflow state: $state');
    return state;
  }

  /// Set previous workflow state (for restoration after reconnection)
  Future<void> setPreviousWorkflowState(bool state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_previousWorkflowKey, state);
    dev.log('💾 [SETTINGS_SERVICE] Previous workflow state set to: $state');
  }

  /// Clear previous workflow state
  Future<void> clearPreviousWorkflowState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_previousWorkflowKey);
    dev.log('🗑️ [SETTINGS_SERVICE] Previous workflow state cleared');
  }

  /// Get all stream settings
  Future<StreamSettings> getAllSettings() async {
    final enabled = await isStreamEnabled();
    final url = await getStreamUrl();
    final replaceWorkflow = await isReplaceWorkflowEnabled();
    
    return StreamSettings(
      isEnabled: enabled,
      streamUrl: url,
      replaceWorkflow: replaceWorkflow,
    );
  }

  /// Save all stream settings
  Future<void> saveAllSettings(StreamSettings settings) async {
    await setStreamEnabled(settings.isEnabled);
    if (settings.streamUrl != null) {
      await setStreamUrl(settings.streamUrl!);
    }
    await setReplaceWorkflowEnabled(settings.replaceWorkflow);
    dev.log('💾 [SETTINGS_SERVICE] All settings saved');
  }
}

/// Data class for stream settings
class StreamSettings {
  final bool isEnabled;
  final String? streamUrl;
  final bool replaceWorkflow;

  const StreamSettings({
    required this.isEnabled,
    this.streamUrl,
    required this.replaceWorkflow,
  });

  @override
  String toString() {
    return 'StreamSettings{isEnabled: $isEnabled, streamUrl: $streamUrl, replaceWorkflow: $replaceWorkflow}';
  }
} 