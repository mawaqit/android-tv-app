// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'reciter_model.dart';

class ReciterModelMapper extends ClassMapperBase<ReciterModel> {
  ReciterModelMapper._();

  static ReciterModelMapper? _instance;
  static ReciterModelMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ReciterModelMapper._());
      MoshafModelMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'ReciterModel';

  static int _$id(ReciterModel v) => v.id;
  static const Field<ReciterModel, int> _f$id = Field('id', _$id);
  static String _$name(ReciterModel v) => v.name;
  static const Field<ReciterModel, String> _f$name = Field('name', _$name);
  static String _$letter(ReciterModel v) => v.letter;
  static const Field<ReciterModel, String> _f$letter =
      Field('letter', _$letter);
  static List<MoshafModel> _$moshaf(ReciterModel v) => v.moshaf;
  static const Field<ReciterModel, List<MoshafModel>> _f$moshaf =
      Field('moshaf', _$moshaf);

  @override
  final MappableFields<ReciterModel> fields = const {
    #id: _f$id,
    #name: _f$name,
    #letter: _f$letter,
    #moshaf: _f$moshaf,
  };

  static ReciterModel _instantiate(DecodingData data) {
    return ReciterModel(data.dec(_f$id), data.dec(_f$name), data.dec(_f$letter),
        data.dec(_f$moshaf));
  }

  @override
  final Function instantiate = _instantiate;

  static ReciterModel fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ReciterModel>(map);
  }

  static ReciterModel fromJson(String json) {
    return ensureInitialized().decodeJson<ReciterModel>(json);
  }
}

mixin ReciterModelMappable {
  String toJson() {
    return ReciterModelMapper.ensureInitialized()
        .encodeJson<ReciterModel>(this as ReciterModel);
  }

  Map<String, dynamic> toMap() {
    return ReciterModelMapper.ensureInitialized()
        .encodeMap<ReciterModel>(this as ReciterModel);
  }

  ReciterModelCopyWith<ReciterModel, ReciterModel, ReciterModel> get copyWith =>
      _ReciterModelCopyWithImpl(this as ReciterModel, $identity, $identity);
  @override
  String toString() {
    return ReciterModelMapper.ensureInitialized()
        .stringifyValue(this as ReciterModel);
  }

  @override
  bool operator ==(Object other) {
    return ReciterModelMapper.ensureInitialized()
        .equalsValue(this as ReciterModel, other);
  }

  @override
  int get hashCode {
    return ReciterModelMapper.ensureInitialized()
        .hashValue(this as ReciterModel);
  }
}

extension ReciterModelValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ReciterModel, $Out> {
  ReciterModelCopyWith<$R, ReciterModel, $Out> get $asReciterModel =>
      $base.as((v, t, t2) => _ReciterModelCopyWithImpl(v, t, t2));
}

abstract class ReciterModelCopyWith<$R, $In extends ReciterModel, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, MoshafModel,
      MoshafModelCopyWith<$R, MoshafModel, MoshafModel>> get moshaf;
  $R call({int? id, String? name, String? letter, List<MoshafModel>? moshaf});
  ReciterModelCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _ReciterModelCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ReciterModel, $Out>
    implements ReciterModelCopyWith<$R, ReciterModel, $Out> {
  _ReciterModelCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ReciterModel> $mapper =
      ReciterModelMapper.ensureInitialized();
  @override
  ListCopyWith<$R, MoshafModel,
          MoshafModelCopyWith<$R, MoshafModel, MoshafModel>>
      get moshaf => ListCopyWith($value.moshaf, (v, t) => v.copyWith.$chain(t),
          (v) => call(moshaf: v));
  @override
  $R call({int? id, String? name, String? letter, List<MoshafModel>? moshaf}) =>
      $apply(FieldCopyWithData({
        if (id != null) #id: id,
        if (name != null) #name: name,
        if (letter != null) #letter: letter,
        if (moshaf != null) #moshaf: moshaf
      }));
  @override
  ReciterModel $make(CopyWithData data) => ReciterModel(
      data.get(#id, or: $value.id),
      data.get(#name, or: $value.name),
      data.get(#letter, or: $value.letter),
      data.get(#moshaf, or: $value.moshaf));

  @override
  ReciterModelCopyWith<$R2, ReciterModel, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _ReciterModelCopyWithImpl($value, $cast, t);
}
