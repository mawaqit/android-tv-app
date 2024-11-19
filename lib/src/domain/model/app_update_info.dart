class UpdateInfo {
  final String version;
  final String downloadUrl;
  final String releaseNotes;
  final DateTime releaseDate;
  final String message;

  UpdateInfo({
    required this.version,
    required this.downloadUrl,
    required this.releaseNotes,
    required this.releaseDate,
    this.message = '',
  });

  factory UpdateInfo.fromJson(Map<String, dynamic> json) {
    return UpdateInfo(
      version: json['tag_name'],
      downloadUrl: json['assets'][0]['browser_download_url'],
      releaseNotes: json['body'] ?? '',
      releaseDate: DateTime.parse(json['published_at']),
      message: json['message'] ?? '',
    );
  }
}
