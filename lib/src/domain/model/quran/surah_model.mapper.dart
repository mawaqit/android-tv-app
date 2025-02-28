// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'surah_model.dart';

class SurahModelMapper extends ClassMapperBase<SurahModel> {
  SurahModelMapper._();

  static SurahModelMapper? _instance;
  static SurahModelMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = SurahModelMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'SurahModel';

  static int _$id(SurahModel v) => v.id;
  static const Field<SurahModel, int> _f$id = Field('id', _$id);
  static String _$name(SurahModel v) => v.name;
  static const Field<SurahModel, String> _f$name = Field('name', _$name);
  static int _$startPage(SurahModel v) => v.startPage;
  static const Field<SurahModel, int> _f$startPage =
      Field('startPage', _$startPage, key: r'start_page');
  static int _$endPage(SurahModel v) => v.endPage;
  static const Field<SurahModel, int> _f$endPage =
      Field('endPage', _$endPage, key: r'end_page');
  static int _$makkia(SurahModel v) => v.makkia;
  static const Field<SurahModel, int> _f$makkia = Field('makkia', _$makkia);
  static int _$type(SurahModel v) => v.type;
  static const Field<SurahModel, int> _f$type = Field('type', _$type);

  @override
  final MappableFields<SurahModel> fields = const {
    #id: _f$id,
    #name: _f$name,
    #startPage: _f$startPage,
    #endPage: _f$endPage,
    #makkia: _f$makkia,
    #type: _f$type,
  };

  static SurahModel _instantiate(DecodingData data) {
    return SurahModel(
        data.dec(_f$id),
        data.dec(_f$name),
        data.dec(_f$startPage),
        data.dec(_f$endPage),
        data.dec(_f$makkia),
        data.dec(_f$type));
  }

  @override
  final Function instantiate = _instantiate;

  static SurahModel fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<SurahModel>(map);
  }

  static SurahModel fromJson(String json) {
    return ensureInitialized().decodeJson<SurahModel>(json);
  }
}

mixin SurahModelMappable {
  String toJson() {
    return SurahModelMapper.ensureInitialized()
        .encodeJson<SurahModel>(this as SurahModel);
  }

  Map<String, dynamic> toMap() {
    return SurahModelMapper.ensureInitialized()
        .encodeMap<SurahModel>(this as SurahModel);
  }

  SurahModelCopyWith<SurahModel, SurahModel, SurahModel> get copyWith =>
      _SurahModelCopyWithImpl(this as SurahModel, $identity, $identity);
  @override
  String toString() {
    return SurahModelMapper.ensureInitialized()
        .stringifyValue(this as SurahModel);
  }

  @override
  bool operator ==(Object other) {
    return SurahModelMapper.ensureInitialized()
        .equalsValue(this as SurahModel, other);
  }

  @override
  int get hashCode {
    return SurahModelMapper.ensureInitialized().hashValue(this as SurahModel);
  }
}

extension SurahModelValueCopy<$R, $Out>
    on ObjectCopyWith<$R, SurahModel, $Out> {
  SurahModelCopyWith<$R, SurahModel, $Out> get $asSurahModel =>
      $base.as((v, t, t2) => _SurahModelCopyWithImpl(v, t, t2));
}

abstract class SurahModelCopyWith<$R, $In extends SurahModel, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call(
      {int? id,
      String? name,
      int? startPage,
      int? endPage,
      int? makkia,
      int? type});
  SurahModelCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _SurahModelCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, SurahModel, $Out>
    implements SurahModelCopyWith<$R, SurahModel, $Out> {
  _SurahModelCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<SurahModel> $mapper =
      SurahModelMapper.ensureInitialized();
  @override
  $R call(
          {int? id,
          String? name,
          int? startPage,
          int? endPage,
          int? makkia,
          int? type}) =>
      $apply(FieldCopyWithData({
        if (id != null) #id: id,
        if (name != null) #name: name,
        if (startPage != null) #startPage: startPage,
        if (endPage != null) #endPage: endPage,
        if (makkia != null) #makkia: makkia,
        if (type != null) #type: type
      }));
  @override
  SurahModel $make(CopyWithData data) => SurahModel(
      data.get(#id, or: $value.id),
      data.get(#name, or: $value.name),
      data.get(#startPage, or: $value.startPage),
      data.get(#endPage, or: $value.endPage),
      data.get(#makkia, or: $value.makkia),
      data.get(#type, or: $value.type));

  @override
  SurahModelCopyWith<$R2, SurahModel, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _SurahModelCopyWithImpl($value, $cast, t);
}
