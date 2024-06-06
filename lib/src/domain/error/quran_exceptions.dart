// exceptions.dart

abstract class QuranException implements Exception {
  final String message;
  final String errorCode;

  QuranException(this.message, this.errorCode);

  @override
  String toString() => 'Error ($errorCode): $message';
}

// DownloadQuranRemoteDataSource exceptions

class FetchRemoteQuranVersionException extends QuranException {
  FetchRemoteQuranVersionException(String message)
      : super('Error occurred while fetching remote Quran version: $message', 'FETCH_REMOTE_QURAN_VERSION_ERROR');
}

class DownloadQuranException extends QuranException {
  DownloadQuranException(String message)
      : super('Error occurred while downloading Quran: $message', 'DOWNLOAD_QURAN_ERROR');
}

class CancelDownloadException extends QuranException {
  CancelDownloadException() : super('Download cancelled', 'CANCEL_DOWNLOAD_ERROR');
}

// DownloadQuranLocalDataSource exceptions

class SaveSvgFilesException extends QuranException {
  SaveSvgFilesException(String message)
      : super('Error occurred while saving SVG files: $message', 'SAVE_SVG_FILES_ERROR');
}

class DeleteExistingSvgFilesException extends QuranException {
  DeleteExistingSvgFilesException(String message)
      : super('Error occurred while deleting existing SVG files: $message', 'DELETE_EXISTING_SVG_FILES_ERROR');
}

class DeleteZipFileException extends QuranException {
  DeleteZipFileException(String message)
      : super('Error occurred while deleting zip file: $message', 'DELETE_ZIP_FILE_ERROR');
}

class ExtractZipFileException extends QuranException {
  ExtractZipFileException(String message)
      : super('Error occurred while extracting zip file: $message', 'EXTRACT_ZIP_FILE_ERROR');
}

class CreateDirectoryException extends QuranException {
  CreateDirectoryException(String message)
      : super('Error occurred while creating directory: $message', 'CREATE_DIRECTORY_ERROR');
}

class FileNotFOUNDException extends QuranException {
  FileNotFOUNDException(String message) : super('File not found: $message', 'FILE_NOT_FOUND_ERROR');
}

class InvalidZipFileException extends QuranException {
  InvalidZipFileException(String message) : super('Invalid zip file: $message', 'INVALID_ZIP_FILE_ERROR');
}

class ZipFileAlreadyExtractedException extends QuranException {
  ZipFileAlreadyExtractedException(String message)
      : super('Zip file already extracted: $message', 'ZIP_FILE_ALREADY_EXTRACTED_ERROR');
}

class UnknownException extends QuranException {
  UnknownException(String message) : super('Unknown error: $message', 'UNKNOWN_ERROR');
}
