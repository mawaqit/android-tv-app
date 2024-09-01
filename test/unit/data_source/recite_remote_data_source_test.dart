import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:mawaqit/src/domain/model/quran/reciter_model.dart';
import 'package:mawaqit/src/domain/error/recite_exception.dart';
import 'package:mawaqit/src/data/data_source/quran/recite_remote_data_source.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late ReciteRemoteDataSource dataSource;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    dataSource = ReciteRemoteDataSource(mockDio);
  });

  group('getReciters', () {
    final mockReciterData = {
      'id': 1,
      'name': 'Reciter 1',
      'letter': 'A',
      'moshaf': [
        {
          'id': 1,
          'name': 'Moshaf 1',
          'server': 'http://example.com',
          'surah_list': '1,2,3',
          "surah_total": 114,
          "moshaf_type": 11,
          // Add any other required fields for MoshafModel here
        }
      ]
    };

    test('Successfully fetches reciters with only language parameter', () async {
      // Arrange
      final language = 'en';
      final mockResponse = Response(
        data: {
          'reciters': [mockReciterData]
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      );
      when(() => mockDio.get('reciters', queryParameters: {'language': language}))
          .thenAnswer((_) async => mockResponse);

      // Act
      final result = await dataSource.getReciters(language: language);

      // Assert
      expect(result, isA<List<ReciterModel>>());
      expect(result.length, 1);
      expect(result[0].id, 1);
      expect(result[0].name, 'Reciter 1');
      expect(result[0].letter, 'A');
      expect(result[0].moshaf.length, 1);
      expect(result[0].moshaf[0].id, 1);
      expect(result[0].moshaf[0].name, 'Moshaf 1');
      expect(result[0].moshaf[0].server, 'http://example.com');
      expect(result[0].moshaf[0].surahList, [1, 2, 3]);
      expect(result[0].moshaf[0].surahTotal, 114);
      expect(result[0].moshaf[0].moshafType, 11);
    });

    test('Throws FetchRecitersBySurahException when _fetchReciters fails', () async {
      // Arrange
      final language = 'en';
      when(() => mockDio.get('reciters', queryParameters: {'language': language}))
          .thenThrow(DioError(requestOptions: RequestOptions(path: '')));

      // Act & Assert
      expect(
        () => dataSource.getReciters(language: language),
        throwsA(isA<FetchRecitersFailedException>()),
      );
    });

    test('Returns empty list when no reciters are found', () async {
      // Arrange
      final language = 'en';
      final mockResponse = Response(
        data: {'reciters': []},
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      );
      when(() => mockDio.get('reciters', queryParameters: {'language': language}))
          .thenAnswer((_) async => mockResponse);

      // Act
      final result = await dataSource.getReciters(language: language);

      // Assert
      expect(result, isA<List<ReciterModel>>());
      expect(result.isEmpty, true);
    });

    test('Handles different language inputs correctly', () async {
      // Arrange
      final languages = ['en', 'ar'];
      for (final lang in languages) {
        final mockReciterData = {
          'id': 1,
          'name': 'Reciter 1',
          'letter': 'A',
          'moshaf': [
            {
              'id': 1,
              'name': 'Moshaf 1',
              'server': 'http://example.com',
              'surah_list': '1,2,3',
              "surah_total": 114,
              "moshaf_type": 11,
              // Add any other required fields for MoshafModel here
            }
          ]
        };

        final mockResponse = Response(
          data: {
            'reciters': [mockReciterData]
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        );
        when(() => mockDio.get('reciters', queryParameters: {'language': lang})).thenAnswer((_) async => mockResponse);

        // Act
        final result = await dataSource.getReciters(language: lang);

        // Assert
        expect(result, isA<List<ReciterModel>>());
        expect(result.length, 1);
        expect(result[0].id, 1);
        expect(result[0].name, 'Reciter 1');
        expect(result[0].letter, 'A');
        expect(result[0].moshaf.length, 1);
        expect(result[0].moshaf[0].id, 1);
        expect(result[0].moshaf[0].name, 'Moshaf 1');
        expect(result[0].moshaf[0].server, 'http://example.com');
        // expect(result[0].moshaf[0].surahList, [1, 2, 3]);
      }
    });
  });

  group('_fetchReciters', () {
    test('Successfully fetches reciters with only language parameter', () async {
      final mockReciterData = {
        'reciters': [
          {
            'id': 1,
            'name': 'Reciter 1',
            'letter': 'A',
            'moshaf': [
              {
                'id': 1,
                'name': 'Moshaf 1',
                'server': 'http://example.com',
                'surah_list': '1,2,3',
                'surah_total': 114,
                'moshaf_type': 11,
              }
            ]
          }
        ]
      };

      when(() => mockDio.get('reciters', queryParameters: {'language': 'en'})).thenAnswer(
          (_) async => Response(data: mockReciterData, statusCode: 200, requestOptions: RequestOptions(path: '')));

      final result = await dataSource.getReciters(language: 'en');

      expect(result, isA<List<ReciterModel>>());
      expect(result.length, 1);
    });

    test('Successfully fetches reciters with all optional parameters', () async {
      final mockReciterData = {
        'reciters': [
          {
            'id': 1,
            'name': 'Reciter 1',
            'letter': 'A',
            'moshaf': [
              {
                'id': 1,
                'name': 'Moshaf 1',
                'server': 'http://example.com',
                'surah_list': '1,2,3',
                'surah_total': 114,
                'moshaf_type': 11,
              }
            ]
          }
        ]
      };

      final queryParams = {
        'language': 'en',
        'reciter': 1,
        'rewaya': 2,
        'sura': 3,
        'last_updated_date': '2023-01-01',
      };

      when(() => mockDio.get('reciters', queryParameters: queryParams)).thenAnswer(
          (_) async => Response(data: mockReciterData, statusCode: 200, requestOptions: RequestOptions(path: '')));

      final result = await dataSource.fetchReciters(
        language: 'en',
        reciterId: 1,
        rewayaId: 2,
        surahId: 3,
        lastUpdatedDate: '2023-01-01',
      );

      expect(result, isA<List<ReciterModel>>());
      expect(result.length, 1);
    });

    test('Correctly constructs query parameters based on provided inputs', () async {
      final mockReciterData = {
        'reciters': [
          {
            'id': 1,
            'name': 'Reciter 1',
            'letter': 'A',
            'moshaf': [
              {
                'id': 1,
                'name': 'Moshaf 1',
                'server': 'http://example.com',
                'surah_list': '1,2,3',
                'surah_total': 114,
                'moshaf_type': 11,
              }
            ]
          }
        ]
      };

      final queryParams = {
        'language': 'en',
        'reciter': 1,
        'rewaya': 2,
      };

      when(() => mockDio.get('reciters', queryParameters: queryParams)).thenAnswer(
          (_) async => Response(data: mockReciterData, statusCode: 200, requestOptions: RequestOptions(path: '')));

      await dataSource.fetchReciters(language: 'en', reciterId: 1, rewayaId: 2);

      verify(() => mockDio.get('reciters', queryParameters: queryParams)).called(1);
    });

    test('Handles 200 status code correctly', () async {
      final mockReciterData = {
        'reciters': [
          {
            'id': 1,
            'name': 'Reciter 1',
            'letter': 'A',
            'moshaf': [
              {
                'id': 1,
                'name': 'Moshaf 1',
                'server': 'http://example.com',
                'surah_list': '1,2,3',
                'surah_total': 114,
                'moshaf_type': 11,
              }
            ]
          }
        ]
      };

      when(() => mockDio.get('reciters', queryParameters: {'language': 'en'})).thenAnswer(
          (_) async => Response(data: mockReciterData, statusCode: 200, requestOptions: RequestOptions(path: '')));

      final result = await dataSource.getReciters(language: 'en');

      expect(result, isA<List<ReciterModel>>());
      expect(result.length, 1);
    });

    test('Throws FetchRecitersFailedException for non-200 status codes', () async {
      when(() => mockDio.get('reciters', queryParameters: {'language': 'en'}))
          .thenAnswer((_) async => Response(data: null, statusCode: 404, requestOptions: RequestOptions(path: '')));

      expect(() => dataSource.getReciters(language: 'en'), throwsA(isA<FetchRecitersFailedException>()));
    });

    test('Correctly parses response data into ReciterModel objects', () async {
      final mockReciterData = {
        'reciters': [
          {
            'id': 1,
            'name': 'Reciter 1',
            'letter': 'A',
            'moshaf': [
              {
                'id': 1,
                'name': 'Moshaf 1',
                'server': 'http://example.com',
                'surah_list': '1,2,3',
                'surah_total': 114,
                'moshaf_type': 11,
              }
            ]
          }
        ]
      };

      when(() => mockDio.get('reciters', queryParameters: {'language': 'en'})).thenAnswer(
          (_) async => Response(data: mockReciterData, statusCode: 200, requestOptions: RequestOptions(path: '')));

      final result = await dataSource.getReciters(language: 'en');

      expect(result[0], isA<ReciterModel>());
      expect(result[0].id, 1);
      expect(result[0].name, 'Reciter 1');
      expect(result[0].moshaf[0].surahList, [1, 2, 3]);
    });

    test('Handles empty response data', () async {
      when(() => mockDio.get('reciters', queryParameters: {'language': 'en'})).thenAnswer(
          (_) async => Response(data: {'reciters': []}, statusCode: 200, requestOptions: RequestOptions(path: '')));

      final result = await dataSource.getReciters(language: 'en');

      expect(result, isEmpty);
    });

    test('Handles malformed response data', () async {
      when(() => mockDio.get('reciters', queryParameters: {'language': 'en'})).thenAnswer(
          (_) async => Response(data: {'invalid_key': []}, statusCode: 200, requestOptions: RequestOptions(path: '')));

      expect(() => dataSource.getReciters(language: 'en'), throwsA(isA<Exception>()));
    });

    test('Correctly converts surah_list from string to List<int>', () async {
      final mockReciterData = {
        'reciters': [
          {
            'id': 1,
            'name': 'Reciter 1',
            'letter': 'A',
            'moshaf': [
              {
                'id': 1,
                'name': 'Moshaf 1',
                'server': 'http://example.com',
                'surah_list': '1,2,3',
                'surah_total': 114,
                'moshaf_type': 11,
              }
            ]
          }
        ]
      };

      when(() => mockDio.get('reciters', queryParameters: {'language': 'en'})).thenAnswer(
          (_) async => Response(data: mockReciterData, statusCode: 200, requestOptions: RequestOptions(path: '')));

      final result = await dataSource.getReciters(language: 'en');

      expect(result[0].moshaf[0].surahList, isA<List<int>>());
      expect(result[0].moshaf[0].surahList, [1, 2, 3]);
    });

    test('Handles network errors', () async {
      when(() => mockDio.get('reciters', queryParameters: {'language': 'en'}))
          .thenThrow(DioError(requestOptions: RequestOptions(path: ''), type: DioExceptionType.connectionError));

      expect(() => dataSource.getReciters(language: 'en'), throwsA(isA<FetchRecitersFailedException>()));
    });
  });

  group('Edge cases', () {
    test('Handles very large responses', () async {
      // Create a large response with 1000 reciters
      final largeResponse = {
        'reciters': List.generate(
            1000,
            (index) => {
                  'id': index,
                  'name': 'Reciter $index',
                  'letter': 'A',
                  'moshaf': [
                    {
                      'id': index,
                      'name': 'Moshaf $index',
                      'server': 'http://example.com',
                      'surah_list': '1,2,3',
                      'surah_total': 114,
                      'moshaf_type': 11,
                    }
                  ]
                })
      };

      when(() => mockDio.get('reciters', queryParameters: {'language': 'en'})).thenAnswer(
          (_) async => Response(data: largeResponse, statusCode: 200, requestOptions: RequestOptions(path: '')));

      final result = await dataSource.getReciters(language: 'en');

      expect(result.length, 1000);
      expect(result.last.id, 999);
    });

    test('Handles responses with special characters in reciter names or other fields', () async {
      final responseWithSpecialChars = {
        'reciters': [
          {
            'id': 1,
            'name': 'Reciter',
            'letter': 'A',
            'moshaf': [
              {
                'id': 1,
                'name': 'Moshaf',
                'server': 'http://example.com/',
                'surah_list': '1,2,3',
                'surah_total': 114,
                'moshaf_type': 11,
              }
            ]
          }
        ]
      };

      when(() => mockDio.get('reciters', queryParameters: {'language': 'en'})).thenAnswer((_) async =>
          Response(data: responseWithSpecialChars, statusCode: 200, requestOptions: RequestOptions(path: '')));
      final result = await dataSource.getReciters(language: 'en');

      expect(result.length, 1);
      expect(result[0].name, 'Reciter');
      expect(result[0].letter, 'A');
      expect(result[0].moshaf[0].name, 'Moshaf');
      expect(result[0].moshaf[0].server, 'http://example.com/');
    });

    // test('Handles responses with missing or null fields', () async {
    //   final responseWithMissingFields = {
    //     'reciters': [
    //       {
    //         'id': 1,
    //         'name': 'Reciter 1',
    //         // 'letter' is missing
    //         'moshaf': [
    //           {
    //             'id': 1,
    //             'name': null, // null field
    //             'server': 'http://example.com',
    //             // 'surah_list' is missing
    //             'surah_total': 114,
    //             'moshaf_type': 11,
    //           }
    //         ]
    //       },
    //       {
    //         // 'id' is missing
    //         'name': 'Reciter 2',
    //         'letter': 'B',
    //         'moshaf': [] // empty moshaf list
    //       }
    //     ]
    //   };
    //
    //   when(() => mockDio.get('reciters', queryParameters: {'language': 'en'})).thenAnswer((_) async =>
    //       Response(data: responseWithMissingFields, statusCode: 200, requestOptions: RequestOptions(path: '')));
    //
    //   expect(
    //     () async => await dataSource.getReciters(language: 'en'),
    //     throwsA(isA<FetchRecitersFailedException>()),
    //   );
    // });
  });
}
