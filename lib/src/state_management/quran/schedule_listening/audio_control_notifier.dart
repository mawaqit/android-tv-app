import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:mawaqit/src/state_management/quran/schedule_listening/audio_control_state.dart';
import 'package:mawaqit/src/state_management/quran/schedule_listening/schedule_listening_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../const/constants.dart';

/// Provider for the AudioControlNotifier
final audioControlProvider = AsyncNotifierProvider<AudioControlNotifier, AudioControlState>(
  () => AudioControlNotifier(),
);

/// Manages the audio control state and interactions with the background service
class AudioControlNotifier extends AsyncNotifier<AudioControlState> {
  /// Background service instance
  final FlutterBackgroundService _service;

  /// Creates an AudioControlNotifier with an optional background service
  AudioControlNotifier({FlutterBackgroundService? service}) : _service = service ?? FlutterBackgroundService();

  @override
  Future<AudioControlState> build() async {
    await _initializeListeners();
    return _getInitialState();
  }

  /// Initializes all event listeners for the audio control
  Future<void> _initializeListeners() async {
    _setupAudioStateListener();
    _setupScheduleStateListener();
    await _checkPlaybackState();
  }

  /// Sets up the listener for audio state changes from the background service
  void _setupAudioStateListener() {
    _service.on(BackgroundScheduleAudioServiceConstant.kAudioStateChanged).listen(_handleAudioStateChange);
  }

  /// Handles audio state changes received from the background service
  void _handleAudioStateChange(Map<String, dynamic>? event) {
    if (event == null || event['isPlaying'] == null) return;

    final isPlaying = event['isPlaying'] as bool;
    _updatePlaybackState(isPlaying);
  }

  /// Updates the playback state in the notifier
  void _updatePlaybackState(bool isPlaying) {
    try {
      state = AsyncData(state.value!.copyWith(
        status: isPlaying ? AudioStatus.playing : AudioStatus.paused,
      ));
    } catch (e) {
      _handleError('Failed to update playback state: $e');
    }
  }

  /// Sets up the listener for schedule state changes
  void _setupScheduleStateListener() {
    ref.listen(scheduleProvider, _handleScheduleStateChange);
  }

  /// Handles schedule state changes
  void _handleScheduleStateChange(AsyncValue<dynamic>? previous, AsyncValue<dynamic> next) {
    if (next.value != null) {
      try {
        state = AsyncData(state.value!.copyWith(
          shouldShowControls: next.value!.isScheduleEnabled,
        ));
      } catch (e) {
        _handleError('Failed to update controls visibility: $e');
      }
    }
  }

  /// Retrieves the initial state from SharedPreferences
  Future<AudioControlState> _getInitialState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isScheduleEnabled = prefs.getBool(BackgroundScheduleAudioServiceConstant.kScheduleEnabled) ?? false;

      return AudioControlState(
        status: AudioStatus.paused,
        shouldShowControls: isScheduleEnabled,
      );
    } catch (e) {
      _handleError('Failed to get initial state: $e');
      return const AudioControlState(
        status: AudioStatus.paused,
        shouldShowControls: false,
      );
    }
  }

  /// Checks the current playback state with the background service
  Future<void> _checkPlaybackState() async {
    try {
      await _updateLoadingState(true);
      _service.invoke(BackgroundScheduleAudioServiceConstant.kGetPlaybackState);
    } catch (e) {
      _handleError('Failed to check playback state: $e');
    } finally {
      await _updateLoadingState(false);
    }
  }

  /// Updates the loading state of the notifier
  Future<void> _updateLoadingState(bool isLoading) async {
    try {
      state = AsyncData(state.value!.copyWith(isLoading: isLoading));
    } catch (e) {
      _handleError('Failed to update loading state: $e');
    }
  }

  /// Handles errors by updating the state with the error message
  void _handleError(String errorMessage) {
    try {
      state = AsyncData(state.value!.copyWith(
        isLoading: false,
        error: errorMessage,
      ));
    } catch (e) {
      // If we can't even update the error state, log it
      print('Critical error: Unable to update error state: $e');
    }
  }

  /// Toggles the playback state between playing and paused
  Future<void> togglePlayback() async {
    if (state.value == null) return;

    final currentStatus = state.value!.status;
    final newStatus = currentStatus == AudioStatus.playing ? AudioStatus.paused : AudioStatus.playing;

    try {
      // Update state optimistically
      await _updatePlaybackStateWithLoading(newStatus);

      // Invoke appropriate service method
      _service.invoke(newStatus == AudioStatus.paused
          ? BackgroundScheduleAudioServiceConstant.kStopAudio
          : BackgroundScheduleAudioServiceConstant.kResumeAudio);
    } catch (e) {
      // Revert to previous state on error
      await _updatePlaybackStateWithLoading(currentStatus);
      _handleError('Failed to toggle playback: $e');
    }
  }

  /// Updates the playback state with loading indicator
  Future<void> _updatePlaybackStateWithLoading(AudioStatus status) async {
    try {
      state = AsyncData(state.value!.copyWith(
        status: status,
        isLoading: true,
      ));

      // Simulate a small delay for UI feedback
      await Future.delayed(const Duration(milliseconds: 100));

      state = AsyncData(state.value!.copyWith(
        isLoading: false,
      ));
    } catch (e) {
      _handleError('Failed to update playback state: $e');
    }
  }
}
