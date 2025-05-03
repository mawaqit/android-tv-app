abstract class PrayerAudioException implements Exception {
  final String message;
  final String errorCode;

  PrayerAudioException(this.message, this.errorCode);

  @override
  String toString() => 'Error ($errorCode): $message';
}

class PlayAdhanException extends PrayerAudioException {
  PlayAdhanException(String message)
      : super('Error occurred while playing Adhan: $message', 'PLAY_ADHAN_ERROR');
}

class PlayIqamaException extends PrayerAudioException {
  PlayIqamaException(String message)
      : super('Error occurred while playing Iqama: $message', 'PLAY_IQAMA_ERROR');
}

class PlayDuaException extends PrayerAudioException {
  PlayDuaException(String message)
      : super('Error occurred while playing Dua: $message', 'PLAY_DUA_ERROR');
}

class AudioInitializationTimeoutException extends PrayerAudioException {
  AudioInitializationTimeoutException(String message)
      : super('Audio initialization timeout: $message', 'AUDIO_INIT_TIMEOUT_ERROR');
}

class UnknownPrayerAudioException extends PrayerAudioException {
  UnknownPrayerAudioException(String message)
      : super('Unknown prayer audio error: $message', 'UNKNOWN_PRAYER_AUDIO_ERROR');
}
