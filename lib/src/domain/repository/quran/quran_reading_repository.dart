import 'package:flutter_svg/svg.dart';
import 'package:mawaqit/src/domain/model/quran/moshaf_type_model.dart';

abstract class QuranReadingRepository {
  Future<int> getLastReadPage();
  Future<void> saveLastReadPage(int page);
  Future<List<SvgPicture>> loadAllSvgs(MoshafType moshafType);
}
