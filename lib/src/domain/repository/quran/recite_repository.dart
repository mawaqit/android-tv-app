import 'package:mawaqit/src/domain/model/quran/reciter_model.dart';

abstract class ReciteRepository {
  Future<List<ReciterModel>> getAllReciters({required String language});
  Future<void> addFavoriteReciter(int reciterId);
  Future<void> removeFavoriteReciter(int reciterId);
  Future<List<ReciterModel>> getFavoriteReciters();
  bool isFavoriteReciter(int reciterId);
}
