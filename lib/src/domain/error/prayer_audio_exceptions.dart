/// Base class for prayer audio exceptions
abstract class PrayerAudioException implements Exception {
  final String message;
  final String errorCode;

  PrayerAudioException(this.message, this.errorCode);

  @override
  String toString() => 'Error ($errorCode): $message';
}

/// Exception thrown when audio initialization times out
class AudioInitializationTimeoutException extends PrayerAudioException {
  AudioInitializationTimeoutException(String message)
      : super('Audio initialization timeout: $message', 'AUDIO_INIT_TIMEOUT_ERROR');
}

/// Exception thrown when playing adhan fails
class PlayAdhanException extends PrayerAudioException {
  PlayAdhanException(String message) : super('Error occurred while playing Adhan: $message', 'PLAY_ADHAN_ERROR');
}

/// Exception thrown when playing iqama fails
class PlayIqamaException extends PrayerAudioException {
  PlayIqamaException(String message) : super('Error occurred while playing Iqama: $message', 'PLAY_IQAMA_ERROR');
}

/// Exception thrown when playing dua fails
class PlayDuaException extends PrayerAudioException {
  PlayDuaException(String message) : super('Error occurred while playing Dua: $message', 'PLAY_DUA_ERROR');
}

/// Exception for general unknown errors
class UnknownPrayerAudioException extends PrayerAudioException {
  UnknownPrayerAudioException(String message)
      : super('Unknown prayer audio error: $message', 'UNKNOWN_PRAYER_AUDIO_ERROR');
}

/// Exception for audio cache download failures
class AudioCacheDownloadException extends PrayerAudioException {
  AudioCacheDownloadException(String message)
      : super('Error occurred while downloading audio cache: $message', 'AUDIO_CACHE_DOWNLOAD_ERROR');
}

/// Exception for when cache is empty and network is unavailable
class AudioCacheMissingException extends PrayerAudioException {
  AudioCacheMissingException(String message)
      : super('Audio cache is missing and network is unavailable: $message', 'AUDIO_CACHE_MISSING_ERROR');
}

/// Exception for corrupted audio cache files
class AudioCacheCorruptedException extends PrayerAudioException {
  AudioCacheCorruptedException(String message)
      : super('Audio cache file is corrupted: $message', 'AUDIO_CACHE_CORRUPTED_ERROR');
}
