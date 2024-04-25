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
}

class Extracting extends DownloadQuranState {
  final double progress;

  const Extracting(this.progress);
}

class Success extends DownloadQuranState {
  final String version;

  const Success(this.version);
}

class Error extends DownloadQuranState {
  final String message;

  const Error(this.message);
}

class Cancel extends DownloadQuranState {
  const Cancel();
}
