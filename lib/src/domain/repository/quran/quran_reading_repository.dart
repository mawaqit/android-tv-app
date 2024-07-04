import 'package:flutter_svg/svg.dart';

abstract class QuranReadingRepository {
  Future<int> getLastReadPage();
  Future<void> saveLastReadPage(int page);
  Future<List<SvgPicture>> loadAllSvgs();
}
