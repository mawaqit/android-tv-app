// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'language_model.dart';

class LanguageModelMapper extends ClassMapperBase<LanguageModel> {
  LanguageModelMapper._();

  static LanguageModelMapper? _instance;
  static LanguageModelMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = LanguageModelMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'LanguageModel';

  static String _$id(LanguageModel v) => v.id;
  static const Field<LanguageModel, String> _f$id = Field('id', _$id);
  static String _$language(LanguageModel v) => v.language;
  static const Field<LanguageModel, String> _f$language =
      Field('language', _$language);
  static String _$native(LanguageModel v) => v.native;
  static const Field<LanguageModel, String> _f$native =
      Field('native', _$native);
  static String _$locale(LanguageModel v) => v.locale;
  static const Field<LanguageModel, String> _f$locale =
      Field('locale', _$locale);
  static String _$surah(LanguageModel v) => v.surah;
  static const Field<LanguageModel, String> _f$surah = Field('surah', _$surah);
  static String _$rewayah(LanguageModel v) => v.rewayah;
  static const Field<LanguageModel, String> _f$rewayah =
      Field('rewayah', _$rewayah);
  static String _$reciters(LanguageModel v) => v.reciters;
  static const Field<LanguageModel, String> _f$reciters =
      Field('reciters', _$reciters);
  static String _$tafasir(LanguageModel v) => v.tafasir;
  static const Field<LanguageModel, String> _f$tafasir =
      Field('tafasir', _$tafasir);

  @override
  final MappableFields<LanguageModel> fields = const {
    #id: _f$id,
    #language: _f$language,
    #native: _f$native,
    #locale: _f$locale,
    #surah: _f$surah,
    #rewayah: _f$rewayah,
    #reciters: _f$reciters,
    #tafasir: _f$tafasir,
  };

  static LanguageModel _instantiate(DecodingData data) {
    return LanguageModel(
        data.dec(_f$id),
        data.dec(_f$language),
        data.dec(_f$native),
        data.dec(_f$locale),
        data.dec(_f$surah),
        data.dec(_f$rewayah),
        data.dec(_f$reciters),
        data.dec(_f$tafasir));
  }

  @override
  final Function instantiate = _instantiate;

  static LanguageModel fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<LanguageModel>(map);
  }

  static LanguageModel fromJson(String json) {
    return ensureInitialized().decodeJson<LanguageModel>(json);
  }
}

mixin LanguageModelMappable {
  String toJson() {
    return LanguageModelMapper.ensureInitialized()
        .encodeJson<LanguageModel>(this as LanguageModel);
  }

  Map<String, dynamic> toMap() {
    return LanguageModelMapper.ensureInitialized()
        .encodeMap<LanguageModel>(this as LanguageModel);
  }

  LanguageModelCopyWith<LanguageModel, LanguageModel, LanguageModel>
      get copyWith => _LanguageModelCopyWithImpl(
          this as LanguageModel, $identity, $identity);
  @override
  String toString() {
    return LanguageModelMapper.ensureInitialized()
        .stringifyValue(this as LanguageModel);
  }

  @override
  bool operator ==(Object other) {
    return LanguageModelMapper.ensureInitialized()
        .equalsValue(this as LanguageModel, other);
  }

  @override
  int get hashCode {
    return LanguageModelMapper.ensureInitialized()
        .hashValue(this as LanguageModel);
  }
}

extension LanguageModelValueCopy<$R, $Out>
    on ObjectCopyWith<$R, LanguageModel, $Out> {
  LanguageModelCopyWith<$R, LanguageModel, $Out> get $asLanguageModel =>
      $base.as((v, t, t2) => _LanguageModelCopyWithImpl(v, t, t2));
}

abstract class LanguageModelCopyWith<$R, $In extends LanguageModel, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call(
      {String? id,
      String? language,
      String? native,
      String? locale,
      String? surah,
      String? rewayah,
      String? reciters,
      String? tafasir});
  LanguageModelCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _LanguageModelCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, LanguageModel, $Out>
    implements LanguageModelCopyWith<$R, LanguageModel, $Out> {
  _LanguageModelCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<LanguageModel> $mapper =
      LanguageModelMapper.ensureInitialized();
  @override
  $R call(
          {String? id,
          String? language,
          String? native,
          String? locale,
          String? surah,
          String? rewayah,
          String? reciters,
          String? tafasir}) =>
      $apply(FieldCopyWithData({
        if (id != null) #id: id,
        if (language != null) #language: language,
        if (native != null) #native: native,
        if (locale != null) #locale: locale,
        if (surah != null) #surah: surah,
        if (rewayah != null) #rewayah: rewayah,
        if (reciters != null) #reciters: reciters,
        if (tafasir != null) #tafasir: tafasir
      }));
  @override
  LanguageModel $make(CopyWithData data) => LanguageModel(
      data.get(#id, or: $value.id),
      data.get(#language, or: $value.language),
      data.get(#native, or: $value.native),
      data.get(#locale, or: $value.locale),
      data.get(#surah, or: $value.surah),
      data.get(#rewayah, or: $value.rewayah),
      data.get(#reciters, or: $value.reciters),
      data.get(#tafasir, or: $value.tafasir));

  @override
  LanguageModelCopyWith<$R2, LanguageModel, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _LanguageModelCopyWithImpl($value, $cast, t);
}
