import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mawaqit/src/data/data_source/quran/download_quran_remote_data_source.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mawaqit/src/domain/error/quran_exceptions.dart';
import 'package:mawaqit/src/helpers/directory_helper.dart';

// Mock classes
class MockDio extends Mock implements Dio {}

class MockResponse extends Mock implements Response {}

class MockDirectoryHelper extends Mock implements DirectoryHelper {}

void main() {
  late DownloadQuranRemoteDataSource dataSource;
  late MockDio mockDio;
  const String testAppSupportPath = '/test/app/support';

  setUp(() {
    mockDio = MockDio();
    dataSource = DownloadQuranRemoteDataSource(
      dio: mockDio,
      applicationSupportDirectoryPath: testAppSupportPath,
    );
  });

  group('getRemoteQuranVersion', () {
    test('should return version when the call is successful', () async {
      // Arrange
      final mockResponse = MockResponse();
      when(() => mockResponse.data).thenReturn({'fileName': 'quran_v1.0.0.zip'});
      when(() => mockDio.get(any())).thenAnswer((_) async => mockResponse);

      // Act
      final result = await dataSource.getRemoteQuranVersion();

      // Assert
      expect(result, 'quran_v1.0.0.zip');
      verify(() => mockDio.get('https://mawaqit.github.io/mawaqit-announcements/public/quran/config.json')).called(1);
    });

    test('should throw FetchRemoteQuranVersionException when the call fails', () async {
      // Arrange
      when(() => mockDio.get(any())).thenThrow(Exception('Network error'));

      // Act & Assert
      expect(() => dataSource.getRemoteQuranVersion(), throwsA(isA<FetchRemoteQuranVersionException>()));
    });
  });

  group('downloadQuranWithProgress', () {
    test('should download quran successfully', () async {
      // Arrange
      when(() => mockDio.download(
            any(),
            any(),
            onReceiveProgress: any(named: 'onReceiveProgress'),
            cancelToken: any(named: 'cancelToken'),
          )).thenAnswer((_) async => Response(requestOptions: RequestOptions()));

      // Act
      await dataSource.downloadQuranWithProgress(versionName: 'quran_v1.0.0.zip');

      // Assert
      verify(() => mockDio.download(
            'https://mawaqit.github.io/mawaqit-announcements/public/quran/quran_v1.0.0.zip',
            '$testAppSupportPath/quran_zip/quran_v1.0.0.zip',
            onReceiveProgress: any(named: 'onReceiveProgress'),
            cancelToken: any(named: 'cancelToken'),
          )).called(1);
    });

    test('should throw CancelDownloadException when download is cancelled', () async {
      // Arrange
      when(() => mockDio.download(
            any(),
            any(),
            onReceiveProgress: any(named: 'onReceiveProgress'),
            cancelToken: any(named: 'cancelToken'),
          )).thenThrow(DioException(
        type: DioExceptionType.cancel,
        requestOptions: RequestOptions(),
      ));

      // Act & Assert
      expect(() => dataSource.downloadQuranWithProgress(versionName: 'quran_v1.0.0.zip'),
          throwsA(isA<CancelDownloadException>()));
    });

    test('should throw UnknownException for other errors', () async {
      // Arrange
      when(() => mockDio.download(
            any(),
            any(),
            onReceiveProgress: any(named: 'onReceiveProgress'),
            cancelToken: any(named: 'cancelToken'),
          )).thenThrow(Exception('Unknown error'));

      // Act & Assert
      expect(() => dataSource.downloadQuranWithProgress(versionName: 'quran_v1.0.0.zip'),
          throwsA(isA<UnknownException>()));
    });
  });

  test('cancelDownload should cancel the current download', () {
    // Arrange
    final cancelToken = CancelToken();
    dataSource = DownloadQuranRemoteDataSource(
      dio: mockDio,
      applicationSupportDirectoryPath: testAppSupportPath,
      cancelToken: cancelToken,
    );

    // Act
    dataSource.cancelDownload();

    // Assert
    expect(cancelToken.isCancelled, true);
    expect(dataSource.cancelToken, isNot(cancelToken));
  });
}
