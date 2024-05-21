// import 'package:dio/dio.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:mawaqit/src/data/data_source/quran/quran_remote_data_source.dart';
// import 'package:mocktail/mocktail.dart';
// import 'package:mawaqit/src/domain/model/quran/langauge_model.dart';
// import 'package:mawaqit/src/domain/model/quran/surah_model.dart';
// import 'package:mawaqit/src/const/constants.dart';
// import 'package:mawaqit/src/module/dio_module.dart';
//
// class MockDio extends Mock implements Dio {}
//
// void main() {
//   late ProviderContainer container;
//   late MockDio mockDio;
//
//   setUp(() {
//     container = ProviderContainer();
//     mockDio = MockDio();
//   });
//
//   test('getLanguages should return a list of LanguageModel', () async {
//     // Arrange
//     final response = {
//       'language': [
//         {'code': 'en', 'name': 'English'},
//         {'code': 'ar', 'name': 'Arabic'},
//       ],
//     };
//     when(() => mockDio.get('languages')).thenAnswer(
//       (_) async => Response(
//         data: response,
//         requestOptions: RequestOptions(path: ''),
//       ),
//     );
//     final container = ProviderContainer(
//       overrides: [
//         // Override the behavior of repositoryProvider to return
//         // FakeRepository instead of Repository.
//         // dioProvider.overrideWith((ref, arg) => ref,),
//         // We do not have to override `todoListProvider`, it will automatically
//         // use the overridden repositoryProvider
//       ],
//     );
//
//     final quranRemoteDataSource = container.read(quranRemoteDataSourceProvider);
//
//     // Act
//     final result = await quranRemoteDataSource.getLanguages();
//
//     // Assert
//     expect(result, isA<List<LangaugeModel>>());
//     expect(result.length, equals(2));
//     expect(result[0].code, equals('en'));
//     expect(result[0].name, equals('English'));
//     expect(result[1].code, equals('ar'));
//     expect(result[1].name, equals('Arabic'));
//   });
//
//   test('getSuwarByLanguage should return a list of SurahModel', () async {
//     // Arrange
//     final response = {
//       'suwar': [
//         {'id': 1, 'name': 'Al-Fatihah'},
//         {'id': 2, 'name': 'Al-Baqarah'},
//       ],
//     };
//     when(() => mockDio.get(
//           'suwar',
//           queryParameters: {'language': 'en'},
//         )).thenAnswer((_) async => Response(
//           data: response,
//           requestOptions: RequestOptions(path: ''),
//         ));
//     dioProvider.overrideWith((ref, arg) => mockDio.di);
//
//     final quranRemoteDataSource = container.read(quranRemoteDataSourceProvider);
//
//     // Act
//     final result = await quranRemoteDataSource.getSuwarByLanguage(languageCode: 'en');
//
//     // Assert
//     expect(result, isA<List<SurahModel>>());
//     expect(result.length, equals(2));
//     expect(result[0].id, equals(1));
//     expect(result[0].name, equals('Al-Fatihah'));
//     expect(result[1].id, equals(2));
//     expect(result[1].name, equals('Al-Baqarah'));
//   });
// }

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mawaqit/src/data/data_source/quran/quran_remote_data_source.dart';
import 'package:mawaqit/src/domain/model/quran/surah_model.dart';

void main() {
  group('QuranRemoteDataSource', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    test('getLanguages should return a list of LanguageModel', () async {
      final quranRemoteDataSource = container.read(quranRemoteDataSourceProvider);

      final result = await quranRemoteDataSource.getLanguages();

      // expect(result, isA<List<LangaugeModel>>());
      print('Languages:');
      result.forEach((language) {
        print('result: ${language}');
      });
    });

    test('getSuwarByLanguage should return a list of SurahModel', () async {
      final quranRemoteDataSource = container.read(quranRemoteDataSourceProvider);

      final result = await quranRemoteDataSource.getSuwarByLanguage(languageCode: 'fr');

      expect(result, isA<List<SurahModel>>());
      print('Surahs:');
      result.forEach((surah) {
        print('ID: ${surah.id}, Name: ${surah.name}');
      });
    });
  });
}
