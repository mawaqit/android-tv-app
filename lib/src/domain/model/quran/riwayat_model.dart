import 'package:dart_mappable/dart_mappable.dart';

part 'riwayat_model.mapper.dart';

@MappableClass()
class RiwayatModel {
  final int id;
  final String name;

  RiwayatModel(this.id, this.name);

  factory RiwayatModel.fromJson(Map<String, dynamic> map) =>
      _ensureContainer.fromMap<RiwayatModel>(map);

  factory RiwayatModel.fromString(String json) =>
      _ensureContainer.fromJson<RiwayatModel>(json);

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

  RiwayatModelCopyWith<RiwayatModel, RiwayatModel, RiwayatModel>
      get copyWith {
    return _RiwayatModelCopyWithImpl(this, $identity, $identity);
  }

  static final MapperContainer _ensureContainer = () {
    RiwayatModelMapper.ensureInitialized();
    return MapperContainer.globals;
  }();

  static RiwayatModelMapper ensureInitialized() =>
      RiwayatModelMapper.ensureInitialized();
}
