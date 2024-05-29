abstract class MosqueFailure implements Exception {
  final String errorMessage;
  final String errorCode;

  const MosqueFailure({
    required this.errorMessage,
    required this.errorCode,
  });
}

class MosqueNotFoundFailure extends MosqueFailure {
  const MosqueNotFoundFailure()
      : super(
          errorMessage: 'Mosque not found',
          errorCode: 'MOSQUE_IS_NOT_FOUND',
        );
}
