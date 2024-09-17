// download_quran_state.dart
import 'package:equatable/equatable.dart';
import 'package:mawaqit/src/domain/model/quran/moshaf_type_model.dart';

abstract class DownloadQuranState {
  const DownloadQuranState();
}

class Initial extends DownloadQuranState {
  const Initial();
}

class CheckingUpdate extends DownloadQuranState {
  const CheckingUpdate();
}

class CheckingDownloadedQuran extends DownloadQuranState {
  const CheckingDownloadedQuran();
}

class Downloading extends DownloadQuranState {
  final double progress;

  const Downloading(this.progress);

  @override
  String toString() {
    return 'Downloading: $progress';
  }
}

class NoUpdate extends DownloadQuranState with EquatableMixin {
  final String version;
  final String svgFolderPath;
  final MoshafType moshafType;

  const NoUpdate({
    required this.version,
    required this.svgFolderPath,
    required this.moshafType,
  });

  @override
  List<Object?> get props => [version, svgFolderPath];
}

class UpdateAvailable extends DownloadQuranState {
  final String version;

  const UpdateAvailable(this.version);
}

class CancelDownload extends DownloadQuranState {
  const CancelDownload();
}

class Extracting extends DownloadQuranState {
  final double progress;

  const Extracting(this.progress);

  @override
  String toString() {
    return 'Extracting: $progress';
  }
}

class Success extends DownloadQuranState with EquatableMixin {
  final String version;
  final String svgFolderPath;
  final MoshafType moshafType;

  const Success({
    required this.version,
    required this.svgFolderPath,
    required this.moshafType,
  });

  @override
  List<Object?> get props => [version, svgFolderPath];
}

class Cancel extends DownloadQuranState {
  const Cancel();
}

class NeededDownloadedQuran extends DownloadQuranState {
  const NeededDownloadedQuran();
}

class Error extends DownloadQuranState {
  final Object error;
  final StackTrace stackTrace;

  const Error(this.error, this.stackTrace);
}
