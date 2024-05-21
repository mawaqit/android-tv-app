import 'package:mawaqit/src/domain/model/quran/language_model.dart';
import 'package:mawaqit/src/domain/model/quran/surah_model.dart';

abstract class QuranRepository {
  Future<List<SurahModel>> getSuwarByLanguage({String languageCode = 'en'});

  Future<List<LanguageModel>> getLanguages();
}
