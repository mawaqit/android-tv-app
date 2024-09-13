import 'package:dart_mappable/dart_mappable.dart';

part 'audio_file_model.mapper.dart';

@MappableClass()
class AudioFileModel {
  final String reciterId;
  final String riwayahId;
  final String surahId;
  final String url;

  AudioFileModel(this.reciterId, this.riwayahId, this.surahId, this.url);

  String get filePath => '$reciterId/$riwayahId/$surahId.mp3';

  factory AudioFileModel.fromJson(Map<String, dynamic> map) => _ensureContainer.fromMap<AudioFileModel>(map);

  factory AudioFileModel.fromString(String json) => _ensureContainer.fromJson<AudioFileModel>(json);

  Map<String, dynamic> toJson() {
    return _ensureContainer.toMap(this);
  }

  @override
  String toString() {
    return _ensureContainer.toJson(this);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || (runtimeType == other.runtimeType && _ensureContainer.isEqual(this, other));
  }

  @override
  int get hashCode {
    return _ensureContainer.hash(this);
  }

  AudioFileModelCopyWith<AudioFileModel, AudioFileModel, AudioFileModel> get copyWith {
    return _AudioFileModelCopyWithImpl(this, $identity, $identity);
  }

  static final MapperContainer _ensureContainer = () {
    AudioFileModelMapper.ensureInitialized();
    return MapperContainer.globals;
  }();

  static AudioFileModelMapper ensureInitialized() => AudioFileModelMapper.ensureInitialized();
}
