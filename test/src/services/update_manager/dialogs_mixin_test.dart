import 'package:flutter_test/flutter_test.dart';
import 'package:mawaqit/src/services/update_manager/dialogs_mixin.dart';
import 'package:mawaqit/src/services/update_manager/update_manager.dart';

class ManagerMockup extends UpdateManager with UpdateManagerDialogsMixin {
  @override
  Future<String?> checkForUpdate() {
    // TODO: implement checkForUpdate
    throw UnimplementedError();
  }

  @override
  Future<void> downloadUpdateApk() {
    throw UnimplementedError();
  }

  @override
  Future<void> startUpdate() {
    throw UnimplementedError();
  }
}

void main() {
  group('Dialogs mixins tests ...', () {
    final manager = ManagerMockup();

    test('version comparer', () {
      expect(
        manager.compareTwoVersion(oldVersion: '1.1.1', newVersion: '1.1.1'),
        false,
      );

      expect(
        manager.compareTwoVersion(oldVersion: '1.1.1', newVersion: '1.1.2'),
        true,
      );

      expect(
        manager.compareTwoVersion(oldVersion: '1.1.1', newVersion: '1.2.1'),
        true,
      );

      expect(
        manager.compareTwoVersion(oldVersion: '1.1.1', newVersion: '2.1.1'),
        true,
      );

      expect(
        manager.compareTwoVersion(oldVersion: '1.1.1', newVersion: '1.1.0'),
        false,
      );

      expect(
        manager.compareTwoVersion(oldVersion: '1.1.1', newVersion: '1.10.1'),
        true,
      );
    });
  });
}
