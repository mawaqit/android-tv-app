/// Base exception class for all livestream-related exceptions
abstract class LiveStreamException implements Exception {
  final String message;
  final String errorCode;

  LiveStreamException(this.message, this.errorCode);

  @override
  String toString() => 'Error ($errorCode): $message';
}

/// Exception thrown when validating or initializing a livestream
class LiveStreamInitializationException extends LiveStreamException {
  LiveStreamInitializationException(String message)
      : super('Error during livestream initialization: $message', 'LIVESTREAM_INITIALIZATION_ERROR');
}

/// Exception thrown when a livestream URL is invalid
class InvalidStreamUrlException extends LiveStreamException {
  InvalidStreamUrlException(String message) : super('Invalid stream URL: $message', 'INVALID_STREAM_URL_ERROR');
}

/// Exception thrown when a stream URL is not provided
class StreamUrlNotProvidedException extends LiveStreamException {
  StreamUrlNotProvidedException() : super('No stream URL provided', 'STREAM_URL_NOT_PROVIDED_ERROR');
}

/// Exception thrown when toggling livestream settings
class LiveStreamToggleException extends LiveStreamException {
  LiveStreamToggleException(String message) : super('Error toggling livestream: $message', 'LIVESTREAM_TOGGLE_ERROR');
}

/// Exception thrown when updating a livestream
class LiveStreamUpdateException extends LiveStreamException {
  LiveStreamUpdateException(String message) : super('Error updating livestream: $message', 'LIVESTREAM_UPDATE_ERROR');
}

/// Exception thrown when an unknown livestream error occurs
class LiveStreamUnknownException extends LiveStreamException {
  LiveStreamUnknownException(String message) : super('Unknown livestream error: $message', 'LIVESTREAM_UNKNOWN_ERROR');
}
