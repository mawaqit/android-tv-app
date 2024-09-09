import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mawaqit/src/domain/repository/quran/quran_reading_repository.dart';

import 'package:mawaqit/src/data/data_source/quran/quran_reading_local_data_source.dart';
import 'package:mawaqit/src/helpers/quran_path_helper.dart';
import 'package:mawaqit/src/state_management/quran/reading/quran_reading_state.dart';
import 'package:path_provider/path_provider.dart';

class QuranReadingImpl implements QuranReadingRepository {
  final QuranReadingLocalDataSource localDataSource;

  const QuranReadingImpl({
    required this.localDataSource,
  });

  @override
  Future<int> getLastReadPage() {
    return localDataSource.getLastReadPage();
  }

  @override
  Future<void> saveLastReadPage(int page) {
    return localDataSource.saveLastReadPage(page);
  }

  @override
  Future<List<SvgPicture>> loadAllSvgs(MoshafType moshafType) async {
    return localDataSource.loadAllSvgs(moshafType);
  }
}

final quranReadingRepositoryProvider = FutureProvider<QuranReadingRepository>((ref) async {
  final localDataSource = await ref.read(quranReadingLocalDataSourceProvider.future);
  return QuranReadingImpl(
    localDataSource: localDataSource,
  );
});
