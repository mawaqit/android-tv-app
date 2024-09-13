import 'package:flutter_svg/svg.dart';
import 'package:mawaqit/src/state_management/quran/reading/quran_reading_state.dart';

abstract class QuranReadingRepository {
  Future<int> getLastReadPage();
  Future<void> saveLastReadPage(int page);
  Future<List<SvgPicture>> loadAllSvgs(MoshafType moshafType);
}
