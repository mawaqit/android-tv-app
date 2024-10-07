import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mawaqit/src/const/constants.dart';
import 'package:mawaqit/src/helpers/quran_path_helper.dart';
import 'package:mawaqit/src/data/data_source/quran/download_quran_local_data_source.dart';
import 'package:mawaqit/src/domain/model/quran/moshaf_type_model.dart';
import 'package:fpdart/fpdart.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

class MockQuranPathHelper extends Mock implements QuranPathHelper {}

class MockFile extends Mock implements File {}

class MockDirectory extends Mock implements Directory {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DownloadQuranLocalDataSource dataSource;
  late MockSharedPreferences mockSharedPreferences;
  late MockQuranPathHelper mockQuranPathHelper;
  late MoshafType moshafType;

  setUpAll(() {
    registerFallbackValue(MockFile());
  });

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    mockQuranPathHelper = MockQuranPathHelper();
    moshafType = MoshafType.hafs;
    dataSource = DownloadQuranLocalDataSource(
      sharedPreference: mockSharedPreferences,
      quranPathHelper: mockQuranPathHelper,
      moshafType: moshafType,
    );
  });

  group('DownloadQuranLocalDataSource', () {
    group('saveSvgFiles', () {
      test('should save SVG files to the correct directory', () async {
        final mockSvgFiles = [MockFile(), MockFile()];
        when(() => mockQuranPathHelper.quranDirectoryPath).thenReturn('/path/to/quran');
        when(() => mockSvgFiles[0].path).thenReturn('/temp/file1.svg');
        when(() => mockSvgFiles[1].path).thenReturn('/temp/file2.svg');

        // Updated with explicit type argument
        when(() => mockSvgFiles[0].copy(any<String>())).thenAnswer((_) async => MockFile());
        when(() => mockSvgFiles[1].copy(any<String>())).thenAnswer((_) async => MockFile());

        await dataSource.saveSvgFiles(mockSvgFiles, MoshafType.hafs);

        // Updated with explicit type argument
        verify(() => mockSvgFiles[0].copy(any<String>())).called(1);
        verify(() => mockSvgFiles[1].copy(any<String>())).called(1);
      });
    });

    group('deleteZipFile', () {
      test('should delete existing zip file', () async {
        final mockZipFile = MockFile();
        when(() => mockZipFile.exists()).thenAnswer((_) async => true);
        when(() => mockZipFile.delete()).thenAnswer((_) async => mockZipFile);

        await dataSource.deleteZipFile('quran-v1.0.0.zip', mockZipFile);

        verify(() => mockZipFile.exists()).called(1);
        verify(() => mockZipFile.delete()).called(1);
      });

      test('should not delete non-existing zip file', () async {
        final mockZipFile = MockFile();
        when(() => mockZipFile.exists()).thenAnswer((_) async => false);

        await dataSource.deleteZipFile('quran-v1.0.0.zip', mockZipFile);

        verify(() => mockZipFile.exists()).called(1);
        verifyNever(() => mockZipFile.delete());
      });
    });

    group('setQuranVersion', () {
      test('should set the correct version for Hafs', () async {
        const version = '1.0.0';
        when(() => mockSharedPreferences.setString(any(), any())).thenAnswer((_) async => true);

        await dataSource.setQuranVersion(version, MoshafType.hafs);

        verify(() => mockSharedPreferences.setString(QuranConstant.kHafsQuranLocalVersion, version)).called(1);
      });

      test('should set the correct version for Warsh', () async {
        const version = '1.0.0';
        final warshDataSource = DownloadQuranLocalDataSource(
          sharedPreference: mockSharedPreferences,
          quranPathHelper: mockQuranPathHelper,
          moshafType: MoshafType.warsh,
        );
        when(() => mockSharedPreferences.setString(any(), any())).thenAnswer((_) async => true);

        await warshDataSource.setQuranVersion(version, MoshafType.warsh);

        verify(() => mockSharedPreferences.setString(QuranConstant.kWarshQuranLocalVersion, version)).called(1);
      });
    });

    group('getQuranVersion', () {
      test('should return stored version when available', () {
        when(() => mockSharedPreferences.getString(any())).thenReturn('1.0.0');

        final result = dataSource.getQuranVersion(MoshafType.hafs);

        expect(result, equals(Some('1.0.0')));
      });

      test('should return None when no version is stored', () {
        when(() => mockSharedPreferences.getString(any())).thenReturn(null);

        final result = dataSource.getQuranVersion(MoshafType.hafs);

        expect(result, equals(None()));
      });
    });

    // group('isQuranDownloaded', () {
    //   test('should return true when Quran directory exists', () async {
    //     when(() => mockQuranPathHelper.quranDirectoryPath).thenReturn('/path/to/quran');
    //     final mockDirectory = MockDirectory();
    //     when(() => mockDirectory.existsSync()).thenReturn(true);
    //
    //     final result = await dataSource.isQuranDownloaded(MoshafType.hafs);
    //
    //     expect(result, true);
    //   });
    //
    //   test('should return false when Quran directory does not exist', () async {
    //     when(() => mockQuranPathHelper.quranDirectoryPath).thenReturn('/path/to/quran');
    //     final mockDirectory = MockDirectory();
    //     when(() => mockDirectory.existsSync()).thenReturn(false);
    //
    //     final result = await dataSource.isQuranDownloaded(MoshafType.hafs);
    //
    //     expect(result, false);
    //   });
    //
    //   test('should rethrow exceptions', () {
    //     when(() => mockQuranPathHelper.quranDirectoryPath).thenThrow(Exception('Test exception'));
    //
    //     expect(() => dataSource.isQuranDownloaded(MoshafType.hafs), throwsException);
    //   });
    // });
  });
}
