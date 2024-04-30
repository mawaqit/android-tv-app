import 'package:dart_mappable/dart_mappable.dart';

part 'moshaf_model.mapper.dart';

@MappableClass()
class MoshafModel {
  final int id;
  final String name;
  final String server;
  @MappableField(key: 'surah_total')
  final int surahTotal;
  @MappableField(key: 'moshaf_type')
  final int moshafType;
  @MappableField(key: 'surah_list')
  final String surahList;

  MoshafModel(this.id, this.name, this.server, this.surahTotal,
      this.moshafType, this.surahList);

  factory MoshafModel.fromJson(Map<String, dynamic> map) =>
      _ensureContainer.fromMap<MoshafModel>(map);

  factory MoshafModel.fromString(String json) =>
      _ensureContainer.fromJson<MoshafModel>(json);

  Map<String, dynamic> toJson() {
    return _ensureContainer.toMap(this);
  }

  @override
  String toString() {
    return _ensureContainer.toJson(this);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (runtimeType == other.runtimeType &&
            _ensureContainer.isEqual(this, other));
  }

  @override
  int get hashCode {
    return _ensureContainer.hash(this);
  }

  MoshafModelCopyWith<MoshafModel, MoshafModel, MoshafModel>
      get copyWith {
    return _MoshafModelCopyWithImpl(this, $identity, $identity);
  }

  static final MapperContainer _ensureContainer = () {
    MoshafModelMapper.ensureInitialized();
    return MapperContainer.globals;
  }();

  static MoshafModelMapper ensureInitialized() =>
      MoshafModelMapper.ensureInitialized();
}
