import 'package:dart_mappable/dart_mappable.dart';
import 'package:hive_flutter/adapters.dart';

part 'surah_model.mapper.dart';
part 'surah_model.g.dart';

@HiveType(typeId: 1)
@MappableClass()
class SurahModel {

  @HiveField(0)
  final int id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  @MappableField(key: 'start_page')
  final int startPage;

  @HiveField(3)
  @MappableField(key: 'end_page')
  final int endPage;

  @HiveField(4)
  final int makkia;

  @HiveField(5)
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

  String getSurahUrl(String serverUrl) {
    // Convert the surah ID to a string
    String surahIdStr = id.toString().padLeft(3, '0');

    String surahUrl = "$serverUrl$surahIdStr.mp3";

    return surahUrl;
  }
}
