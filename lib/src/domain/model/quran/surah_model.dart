import 'package:dart_mappable/dart_mappable.dart';

part 'surah_model.mapper.dart';

@MappableClass()
class SurahModel {
  final int id;
  final String name;
  @MappableField(key: 'start_page')
  final int startPage;
  @MappableField(key: 'end_page')
  final int endPage;
  final int makkia;
  final int type;

  SurahModel(this.id, this.name, this.startPage, this.endPage,
      this.makkia, this.type);

  factory SurahModel.fromJson(Map<String, dynamic> map) =>
      _ensureContainer.fromMap<SurahModel>(map);

  factory SurahModel.fromString(String json) =>
      _ensureContainer.fromJson<SurahModel>(json);

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

  SurahModelCopyWith<SurahModel, SurahModel, SurahModel>
      get copyWith {
    return _SurahModelCopyWithImpl(this, $identity, $identity);
  }

  static final MapperContainer _ensureContainer = () {
    SurahModelMapper.ensureInitialized();
    return MapperContainer.globals;
  }();

  static SurahModelMapper ensureInitialized() =>
      SurahModelMapper.ensureInitialized();
}
