
import 'package:dio/dio.dart'; 
import 'package:fpdart/fpdart.dart';
import 'package:mawaqit/src/domain/model/quran/moshaf_type_model.dart';

abstract class QuranDownloadRepository {
  Future<Option<String>> getLocalQuranVersion({
    required MoshafType moshafType,
  });

  Future<String> getRemoteQuranVersion({
    required MoshafType moshafType,
  });

  Future<void> downloadQuran({
    required String version,
    required MoshafType moshafType,
    String? filePath,
    required dynamic Function(double) onReceiveProgress,
    required dynamic Function(double) onExtractProgress,
  });


  void cancelDownload(CancelToken cancelToken);

  Future<bool> isQuranDownloaded(MoshafType moshafType);
}
