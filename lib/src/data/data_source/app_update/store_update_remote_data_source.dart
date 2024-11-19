import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawaqit/src/const/constants.dart';
import 'package:mawaqit/src/domain/model/app_update_info.dart';
import 'package:upgrader/upgrader.dart';
import 'package:open_store/open_store.dart';

class StoreUpdateRemoteDataSource {
  final Upgrader _upgrader;

  StoreUpdateRemoteDataSource({Upgrader? upgrader})
      : _upgrader = upgrader ?? Upgrader();

  Future<UpdateInfo> getLatestUpdate() async {
    try {
      await _upgrader.initialize();
      final version = _upgrader.currentAppStoreVersion() ?? '0.0.0';
      final notes = _upgrader.releaseNotes ?? '';
      final message = _upgrader.message();

      return UpdateInfo(
        version: version,
        downloadUrl: '', // Store handles the download
        releaseNotes: notes,
        message: message,
        releaseDate: DateTime.now(), // Store API doesn't provide this
      );
    } catch (e) {
      throw Exception('Error fetching store update: $e');
    }
  }

  Future<bool> isUpdateAvailable() async {
    await _upgrader.initialize();
    return _upgrader.isUpdateAvailable();
  }

  Future<void> openStore() async {
    await OpenStore.instance.open(
      androidAppBundleId: kGooglePlayId,
    );
  }

  String? getCurrentStoreVersion() {
    return _upgrader.currentAppStoreVersion();
  }
}

final storeUpdateRemoteDataSourceProvider = Provider.family<StoreUpdateRemoteDataSource, String>((ref, language) {
  return StoreUpdateRemoteDataSource(
    upgrader: Upgrader(
      messages: UpgraderMessages(code: language),
    ),
  );
});
