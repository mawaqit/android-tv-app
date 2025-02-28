// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'audio_file_model.dart';

class AudioFileModelMapper extends ClassMapperBase<AudioFileModel> {
  AudioFileModelMapper._();

  static AudioFileModelMapper? _instance;
  static AudioFileModelMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = AudioFileModelMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'AudioFileModel';

  static String _$reciterId(AudioFileModel v) => v.reciterId;
  static const Field<AudioFileModel, String> _f$reciterId =
      Field('reciterId', _$reciterId);
  static String _$moshafId(AudioFileModel v) => v.moshafId;
  static const Field<AudioFileModel, String> _f$moshafId =
      Field('moshafId', _$moshafId);
  static String _$surahId(AudioFileModel v) => v.surahId;
  static const Field<AudioFileModel, String> _f$surahId =
      Field('surahId', _$surahId);
  static String _$url(AudioFileModel v) => v.url;
  static const Field<AudioFileModel, String> _f$url = Field('url', _$url);

  @override
  final MappableFields<AudioFileModel> fields = const {
    #reciterId: _f$reciterId,
    #moshafId: _f$moshafId,
    #surahId: _f$surahId,
    #url: _f$url,
  };

  static AudioFileModel _instantiate(DecodingData data) {
    return AudioFileModel(data.dec(_f$reciterId), data.dec(_f$moshafId),
        data.dec(_f$surahId), data.dec(_f$url));
  }

  @override
  final Function instantiate = _instantiate;

  static AudioFileModel fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<AudioFileModel>(map);
  }

  static AudioFileModel fromJson(String json) {
    return ensureInitialized().decodeJson<AudioFileModel>(json);
  }
}

mixin AudioFileModelMappable {
  String toJson() {
    return AudioFileModelMapper.ensureInitialized()
        .encodeJson<AudioFileModel>(this as AudioFileModel);
  }

  Map<String, dynamic> toMap() {
    return AudioFileModelMapper.ensureInitialized()
        .encodeMap<AudioFileModel>(this as AudioFileModel);
  }

  AudioFileModelCopyWith<AudioFileModel, AudioFileModel, AudioFileModel>
      get copyWith => _AudioFileModelCopyWithImpl(
          this as AudioFileModel, $identity, $identity);
  @override
  String toString() {
    return AudioFileModelMapper.ensureInitialized()
        .stringifyValue(this as AudioFileModel);
  }

  @override
  bool operator ==(Object other) {
    return AudioFileModelMapper.ensureInitialized()
        .equalsValue(this as AudioFileModel, other);
  }

  @override
  int get hashCode {
    return AudioFileModelMapper.ensureInitialized()
        .hashValue(this as AudioFileModel);
  }
}

extension AudioFileModelValueCopy<$R, $Out>
    on ObjectCopyWith<$R, AudioFileModel, $Out> {
  AudioFileModelCopyWith<$R, AudioFileModel, $Out> get $asAudioFileModel =>
      $base.as((v, t, t2) => _AudioFileModelCopyWithImpl(v, t, t2));
}

abstract class AudioFileModelCopyWith<$R, $In extends AudioFileModel, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? reciterId, String? moshafId, String? surahId, String? url});
  AudioFileModelCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _AudioFileModelCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, AudioFileModel, $Out>
    implements AudioFileModelCopyWith<$R, AudioFileModel, $Out> {
  _AudioFileModelCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<AudioFileModel> $mapper =
      AudioFileModelMapper.ensureInitialized();
  @override
  $R call(
          {String? reciterId,
          String? moshafId,
          String? surahId,
          String? url}) =>
      $apply(FieldCopyWithData({
        if (reciterId != null) #reciterId: reciterId,
        if (moshafId != null) #moshafId: moshafId,
        if (surahId != null) #surahId: surahId,
        if (url != null) #url: url
      }));
  @override
  AudioFileModel $make(CopyWithData data) => AudioFileModel(
      data.get(#reciterId, or: $value.reciterId),
      data.get(#moshafId, or: $value.moshafId),
      data.get(#surahId, or: $value.surahId),
      data.get(#url, or: $value.url));

  @override
  AudioFileModelCopyWith<$R2, AudioFileModel, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _AudioFileModelCopyWithImpl($value, $cast, t);
}
