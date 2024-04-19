import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/src/domain/repository/random_hadith_repository.dart';

import '../../../main.dart';
import '../../data/repository/random_hadith_impl.dart';

class RandomHadithUseCase {
  final RandomHadithRepository _hadithRepository;

  RandomHadithUseCase(this._hadithRepository);

  Future<String> getRandomHadith({
    String language = 'ar',
  }) async {
    try {
      final hadith = await _hadithRepository.getRandomHadith(language: language);
      return hadith;
    } catch (e) {
      rethrow;
    }
  }
}

final randomHadithUseCaseProvider = FutureProvider.autoDispose((ref) async {
  final hadithRepository = await ref.read(randomHadithRepositoryProvider.future);
  return RandomHadithUseCase(
    hadithRepository,
  );
});
