import 'package:mawaqit/src/domain/model/quran/reciter_model.dart';

abstract class ReciteRepository {
  Future<List<ReciterModel>> getAllReciters({required String language});
}
