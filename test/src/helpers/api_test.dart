import 'package:flutter_test/flutter_test.dart';
import 'package:mawaqit/src/helpers/Api.dart';
import 'package:mawaqit/src/models/mosque.dart';
import 'package:mawaqit/src/models/mosqueConfig.dart';
import 'package:mawaqit/src/models/times.dart';

void main() {
  group('Api unit tests', () {
    test('Search Mosque with id', () async {
      final mosque = Api.searchMosqueWithId('1');

      expect(mosque, completion(isA<Mosque>()));
    });

    /// make sure api search is working fine
    test('mosque searching is working', () {
      final data = Api.searchMosques('paris');

      expect(data, completion(isA<List<Mosque>>()));
    });

    /// make sure api get the correct data from the server with no issues
    test('get mosque test', () {
      const testMosquesUUIDs = [
        /// GRANDE MOSQUÉE DE PARIS
        '05b4d393-fb76-4d9b-b2a4-f98ab4c4b64f',

        /// Maison d'Allah بيت الله
        '8e8a41cf-62d4-4890-9454-120d27b229e1',
      ];

      for (final uuid in testMosquesUUIDs) {
        final mosque = Api.getMosque(uuid);
        final config = Api.getMosqueConfig(uuid);
        final times = Api.getMosqueTimes(uuid);

        expect(mosque, completion(isA<Mosque>()));
        expect(config, completion(isA<MosqueConfig>()));
        expect(times, completion(isA<Times>()));
      }
    });

    test('Get mosque by id', () {
      final testIDs = ['256', '1'];

      for (final id in testIDs) {
        final mosque = Api.searchMosqueWithId(id);

        expect(mosque, completion(isA<Mosque>()));
      }
    });
  });
}
