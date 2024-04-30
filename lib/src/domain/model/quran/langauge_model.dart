import 'package:dart_mappable/dart_mappable.dart';

part 'langauge_model.mapper.dart';

@MappableClass()
class LangaugeModel {
  final String id;
  final String language;
  final String surah;
  final String rewayah;
  final String reciters;
  final String tafasir;

  LangaugeModel(this.id, this.language, this.surah, this.rewayah,
      this.reciters, this.tafasir);

  factory LangaugeModel.fromJson(Map<String, dynamic> map) =>
      _ensureContainer.fromMap<LangaugeModel>(map);

  factory LangaugeModel.fromString(String json) =>
      _ensureContainer.fromJson<LangaugeModel>(json);

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

  LangaugeModelCopyWith<LangaugeModel, LangaugeModel, LangaugeModel>
      get copyWith {
    return _LangaugeModelCopyWithImpl(this, $identity, $identity);
  }

  static final MapperContainer _ensureContainer = () {
    LangaugeModelMapper.ensureInitialized();
    return MapperContainer.globals;
  }();

  static LangaugeModelMapper ensureInitialized() =>
      LangaugeModelMapper.ensureInitialized();
}
