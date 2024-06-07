import 'package:mawaqit/src/domain/model/quran/moshaf_model.dart';
import 'package:mawaqit/src/domain/model/quran/reciter_model.dart';

abstract class QuranFavoriteRepository {
  Future<void> saveFavoriteReciter(int reciterId);

  Future<void> saveFavoriteSuwar({
    required int reciterId,
    required int surahId,
    required String riwayat,
  });

  Future<List<ReciterModel>> getFavoriteReciters();

  Future<MoshafModel> getFavoriteSuwar(
    int reciterId,
    String riwayat,
  );
}
