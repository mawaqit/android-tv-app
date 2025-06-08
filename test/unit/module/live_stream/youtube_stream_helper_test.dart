import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mawaqit/src/helpers/live_stream/youtube_stream_helper.dart';
import 'package:mawaqit/src/domain/error/live_stream_exceptions.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

// Mock classes
class MockYoutubePlayerController extends Mock implements YoutubePlayerController {}

class MockYouTubeExplode extends Mock implements YoutubeExplode {}

class MockVideoClient extends Mock implements VideoClient {}

class MockVideo extends Mock implements Video {}

void main() {
  late YouTubeStreamHelper youtubeHelper;
  late MockYouTubeExplode mockYouTubeExplode;
  late MockVideoClient mockVideoClient;

  setUp(() {
    youtubeHelper = YouTubeStreamHelper();
    mockYouTubeExplode = MockYouTubeExplode();
    mockVideoClient = MockVideoClient();

    // Set up the Mocktail stub for methods we'll use in tests
    when(() => mockYouTubeExplode.videos).thenReturn(mockVideoClient);
    when(() => mockYouTubeExplode.close()).thenAnswer((_) async {});
  });

  group('extractVideoId', () {
    test('should extract video ID from standard YouTube URL', () {
      // Arrange
      const url = 'https://www.youtube.com/watch?v=dQw4w9WgXcQ';

      // Act
      final result = youtubeHelper.extractVideoId(url);

      // Assert
      expect(result, 'dQw4w9WgXcQ');
    });

    test('should extract video ID from YouTube short URL', () {
      // Arrange
      const url = 'https://youtu.be/dQw4w9WgXcQ';

      // Act
      final result = youtubeHelper.extractVideoId(url);

      // Assert
      expect(result, 'dQw4w9WgXcQ');
    });

    test('should extract video ID from YouTube live URL', () {
      // Arrange
      const url = 'https://youtube.com/live/dQw4w9WgXcQ';

      // Act
      final result = youtubeHelper.extractVideoId(url);

      // Assert
      expect(result, 'dQw4w9WgXcQ');
    });

    test('should return null for invalid URL', () {
      // Arrange
      const url = 'https://invalid-url.com';

      // Act
      final result = youtubeHelper.extractVideoId(url);

      // Assert
      expect(result, null);
    });
  });

  group('initializeController', () {
    test('should create and return a YoutubePlayerController', () {
      // Arrange
      const videoId = 'dQw4w9WgXcQ';

      // Act
      final controller = youtubeHelper.initializeController(videoId);

      // Assert
      expect(controller, isA<YoutubePlayerController>());
      expect(youtubeHelper.controller, controller);
    });
  });

  group('processYouTubeUrl', () {
    test('should throw exception for invalid YouTube URL', () async {
      // Arrange
      const invalidUrl = 'https://invalid-url.com';

      // Act & Assert
      expect(
        () => youtubeHelper.processYouTubeUrl(invalidUrl),
        throwsA(isA<InvalidStreamUrlException>()),
      );
    });

    test('should throw exception if video is not a live stream', () async {
      // Arrange
      const validUrl = 'https://www.youtube.com/watch?v=dQw4w9WgXcQ';
      final mockVideo = MockVideo();
      when(() => mockVideo.isLive).thenReturn(false);
      when(() => mockVideoClient.get(any())).thenAnswer((_) async => mockVideo);

      // Act & Assert
      expect(
        () => youtubeHelper.processYouTubeUrl(validUrl),
        throwsA(isA<InvalidStreamUrlException>()),
      );
    });
  });

  group('dispose', () {
    test('should dispose controller and set it to null', () async {
      // Arrange
      const videoId = 'dQw4w9WgXcQ';
      final controller = youtubeHelper.initializeController(videoId);

      // Act
      await youtubeHelper.dispose();

      // Assert
      expect(youtubeHelper.controller, isNull);
    });
  });
}
