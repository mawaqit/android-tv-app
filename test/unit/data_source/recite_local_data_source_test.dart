import 'package:flutter_test/flutter_test.dart';
import 'package:mawaqit/src/const/constants.dart';
import 'package:mawaqit/src/data/data_source/quran/reciter_local_data_source.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mawaqit/src/domain/error/recite_exception.dart';
import 'package:mawaqit/src/domain/model/quran/moshaf_model.dart';
import 'package:mawaqit/src/domain/model/quran/reciter_model.dart';
import 'package:mocktail/mocktail.dart';

class MockHiveBox extends Mock implements Box<ReciterModel> {}

class MockHiveFavoriteBox extends Mock implements Box<int> {}

class MockHiveTimestampBox extends Mock implements Box<DateTime> {}

void main() {
  late ReciteLocalDataSource dataSource;
  late MockHiveBox mockBox;
  late MockHiveFavoriteBox mockFavoriteBox;
  late MockHiveTimestampBox mockTimestampBox;

  setUp(() {
    mockBox = MockHiveBox();
    mockFavoriteBox = MockHiveFavoriteBox();
    mockTimestampBox = MockHiveTimestampBox();
    dataSource = ReciteLocalDataSource(mockBox, mockFavoriteBox, mockTimestampBox);
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

      // Mock both box operations
      when(() => mockBox.putAll(any<Map<dynamic, ReciterModel>>())).thenAnswer((_) async => Future<void>.value());
      when(() => mockTimestampBox.put(any(), any())).thenAnswer((_) async => Future<void>.value());

      await dataSource.saveReciters(reciters);

      // Verify both operations were called
      verify(() => mockBox.putAll(any<Map<dynamic, ReciterModel>>())).called(1);
      verify(() => mockTimestampBox.put(QuranConstant.kQuranReciterRetentionTime, any<DateTime>())).called(1);
    });

    // Update other tests similarly
    test('Handles empty list of reciters', () async {
      await dataSource.saveReciters([]);

      verifyNever(() => mockBox.putAll(any<Map<dynamic, ReciterModel>>()));
      verifyNever(() => mockTimestampBox.put(any(), any()));
    });

    test('Handles very large list of reciters', () async {
      final largeList = List.generate(10000, (index) => createReciter(index, [1, 2, 3]));

      when(() => mockBox.putAll(any<Map<dynamic, ReciterModel>>())).thenAnswer((_) async => Future<void>.value());
      when(() => mockTimestampBox.put(any(), any())).thenAnswer((_) async => Future<void>.value());

      await dataSource.saveReciters(largeList);

      verify(() => mockBox.putAll(any<Map<dynamic, ReciterModel>>())).called(1);
      verify(() => mockTimestampBox.put(QuranConstant.kQuranReciterRetentionTime, any<DateTime>())).called(1);
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
      // Mock both clear operations with correct return types
      when(() => mockBox.clear()).thenAnswer((_) async => 5); // Returns Future<int>
      when(() => mockTimestampBox.clear()).thenAnswer((_) async => 0); // Returns Future<int>

      await dataSource.clearAllReciters();

      verify(() => mockBox.clear()).called(1);
      verify(() => mockTimestampBox.clear()).called(1);
    });

    test('Clearing an already empty box', () async {
      when(() => mockBox.clear()).thenAnswer((_) async => 0);
      when(() => mockTimestampBox.clear()).thenAnswer((_) async => 0);

      await dataSource.clearAllReciters();

      verify(() => mockBox.clear()).called(1);
      verify(() => mockTimestampBox.clear()).called(1);
    });

    test('Interruption during the clearing process', () async {
      when(() => mockBox.clear()).thenThrow(HiveError('Interrupted during clearing'));
      when(() => mockTimestampBox.clear()).thenAnswer((_) async => 0);

      expect(() => dataSource.clearAllReciters(), throwsA(isA<ClearAllRecitersException>()));
    });

    test('Interruption during the timestamp clearing process', () async {
      when(() => mockBox.clear()).thenAnswer((_) async => 5);
      when(() => mockTimestampBox.clear()).thenThrow(HiveError('Interrupted during clearing'));

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

  group('Favorite Reciter', () {
    test('Adding the same reciter as a favorite multiple times', () async {
      final reciter = ReciterModel(1, 'Reciter 1', 'A', []);

      when(() => mockFavoriteBox.add(any())).thenAnswer((_) async => 0);
      when(() => mockFavoriteBox.values).thenReturn([1]);
      when(() => mockBox.values).thenReturn([reciter]);

      await dataSource.addFavoriteReciter(1);
      await dataSource.addFavoriteReciter(1);

      verify(() => mockFavoriteBox.add(1)).called(2);
      expect(dataSource.isFavoriteReciter(1), isTrue);

      final favorites = await dataSource.getFavoriteReciters();
      expect(favorites, hasLength(1));
      expect(favorites.first.id, equals(1));
    });

    test('Removing a favorite reciter that doesn\'t exist', () async {
      when(() => mockFavoriteBox.values).thenReturn([]);
      when(() => mockFavoriteBox.deleteAt(any())).thenAnswer((_) async {});

      await dataSource.removeFavoriteReciter(999);

      verifyNever(() => mockFavoriteBox.deleteAt(any()));
    });

    test('Removing a favorite reciter multiple times', () async {
      final favoriteList = [1];

      when(() => mockFavoriteBox.values).thenAnswer((_) => favoriteList);
      when(() => mockFavoriteBox.deleteAt(any())).thenAnswer((_) async {
        favoriteList.removeAt(0);
      });

      await dataSource.removeFavoriteReciter(1);
      await dataSource.removeFavoriteReciter(1);

      verify(() => mockFavoriteBox.deleteAt(any())).called(1);
      expect(favoriteList, isEmpty);
    });

    test('Adding multiple favorite reciters simultaneously', () async {
      when(() => mockFavoriteBox.add(any())).thenAnswer((_) async => 0);

      await Future.wait([
        dataSource.addFavoriteReciter(1),
        dataSource.addFavoriteReciter(2),
        dataSource.addFavoriteReciter(3),
      ]);

      verify(() => mockFavoriteBox.add(1)).called(1);
      verify(() => mockFavoriteBox.add(2)).called(1);
      verify(() => mockFavoriteBox.add(3)).called(1);
    });

    test('Adding and removing favorite reciters simultaneously', () async {
      when(() => mockFavoriteBox.add(any())).thenAnswer((_) async => 0);
      when(() => mockFavoriteBox.values).thenReturn([1, 2]);
      when(() => mockFavoriteBox.deleteAt(any())).thenAnswer((_) async {});

      await Future.wait([
        dataSource.addFavoriteReciter(3),
        dataSource.removeFavoriteReciter(1),
        dataSource.addFavoriteReciter(4),
        dataSource.removeFavoriteReciter(2),
      ]);

      verify(() => mockFavoriteBox.add(3)).called(1);
      verify(() => mockFavoriteBox.add(4)).called(1);
      verify(() => mockFavoriteBox.deleteAt(0)).called(1);
      verify(() => mockFavoriteBox.deleteAt(1)).called(1); // Changed from 0 to 1
    });

    test('Adding a favorite reciter that doesn\'t exist in the main reciter list', () async {
      // Mock adding to favorite box
      when(() => mockFavoriteBox.add(any())).thenAnswer((_) async => 0);

      // Mock favorite box values
      when(() => mockFavoriteBox.values).thenReturn([999]);

      // Mock main reciter box to be empty
      when(() => mockBox.values).thenReturn([]);

      await dataSource.addFavoriteReciter(999);
      final favorites = await dataSource.getFavoriteReciters();

      verify(() => mockFavoriteBox.add(999)).called(1);
      expect(favorites, isEmpty);
    });

    test('Updating a reciter in the main list and checking if it\'s reflected in favorites', () async {
      final oldReciter = ReciterModel(1, 'Reciter 1', 'A', []);
      final updatedReciter = ReciterModel(1, 'Updated Reciter 1', 'B', []);

      // Mock the main reciter box
      when(() => mockBox.values).thenReturn([oldReciter]);

      // Use only one definition for putAll - choose the style that works in other tests
      when(() => mockBox.putAll(any<Map<dynamic, ReciterModel>>())).thenAnswer((_) => Future<void>.value());
      when(() => mockTimestampBox.put(any(), any())).thenAnswer((_) => Future<void>.value());

      // Mock the favorite box
      when(() => mockFavoriteBox.values).thenReturn([1]);

      await dataSource.saveReciters([updatedReciter]);

      // Update the mock to return the updated reciter
      when(() => mockBox.values).thenReturn([updatedReciter]);

      final favorites = await dataSource.getFavoriteReciters();

      expect(favorites.first.name, equals('Updated Reciter 1'));
      expect(favorites.first.letter, equals('B'));
    });
  });
}
