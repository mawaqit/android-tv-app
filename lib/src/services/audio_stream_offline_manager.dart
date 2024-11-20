import 'dart:typed_data';

import 'package:just_audio/just_audio.dart';

class JustAudioBytesSource extends StreamAudioSource {
  final ByteData _buffer;

  JustAudioBytesSource(this._buffer) : super(tag: 'MyAudioSource');

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    // Convert ByteData to Uint8List
    final Uint8List uint8List = _buffer.buffer.asUint8List();

    // Calculate start and end positions
    final int startPosition = start ?? 0;
    final int endPosition = end ?? uint8List.length;

    // Returning the stream audio response with the parameters
    return StreamAudioResponse(
      sourceLength: uint8List.length,
      contentLength: endPosition - startPosition,
      offset: startPosition,
      stream: Stream.fromIterable([uint8List.sublist(startPosition, endPosition)]),
      contentType: 'audio/mp3',
    );
  }
}
