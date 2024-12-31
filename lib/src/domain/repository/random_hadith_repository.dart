abstract class RandomHadithRepository {
  Future<String> getRandomHadith({required String language});
  Future<void> fetchAndCacheHadith(String language);
  Future<void> ensureHadithsAreCached(String language);
}
