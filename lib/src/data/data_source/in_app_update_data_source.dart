import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:in_app_update/in_app_update.dart';

import '../../../main.dart';
import '../../domain/repository/in_app_update_repository.dart';

class InAppUpdateDataSource implements InAppUpdateRepository {

  Future<bool> checkForUpdate() async {
    try {
      final updateInfo = await InAppUpdate.checkForUpdate();
      logger.i('Update availability: ${updateInfo.updateAvailability}');
      return updateInfo.updateAvailability != UpdateAvailability.updateNotAvailable || updateInfo.updateAvailability != UpdateAvailability.unknown;
    } catch (e) {
      throw Exception('Failed to check for update: $e');
    }
  }

  Future<AppUpdateResult> startFlexibleUpdate() async {
    try {
      final result = await InAppUpdate.startFlexibleUpdate();
      return result;
    } catch (e) {
      throw Exception('Failed to start flexible update: $e');
    }
  }

  Future<void> completeFlexibleUpdate() async {
    try {
      await InAppUpdate.completeFlexibleUpdate();
    } catch (e) {
      throw Exception('Failed to complete flexible update: $e');
    }
  }

  Future<void> performImmediateUpdate() async {
    try {
      await InAppUpdate.performImmediateUpdate();
    } catch (e) {
      throw Exception('Failed to perform immediate update: $e');
    }
  }
}

final inAppUpdateDataSourceProvider = Provider.autoDispose<InAppUpdateDataSource>((ref) => InAppUpdateDataSource());
