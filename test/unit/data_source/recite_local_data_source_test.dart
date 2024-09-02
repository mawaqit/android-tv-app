import 'package:flutter_test/flutter_test.dart';
import 'package:mawaqit/src/data/data_source/quran/reciter_local_data_source.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mawaqit/src/domain/error/recite_exception.dart';
import 'package:mawaqit/src/domain/model/quran/moshaf_model.dart';
import 'package:mawaqit/src/domain/model/quran/reciter_model.dart';
import 'package:mocktail/mocktail.dart';

class MockHiveBox extends Mock implements Box<ReciterModel> {}
class MockHiveFavoriteBox extends Mock implements Box<int> {}

void main() {
  late ReciteLocalDataSource dataSource;
  late MockHiveBox mockBox;
  late MockHiveFavoriteBox mockFavoriteBox;

  setUp(() {
    mockBox = MockHiveBox();
    mockFavoriteBox = MockHiveFavoriteBox();
    dataSource = ReciteLocalDataSource(mockBox, mockFavoriteBox);
  });

  MoshafModel createMoshaf(int id, List<int> surahList) {
    return MoshafModel(id, 'Moshaf $id', 'http://example.com', 114, 1, surahList);
  }

  ReciterModel createReciter(int id, List<int> surahList) {
    return ReciterModel(id, 'Reciter $id', 'A', [createMoshaf(1, surahList)]);
  }

  group('saveReciters', () {
    test('Happy path: Successfully saves list of reciters', () async {
      final reciters = [
        createReciter(1, [1, 2, 3]),
        createReciter(2, [1, 2, 3])
      ];
      when(() => mockBox.putAll(any<Map<dynamic, ReciterModel>>())).thenAnswer((_) => Future.value());

      await dataSource.saveReciters(reciters);

      verify(() => mockBox.putAll(any<Map<dynamic, ReciterModel>>())).called(1);
    });

    test('Handles empty list of reciters', () async {
      await dataSource.saveReciters([]);

      verifyNever(() => mockBox.putAll(any<Map<dynamic, ReciterModel>>()));
    });

    test('Handles very large list of reciters', () async {
      final largeList = List.generate(10000, (index) => createReciter(index, [1, 2, 3]));
      when(() => mockBox.putAll(any<Map<dynamic, ReciterModel>>())).thenAnswer((_) async => Future.value());

      await dataSource.saveReciters(largeList);

      verify(() => mockBox.putAll(any<Map<dynamic, ReciterModel>>())).called(1);
    });

    test('Handles reciters with duplicate IDs', () async {
      final reciters = [
        createReciter(1, [1, 2, 3]),
        createReciter(1, [4, 5, 6])
      ];
      when(() => mockBox.putAll(any<Map<dynamic, ReciterModel>>())).thenAnswer((_) => Future.value());

      await dataSource.saveReciters(reciters);

      verify(() => mockBox.putAll(any<Map<dynamic, ReciterModel>>())).called(1);
    });

    test('Throws SaveRecitersException when Hive box is full', () async {
      final reciters = [
        createReciter(1, [1, 2, 3])
      ];
      when(() => mockBox.putAll(any<Map<dynamic, ReciterModel>>())).thenThrow(HiveError('Box is full'));

      expect(() => dataSource.saveReciters(reciters), throwsA(isA<SaveRecitersException>()));
    });
  });

  group('getReciters', () {
    test('Happy path: Successfully retrieves list of reciters', () async {
      final reciters = [
        createReciter(1, [1, 2, 3]),
        createReciter(2, [1, 2, 3])
      ];
      when(() => mockBox.values).thenReturn(reciters);

      final result = await dataSource.getReciters();

      expect(result, equals(reciters));
    });

    test('Handles empty Hive box', () async {
      when(() => mockBox.values).thenReturn([]);

      final result = await dataSource.getReciters();

      expect(result, isEmpty);
    });

    test('Handles very large number of reciters', () async {
      final largeList = List.generate(10000, (index) => createReciter(index, [1, 2, 3]));
      when(() => mockBox.values).thenReturn(largeList);

      final result = await dataSource.getReciters();

      expect(result.length, equals(10000));
    });

    test('Throws FetchRecitersException on corrupted data', () async {
      when(() => mockBox.values).thenThrow(HiveError('Corrupted data'));

      expect(() => dataSource.getReciters(), throwsA(isA<FetchRecitersException>()));
    });
  });

  group('getReciterBySurah', () {
    test('Happy path: Successfully retrieves reciters for a given surah', () async {
      final reciters = [
        createReciter(1, [1, 2, 3]),
        createReciter(2, [2, 3, 4]),
        createReciter(3, [3, 4, 5]),
      ];
      when(() => mockBox.values).thenReturn(reciters);

      final result = await dataSource.getReciterBySurah(3);

      expect(result.length, equals(3));
      expect(result.map((r) => r.id), containsAll([1, 2, 3]));
    });

    test('Handles invalid surah ID (negative number)', () async {
      when(() => mockBox.values).thenReturn([]);

      final result = await dataSource.getReciterBySurah(-1);

      expect(result, isEmpty);
    });

    test('Handles invalid surah ID (larger than total number of surahs)', () async {
      when(() => mockBox.values).thenReturn([]);

      final result = await dataSource.getReciterBySurah(115); // Assuming 114 surahs in total

      expect(result, isEmpty);
    });

    test('Handles no reciters found for the given surah ID', () async {
      final reciters = [
        createReciter(1, [1, 2, 3])
      ];
      when(() => mockBox.values).thenReturn(reciters);

      final result = await dataSource.getReciterBySurah(4);

      expect(result, isEmpty);
    });

    test('Handles all reciters having the given surah ID', () async {
      final reciters = [
        createReciter(1, [1, 2, 3]),
        createReciter(2, [1, 2, 3]),
        createReciter(3, [1, 2, 3]),
      ];
      when(() => mockBox.values).thenReturn(reciters);

      final result = await dataSource.getReciterBySurah(2);

      expect(result.length, equals(3));
      expect(result.map((r) => r.id), containsAll([1, 2, 3]));
    });

    test('Handles surah ID existing in some moshaf but not others for the same reciter', () async {
      final reciter = ReciterModel(1, 'Reciter 1', 'A', [
        createMoshaf(1, [1, 2, 3]),
        createMoshaf(2, [4, 5, 6]),
      ]);
      when(() => mockBox.values).thenReturn([reciter]);

      final result1 = await dataSource.getReciterBySurah(2);
      final result2 = await dataSource.getReciterBySurah(5);

      expect(result1.length, equals(1));
      expect(result2.length, equals(1));
      expect(result1[0].id, equals(1));
      expect(result2[0].id, equals(1));
    });

    test('Handles very large number of reciters or moshafs', () async {
      final largeList = List.generate(10000, (index) => createReciter(index, List.generate(114, (i) => i + 1)));
      when(() => mockBox.values).thenReturn(largeList);

      final result = await dataSource.getReciterBySurah(50);

      expect(result.length, equals(10000));
    });
  });

  group('clearAllReciters', () {
    test('Successfully clears all reciters', () async {
      when(() => mockBox.clear()).thenAnswer((_) => Future.value(5)); // Assume 5 items were cleared

      await dataSource.clearAllReciters();

      verify(() => mockBox.clear()).called(1);
    });

    test('Clearing an already empty box', () async {
      when(() => mockBox.clear()).thenAnswer((_) => Future.value(0)); // No items to clear

      await dataSource.clearAllReciters();

      verify(() => mockBox.clear()).called(1);
    });

    test('Interruption during the clearing process', () async {
      when(() => mockBox.clear()).thenThrow(HiveError('Interrupted during clearing'));

      expect(() => dataSource.clearAllReciters(), throwsA(isA<ClearAllRecitersException>()));
    });
  });

  group('isRecitersCached', () {
    test('Returns true when reciters are cached', () {
      when(() => mockBox.isNotEmpty).thenReturn(true);

      expect(dataSource.isRecitersCached(), isTrue);
    });

    test('Returns false when no reciters are cached', () {
      when(() => mockBox.isNotEmpty).thenReturn(false);

      expect(dataSource.isRecitersCached(), isFalse);
    });

    test('Box is not initialized or opened', () {
      when(() => mockBox.isNotEmpty).thenThrow(HiveError('Box not opened'));

      expect(() => dataSource.isRecitersCached(), throwsA(isA<CannotCheckRecitersCachedException>()));
    });

    test('Box is corrupted', () {
      when(() => mockBox.isNotEmpty).thenThrow(HiveError('Corrupted box'));

      expect(() => dataSource.isRecitersCached(), throwsA(isA<CannotCheckRecitersCachedException>()));
    });
  });

  group('General Hive-related issues', () {
    test('Hive box is not initialized before use', () {
      when(() => mockBox.values).thenThrow(HiveError('Box not opened'));

      expect(() => dataSource.getReciters(), throwsA(isA<FetchRecitersException>()));
    });

    test('Hive box becomes corrupted', () {
      when(() => mockBox.values).thenThrow(HiveError('Corrupted box'));

      expect(() => dataSource.getReciters(), throwsA(isA<FetchRecitersException>()));
    });

    test('Disk space runs out during write operations', () {
      when(() => mockBox.putAll(any<Map<dynamic, ReciterModel>>())).thenThrow(HiveError('No space left on device'));

      expect(
          () => dataSource.saveReciters([
                createReciter(1, [1, 2, 3])
              ]),
          throwsA(isA<SaveRecitersException>()));
    });
  });
}
