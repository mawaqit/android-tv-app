import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mawaqit/src/data/data_source/quran/download_quran_remote_data_source.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

void main() {
  group('DownloadQuranDataSource', () {
    late DownloadQuranRemoteDataSource dataSource;
    late MockDio mockDio;

    setUp(() {
      mockDio = MockDio();
      dataSource = DownloadQuranRemoteDataSource(
        dio: mockDio,
        applicationSupportDirectoryPath: '/path/to/app/support',
      );
    });

    test('getRemoteQuranVersion should return the version from config.json', () async {
      final response = Response(
        requestOptions: RequestOptions(path: ''),
        data: {'fileName': 'quran_v1.0.0.zip'},
      );
      when(() => mockDio.get(any())).thenAnswer((_) async => response);

      final version = await dataSource.getRemoteQuranVersion();

      expect(version, equals('quran_v1.0.0.zip'));
      verify(() => mockDio.get(any())).called(1);
    });

    test('getRemoteQuranVersion should throw an exception on error', () async {
      when(() => mockDio.get(any())).thenThrow(Exception('Network error'));

      expect(
        () => dataSource.getRemoteQuranVersion(),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Error occurred while fetching remote quran version'),
        )),
      );
      verify(() => mockDio.get(any())).called(1);
    });

    test('downloadQuranWithProgress should download the quran zip file', () async {
      when(() => mockDio.download(any(), any(), onReceiveProgress: any(named: 'onReceiveProgress')))
          .thenAnswer((_) async => Response(requestOptions: RequestOptions(path: '')));

      await dataSource.downloadQuranWithProgress(versionName: 'quran_v1.0.0.zip');

      verify(() => mockDio.download(
            'https://mawaqit.github.io/mawaqit-announcements/public/quran/quran_v1.0.0.zip',
            '/path/to/app/support/quran_zip/quran_v1.0.0.zip',
            onReceiveProgress: any(named: 'onReceiveProgress'),
            cancelToken: any(named: 'cancelToken'),
          )).called(1);
    });

    test('downloadQuranWithProgress should throw an exception on error', () async {
      when(() => mockDio.download(any(), any(), onReceiveProgress: any(named: 'onReceiveProgress')))
          .thenThrow(Exception('Network error'));

      expect(
        () => dataSource.downloadQuranWithProgress(versionName: 'quran_v1.0.0.zip'),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Error occurred while downloading quran'),
        )),
      );
      verify(() => mockDio.download(
            'https://mawaqit.github.io/mawaqit-announcements/public/quran/quran_v1.0.0.zip',
            '/path/to/app/support/quran_zip/quran_v1.0.0.zip',
            onReceiveProgress: any(named: 'onReceiveProgress'),
            cancelToken: any(named: 'cancelToken'),
          )).called(1);
    });
  });
}
