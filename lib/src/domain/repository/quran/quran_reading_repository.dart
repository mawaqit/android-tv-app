abstract class QuranReadingRepository {
  Future<int> getLastReadPage();
  Future<void> saveLastReadPage(int page);
}
