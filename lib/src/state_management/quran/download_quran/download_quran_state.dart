// download_quran_state.dart
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

class NoUpdate extends DownloadQuranState {
  final String version;

  const NoUpdate(this.version);
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

class Success extends DownloadQuranState {
  final String version;

  const Success(this.version);
}

class Cancel extends DownloadQuranState {
  const Cancel();
}
