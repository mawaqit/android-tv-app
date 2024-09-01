import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mawaqit/src/const/constants.dart';
import 'package:mawaqit/src/helpers/quran_path_helper.dart';
import 'package:mawaqit/src/state_management/quran/reading/quran_reading_state.dart';
import 'package:mawaqit/src/data/data_source/quran/download_quran_local_data_source.dart';

// Mock classes
class MockSharedPreferences extends Mock implements SharedPreferences {}

class MockQuranPathHelper extends Mock implements QuranPathHelper {}

class MockFile extends Mock implements File {}

void main() {
  late DownloadQuranLocalDataSource dataSource;
  late MockSharedPreferences mockSharedPreferences;
  late MockQuranPathHelper mockQuranPathHelper;

  setUpAll(() {
    registerFallbackValue(MockFile());
  });
  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    mockQuranPathHelper = MockQuranPathHelper();
    dataSource = DownloadQuranLocalDataSource(
      sharedPreference: mockSharedPreferences,
      quranPathHelper: mockQuranPathHelper,
    );
  });

  group('DownloadQuranLocalDataSource', () {

    group('saveSvgFiles', () {
      test('should save SVG files to the correct directory', () async {
        // Arrange
        final mockSvgFiles = [
          MockFile(),
          MockFile(),
        ];
        when(() => mockQuranPathHelper.quranDirectoryPath).thenReturn('/path/to/quran');
        when(() => mockSvgFiles[0].path).thenReturn('/temp/file1.svg');
        when(() => mockSvgFiles[1].path).thenReturn('/temp/file2.svg');
        when(() => mockSvgFiles[0].copy(any())).thenAnswer((_) async => MockFile());
        when(() => mockSvgFiles[1].copy(any())).thenAnswer((_) async => MockFile());

        // Act
        await dataSource.saveSvgFiles(mockSvgFiles, MoshafType.hafs);

        // Assert
        verify(() => mockSvgFiles[0].copy('/path/to/quran/file1.svg')).called(1);
        verify(() => mockSvgFiles[1].copy('/path/to/quran/file2.svg')).called(1);
      });

      test('should handle empty list of SVG files', () async {
        // Arrange
        final mockSvgFiles = <File>[];
        final mockFile = MockFile();
        when(() => mockQuranPathHelper.quranDirectoryPath).thenReturn('/path/to/quran');

        // Act
        await dataSource.saveSvgFiles(mockSvgFiles, MoshafType.hafs);

        // Assert
        verifyNever(() => mockFile.copy(any()));
      });

      test('should handle file copy exceptions', () async {
        // Arrange
        final mockSvgFile = MockFile();
        when(() => mockQuranPathHelper.quranDirectoryPath).thenReturn('/path/to/quran');
        when(() => mockSvgFile.path).thenReturn('/temp/file1.svg');
        when(() => mockSvgFile.copy(any())).thenThrow(Exception('Copy failed'));

        // Act & Assert
        expect(() => dataSource.saveSvgFiles([mockSvgFile], MoshafType.hafs), throwsException);
      });
    });

    group('deleteZipFile', () {
      test('should delete existing zip file and set version', () async {
        // Arrange
        const zipFileName = 'quran-v1.0.0.zip';
        final zipFilePath = '/path/to/zip/quran-v1.0.0.zip';

        when(() => mockQuranPathHelper.getQuranZipFilePath(zipFileName)).thenReturn(zipFilePath);

        final mockZipFile = MockFile();
        when(() => mockZipFile.exists()).thenAnswer((_) async => true);
        when(() => mockZipFile.delete()).thenAnswer((_) async => mockZipFile);

        when(() => mockSharedPreferences.setString(any(), any())).thenAnswer((_) async => true);

        // Act
        await dataSource.deleteZipFile(zipFileName, mockZipFile);

        // Assert
        verify(() => mockZipFile.exists()).called(1);
        verify(() => mockZipFile.delete()).called(1);
        verify(() => mockSharedPreferences.setString(QuranConstant.kQuranLocalVersion, zipFileName)).called(1);
      });

      test('should not delete non-existing zip file but still set version', () async {
        // Arrange
        const zipFileName = 'quran-v1.0.0.zip';
        when(() => mockQuranPathHelper.getQuranZipFilePath(zipFileName)).thenReturn('/path/to/zip/quran-v1.0.0.zip');
        final mockZipFile = MockFile();
        when(() => mockZipFile.exists()).thenAnswer((_) async => false);
        when(() => mockSharedPreferences.setString(any(), any())).thenAnswer((_) async => true);

        // Act
        await dataSource.deleteZipFile(zipFileName, mockZipFile);

        // Assert
        verifyNever(() => mockZipFile.delete());
        verify(() => mockSharedPreferences.setString(QuranConstant.kQuranLocalVersion, zipFileName)).called(1);
      });
    });

    group('getQuranVersion', () {
      test('should return stored version when available', () {
        // Arrange
        when(() => mockSharedPreferences.getString(QuranConstant.kQuranLocalVersion)).thenReturn('1.0.0');

        // Act
        final result = dataSource.getQuranVersion();

        // Assert
        expect(result, '1.0.0');
      });

      test('should return null when no version is stored', () {
        // Arrange
        when(() => mockSharedPreferences.getString(QuranConstant.kQuranLocalVersion)).thenReturn(null);

        // Act
        final result = dataSource.getQuranVersion();

        // Assert
        expect(result, null);
      });
    });
  });
}
