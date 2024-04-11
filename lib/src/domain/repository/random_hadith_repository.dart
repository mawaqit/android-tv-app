abstract class RandomHadithRepository {
  Future<String> getRandomHadith({required String language});
  Future<void> fetchAndCacheHadith(String language);
}
