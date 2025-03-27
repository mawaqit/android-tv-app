import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StreamOverlaySettings extends Equatable {
  final bool autoOverlayEnabled;
  final bool isOverlayActive;
  final bool isStreamActuallyLive;
  final bool manuallyClosedByUser;

  const StreamOverlaySettings({
    this.autoOverlayEnabled = false,
    this.isOverlayActive = false,
    this.isStreamActuallyLive = false,
    this.manuallyClosedByUser = false,
  });

// Update copyWith method
  StreamOverlaySettings copyWith({
    bool? autoOverlayEnabled,
    bool? isOverlayActive,
    bool? isStreamActuallyLive,
    bool? manuallyClosedByUser,
  }) {
    return StreamOverlaySettings(
      autoOverlayEnabled: autoOverlayEnabled ?? this.autoOverlayEnabled,
      isOverlayActive: isOverlayActive ?? this.isOverlayActive,
      isStreamActuallyLive: isStreamActuallyLive ?? this.isStreamActuallyLive,
      manuallyClosedByUser: manuallyClosedByUser ?? this.manuallyClosedByUser,
    );
  }

  @override
  List<Object?> get props =>
      [autoOverlayEnabled, isOverlayActive, isStreamActuallyLive];

  // Helper getter to determine if overlay should be visible based on settings and stream status
  bool get shouldShowOverlay =>
      isOverlayActive ||
      (autoOverlayEnabled && isStreamActuallyLive && !manuallyClosedByUser);
}

class StreamOverlaySettingsNotifier
    extends StateNotifier<StreamOverlaySettings> {
  StreamOverlaySettingsNotifier() : super(const StreamOverlaySettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final autoOverlayEnabled =
          prefs.getBool('stream_auto_overlay_enabled') ?? false;
      // Optionally persist the manually closed flag
      final manuallyClosedByUser =
          prefs.getBool('stream_manually_closed') ?? false;

      state = state.copyWith(
          autoOverlayEnabled: autoOverlayEnabled,
          manuallyClosedByUser: manuallyClosedByUser);

      // Log loaded settings
      debugPrint(
          'Loaded settings: autoOverlayEnabled=$autoOverlayEnabled, manuallyClosedByUser=$manuallyClosedByUser');
    } catch (e) {
      debugPrint('Error loading overlay settings: $e');
    }
  }

  // This method is called by the StreamMonitorService when stream status changes
  void handleStreamStatusChange(bool isLive) {
    debugPrint(
        'Stream status changed: isLive=$isLive (current state: autoEnabled=${state.autoOverlayEnabled}, isActive=${state.isOverlayActive})');

    // Update the stream live status in state
    state = state.copyWith(isStreamActuallyLive: isLive);

    // Only automatically show/hide overlay if auto mode is enabled and user hasn't manually closed it
    if (state.autoOverlayEnabled && !state.manuallyClosedByUser) {
      // If stream is live, show overlay. If stream is not live, hide overlay.
      _setOverlayActiveInternal(isLive);
      debugPrint('Auto mode active: setting overlay to $isLive');
    }
  }

  Future<void> toggleAutoOverlay(bool enabled) async {
    debugPrint(
        'Toggling auto overlay: $enabled (current stream status: ${state.isStreamActuallyLive})');
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('stream_auto_overlay_enabled', enabled);

      if (enabled) {
        // When enabling auto mode, reset the manually closed flag
        state = state.copyWith(
            autoOverlayEnabled: true, manuallyClosedByUser: false);

        // Don't immediately change the overlay state - let the stream monitor determine this
        // The stream monitor will call handleStreamStatusChange with the current live status

        // Note: The stream monitor's status will take effect in the next check cycle
        // If we need immediate feedback, we can force a check by calling
        // StreamMonitorService.checkAndNotify() here, but that would need to be
        // passed in or accessed via a provider
      } else {
        // Just disable auto mode without changing other flags
        state = state.copyWith(autoOverlayEnabled: false);
      }
    } catch (e) {
      debugPrint('Error toggling auto overlay: $e');
    }
  }

  void setOverlayActive(bool active) {
    debugPrint('Manually setting overlay active: $active');

    if (!active) {
      // User is manually closing the overlay
      state =
          state.copyWith(isOverlayActive: false, manuallyClosedByUser: true);
    } else {
      // User is manually opening the overlay
      state =
          state.copyWith(isOverlayActive: true, manuallyClosedByUser: false);
    }
  }

  // Internal method that only modifies the overlay active state without affecting auto setting
  void _setOverlayActiveInternal(bool active) {
    state = state.copyWith(isOverlayActive: active);
  }
}

final streamOverlaySettingsProvider =
    StateNotifierProvider<StreamOverlaySettingsNotifier, StreamOverlaySettings>(
        (ref) {
  return StreamOverlaySettingsNotifier();
});
