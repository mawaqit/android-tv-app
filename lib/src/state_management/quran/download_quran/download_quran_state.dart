// download_quran_state.dart
import 'package:equatable/equatable.dart';

abstract class DownloadQuranState {
  const DownloadQuranState();
}

class Initial extends DownloadQuranState {
  const Initial();
}

class CheckingUpdate extends DownloadQuranState {
  const CheckingUpdate();
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

  const NoUpdate({
    required this.version,
    required this.svgFolderPath,
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

  const Success({
    required this.version,
    required this.svgFolderPath,
  });

  @override
  List<Object?> get props => [version, svgFolderPath];
}

class Cancel extends DownloadQuranState {
  const Cancel();
}
