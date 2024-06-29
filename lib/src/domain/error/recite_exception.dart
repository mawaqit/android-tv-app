import 'package:mawaqit/src/domain/error/quran_exceptions.dart';

abstract class ReciterException implements QuranException {
  @override
  final String message;
  @override
  final String errorCode;

  ReciterException(this.message, this.errorCode);

  @override
  String toString() => 'FetchRecitersException: $message';
}

class FetchRecitersFailedException extends ReciterException {
  FetchRecitersFailedException(super.message, super.errorCode);
}

class FetchAllRecitersFailedException extends ReciterException {
  FetchAllRecitersFailedException(String message)
      : super('Error occurred while fetching all reciters: $message', 'FETCH_ALL_RECITERS_ERROR');
}

class FetchRecitersByIdException extends ReciterException {
  FetchRecitersByIdException(String message)
      : super('Error occurred while fetching reciter by ID: $message', 'FETCH_RECITERS_BY_ID_ERROR');
}

class FetchRecitersByRewayaException extends ReciterException {
  FetchRecitersByRewayaException(String message)
      : super('Error occurred while fetching reciters by rewaya: $message', 'FETCH_RECITERS_BY_REWAYA_ERROR');
}

class FetchRecitersBySurahException extends ReciterException {
  FetchRecitersBySurahException(String message)
      : super('Error occurred while fetching reciters by surah: $message', 'FETCH_RECITERS_BY_SURAH_ERROR');
}

class FetchRecitersByRewayaAndSurahException extends ReciterException {
  FetchRecitersByRewayaAndSurahException(String message)
      : super(
          'Error occurred while fetching reciters by rewaya and surah: $message',
          'FETCH_RECITERS_BY_REWAYA_AND_SURAH_ERROR',
        );
}

class FetchRecitersByLastUpdatedDateException extends ReciterException {
  FetchRecitersByLastUpdatedDateException(String message)
      : super(
          'Error occurred while fetching reciters by last updated date: $message',
          'FETCH_RECITERS_BY_LAST_UPDATED_DATE_ERROR',
        );
}

class SaveRecitersException extends ReciterException {
  SaveRecitersException(String message)
      : super('Error occurred while saving reciters: $message', 'SAVE_RECITERS_ERROR');
}

class FetchAllRecitersException extends ReciterException {
  FetchAllRecitersException(String message)
      : super('Error occurred while fetching all reciters: $message', 'FETCH_ALL_RECITERS_ERROR');
}

class FetchReciterByIdException extends ReciterException {
  FetchReciterByIdException(String message)
      : super('Error occurred while fetching reciter by ID: $message', 'FETCH_RECITER_BY_ID_ERROR');
}

class ClearAllRecitersException extends ReciterException {
  ClearAllRecitersException(String message)
      : super('Error occurred while clearing all reciters: $message', 'CLEAR_ALL_RECITERS_ERROR');
}

class CannotCheckRecitersCachedException extends ReciterException {
  CannotCheckRecitersCachedException(String message)
      : super('Error occurred while checking if reciters are cached: $message', 'CANNOT_CHECK_RECITERS_CACHED_ERROR');
}

class FetchRecitersException extends ReciterException {
  FetchRecitersException(String message)
      : super('Error occurred while fetching reciters: $message', 'FETCH_RECITERS_ERROR');
}

class FetchAudioFileFailedException extends ReciterException {
  FetchAudioFileFailedException(String message)
      : super('Error occurred while fetching audio file: $message', 'FETCH_AUDIO_FILE_ERROR');
}

class CheckSurahExistenceException extends ReciterException {
  CheckSurahExistenceException(String message)
      : super('Error occurred while saving audio file: $message', 'CHECK_SURAH_EXISTENCE_ERROR');
}

class SaveAudioFileException extends ReciterException {
  SaveAudioFileException(String message)
      : super('Error occurred while saving audio file: $message', 'SAVE_AUDIO_FILE_ERROR');
}

class FetchAudioFileException extends ReciterException {
  FetchAudioFileException(String message)
      : super('Error occurred while fetching audio file: $message', 'FETCH_AUDIO_FILE_ERROR');
}

class AudioFileNotFoundInCacheException extends ReciterException {
  AudioFileNotFoundInCacheException() : super('Audio file not found in cache', 'AUDIO_FILE_NOT_FOUND_IN_CACHE_ERROR');
}

class FetchLocalAudioFileException extends ReciterException {
  FetchLocalAudioFileException(String message)
      : super('Audio file not found in local $message', 'AUDIO_FILE_NOT_FOUND_LOCAL_ERROR');
}
