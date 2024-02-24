import 'dart:isolate';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/src/const/constants.dart';
import 'package:mawaqit/src/data/data_source/random_hadith_local_data_source.dart';
import 'package:mawaqit/src/domain/repository/random_hadith_repository.dart';
import 'package:mawaqit/src/models/address_model.dart';
import 'package:mawaqit/src/services/connectivity_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../main.dart';
import '../data_source/random_hadith_remote_data_source.dart';

/// [RandomHadithImpl] Implementation of the RandomHadithRepository.
///
/// This class handles the logic to fetch a random Hadith either from remote or local sources
/// based on the connectivity status. It leverages the connectivity service to check for internet
/// connection and SharedPreferences to cache the date of the last fetch operation.
class RandomHadithImpl implements RandomHadithRepository {
  final RandomHadithRemoteDataSource remoteDataSource;
  final RandomHadithLocalDataSource localDataSource;
  final ConnectivityService connectivityService;
  final SharedPreferences sharedPreferences;

  RandomHadithImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.connectivityService,
    required this.sharedPreferences,
  });

  /// Fetches a random Hadith based on the provided language.
  ///
  /// First checks for internet connectivity. If connected, it attempts to fetch the Hadith
  /// from the remote source and updates local cache. If not connected, it fetches the Hadith
  /// from the local cache. It also manages the caching of the fetch operation date to limit
  /// remote fetches to once per day.
  @override
  Future<String> getRandomHadith({required String language}) async {
    final checkConnectivity = await connectivityService.connectionStatus;
    if (checkConnectivity == ConnectivityStatus.connected) {
      final hadith = await remoteDataSource.getRandomHadith(language: language);

      final lastRunTime = sharedPreferences.getInt(RandomHadithConstant.kLastHadithXMLFetchDate);

      // Check if a fetch operation was performed within the last day.
      if (lastRunTime != null) {
        final lastRunDate = DateTime.fromMillisecondsSinceEpoch(lastRunTime);
        final now = DateTime.now();
        if (now.difference(lastRunDate).inDays < 1) {
          return hadith;
        }
      }

      // Update the date of the last successful fetch operation.
      final today = DateTime.now().millisecondsSinceEpoch;
      await sharedPreferences.setInt(
        RandomHadithConstant.kLastHadithXMLFetchDate,
        today,
      );

      // Use an isolate to fetch the Hadith in XML format and cache it locally.
      final hadithXmlList = await Isolate.run(
        () async => RandomHadithRemoteDataSource.getRandomHadithXML(language: language),
      );

      if (hadithXmlList != null) {
        final List<String> hadithList = [];
        hadithXmlList.forEach((e) {
          if (e.text != null) hadithList.add(e.text!);
        });
        await localDataSource.cacheRandomHadith(language, hadithList);
      }
      return hadith;
    } else {
      // Fetch from local cache if not connected.
      final hadith = await localDataSource.getRandomHadith(language: language);

      return hadith ?? '';
    }
  }
}


/// [randomHadithRepositoryProvider] Riverpod provider for RandomHadithImpl.
final randomHadithRepositoryProvider = FutureProvider.autoDispose<RandomHadithImpl>(
  (ref) async {
    final localDataSource = await ref.read(randomHadithLocalDataSourceProvider.future);
    final remoteDataSource = ref.read(randomHadithRemoteDataSourceProvider);
    final sharedPreferences = await SharedPreferences.getInstance();
    return RandomHadithImpl(
      remoteDataSource: remoteDataSource,
      localDataSource: localDataSource,
      sharedPreferences: sharedPreferences,
      connectivityService: ref.read(
        connectivityServiceProvider(
          ConnectivityServiceParams(
            interval: const Duration(seconds: 5),
            timeout: const Duration(seconds: 5),
          ),
        ),
      ),
    );
  },
);
