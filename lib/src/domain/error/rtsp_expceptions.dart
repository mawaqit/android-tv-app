abstract class RTSPCameraException implements Exception {
  final String message;
  final String errorCode;

  RTSPCameraException(this.message, this.errorCode);

  @override
  String toString() => 'Error ($errorCode): $message';
}

class RTSPInitializationException extends RTSPCameraException {
  RTSPInitializationException(String message)
      : super('Error during RTSP initialization: $message', 'RTSP_INITIALIZATION_ERROR');
}

class RTSPToggleException extends RTSPCameraException {
  RTSPToggleException(String message)
      : super('Error toggling RTSP camera: $message', 'RTSP_TOGGLE_ERROR');
}

class InvalidRTSPURLException extends RTSPCameraException {
  InvalidRTSPURLException(String message)
      : super('Invalid RTSP URL: $message', 'INVALID_RTSP_URL_ERROR');
}

class YouTubeVideoIdExtractionException extends RTSPCameraException {
  YouTubeVideoIdExtractionException(String message)
      : super('Error extracting YouTube video ID: $message', 'YOUTUBE_VIDEO_ID_EXTRACTION_ERROR');
}

class RTSPStreamUpdateException extends RTSPCameraException {
  RTSPStreamUpdateException(String message)
      : super('Error updating RTSP stream: $message', 'RTSP_STREAM_UPDATE_ERROR');
}

class RTSPUnknownException extends RTSPCameraException {
  RTSPUnknownException(String message)
      : super('Unknown RTSP error: $message', 'RTSP_UNKNOWN_ERROR');
}
