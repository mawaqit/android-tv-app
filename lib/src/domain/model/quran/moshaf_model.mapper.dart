// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'moshaf_model.dart';

class MoshafModelMapper extends ClassMapperBase<MoshafModel> {
  MoshafModelMapper._();

  static MoshafModelMapper? _instance;
  static MoshafModelMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = MoshafModelMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'MoshafModel';

  static int _$id(MoshafModel v) => v.id;
  static const Field<MoshafModel, int> _f$id = Field('id', _$id);
  static String _$name(MoshafModel v) => v.name;
  static const Field<MoshafModel, String> _f$name = Field('name', _$name);
  static String _$server(MoshafModel v) => v.server;
  static const Field<MoshafModel, String> _f$server = Field('server', _$server);
  static int _$surahTotal(MoshafModel v) => v.surahTotal;
  static const Field<MoshafModel, int> _f$surahTotal =
      Field('surahTotal', _$surahTotal, key: r'surah_total');
  static int _$moshafType(MoshafModel v) => v.moshafType;
  static const Field<MoshafModel, int> _f$moshafType =
      Field('moshafType', _$moshafType, key: r'moshaf_type');
  static List<int> _$surahList(MoshafModel v) => v.surahList;
  static const Field<MoshafModel, List<int>> _f$surahList =
      Field('surahList', _$surahList, key: r'surah_list');

  @override
  final MappableFields<MoshafModel> fields = const {
    #id: _f$id,
    #name: _f$name,
    #server: _f$server,
    #surahTotal: _f$surahTotal,
    #moshafType: _f$moshafType,
    #surahList: _f$surahList,
  };

  static MoshafModel _instantiate(DecodingData data) {
    return MoshafModel(
        data.dec(_f$id),
        data.dec(_f$name),
        data.dec(_f$server),
        data.dec(_f$surahTotal),
        data.dec(_f$moshafType),
        data.dec(_f$surahList));
  }

  @override
  final Function instantiate = _instantiate;

  static MoshafModel fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<MoshafModel>(map);
  }

  static MoshafModel fromJson(String json) {
    return ensureInitialized().decodeJson<MoshafModel>(json);
  }
}

mixin MoshafModelMappable {
  String toJson() {
    return MoshafModelMapper.ensureInitialized()
        .encodeJson<MoshafModel>(this as MoshafModel);
  }

  Map<String, dynamic> toMap() {
    return MoshafModelMapper.ensureInitialized()
        .encodeMap<MoshafModel>(this as MoshafModel);
  }

  MoshafModelCopyWith<MoshafModel, MoshafModel, MoshafModel> get copyWith =>
      _MoshafModelCopyWithImpl(this as MoshafModel, $identity, $identity);
  @override
  String toString() {
    return MoshafModelMapper.ensureInitialized()
        .stringifyValue(this as MoshafModel);
  }

  @override
  bool operator ==(Object other) {
    return MoshafModelMapper.ensureInitialized()
        .equalsValue(this as MoshafModel, other);
  }

  @override
  int get hashCode {
    return MoshafModelMapper.ensureInitialized().hashValue(this as MoshafModel);
  }
}

extension MoshafModelValueCopy<$R, $Out>
    on ObjectCopyWith<$R, MoshafModel, $Out> {
  MoshafModelCopyWith<$R, MoshafModel, $Out> get $asMoshafModel =>
      $base.as((v, t, t2) => _MoshafModelCopyWithImpl(v, t, t2));
}

abstract class MoshafModelCopyWith<$R, $In extends MoshafModel, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, int, ObjectCopyWith<$R, int, int>> get surahList;
  $R call(
      {int? id,
      String? name,
      String? server,
      int? surahTotal,
      int? moshafType,
      List<int>? surahList});
  MoshafModelCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _MoshafModelCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, MoshafModel, $Out>
    implements MoshafModelCopyWith<$R, MoshafModel, $Out> {
  _MoshafModelCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<MoshafModel> $mapper =
      MoshafModelMapper.ensureInitialized();
  @override
  ListCopyWith<$R, int, ObjectCopyWith<$R, int, int>> get surahList =>
      ListCopyWith($value.surahList, (v, t) => ObjectCopyWith(v, $identity, t),
          (v) => call(surahList: v));
  @override
  $R call(
          {int? id,
          String? name,
          String? server,
          int? surahTotal,
          int? moshafType,
          List<int>? surahList}) =>
      $apply(FieldCopyWithData({
        if (id != null) #id: id,
        if (name != null) #name: name,
        if (server != null) #server: server,
        if (surahTotal != null) #surahTotal: surahTotal,
        if (moshafType != null) #moshafType: moshafType,
        if (surahList != null) #surahList: surahList
      }));
  @override
  MoshafModel $make(CopyWithData data) => MoshafModel(
      data.get(#id, or: $value.id),
      data.get(#name, or: $value.name),
      data.get(#server, or: $value.server),
      data.get(#surahTotal, or: $value.surahTotal),
      data.get(#moshafType, or: $value.moshafType),
      data.get(#surahList, or: $value.surahList));

  @override
  MoshafModelCopyWith<$R2, MoshafModel, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _MoshafModelCopyWithImpl($value, $cast, t);
}
