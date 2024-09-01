import 'package:flutter_test/flutter_test.dart';
import 'package:mawaqit/src/data/data_source/quran/reciter_local_data_source.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mawaqit/src/domain/error/recite_exception.dart';
import 'package:mawaqit/src/domain/model/quran/moshaf_model.dart';
import 'package:mawaqit/src/domain/model/quran/reciter_model.dart';
import 'package:mocktail/mocktail.dart';

class MockHiveBox extends Mock implements Box<ReciterModel> {}

void main() {
  late ReciteLocalDataSource dataSource;
  late MockHiveBox mockBox;

  setUp(() {
    mockBox = MockHiveBox();
    dataSource = ReciteLocalDataSource(mockBox);
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
}
