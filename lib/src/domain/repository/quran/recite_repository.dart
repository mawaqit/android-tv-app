import 'package:mawaqit/src/domain/model/quran/reciter_model.dart';

abstract class ReciteRepository {
  Future<List<ReciterModel>> getRecitersBySurah({
    required int surahId,
    required String language,
  });
}
