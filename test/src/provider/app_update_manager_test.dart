import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:mawaqit/src/models/times.dart';
import 'package:mawaqit/src/services/app_update_manager.dart';
import 'package:mawaqit/src/services/mosque_manager.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

class MockMosqueManager extends Mock implements MosqueManager {}

class MockInAppUpdate extends Mock implements InAppUpdate {}

class MockHiveInterface extends Mock implements HiveInterface {}

class MockHiveBox extends Mock implements Box {}

void main() {
  MockHiveInterface mockHiveInterface;
  MockHiveBox mockHiveBox;
  WidgetsFlutterBinding.ensureInitialized();

  // final documentDirectory = await getApplicationDocumentsDirectory();

  group('scheduleUpdate', () {
    late MockSharedPreferences mockSharedPreferences;
    late MockMosqueManager mockMosqueManager;
    mockHiveInterface = MockHiveInterface();
    mockHiveBox = MockHiveBox();

    setUp(() async {
      mockSharedPreferences = MockSharedPreferences();
      mockMosqueManager = MockMosqueManager();
    });

    test('performs update when a week has passed and current time is between prayer times', () async {
      final container = ProviderContainer(
        overrides: [
          appUpdateManagerProvider(mockSharedPreferences),
          mosqueManagerProvider.overrideWith((ref) {
            return mockMosqueManager;
          }),
        ],
      );
      when(() => mockMosqueManager).thenAnswer((_) => mockMosqueManager);
      when(() => mockMosqueManager.times).thenAnswer((_) => Times(

          ));
      when(() => mockSharedPreferences.getInt('last_update')).thenAnswer((_) => 0); // A time more than a week ago
      // // Set up the conditions for the test
      when(() => mockSharedPreferences.getInt('last_update')).thenAnswer((_) => 1000); // A time more than a week ago

      container.read(appUpdateManagerProvider(mockSharedPreferences).notifier).scheduleUpdate();
    });

    // Add more tests for different scenarios
  });
}
