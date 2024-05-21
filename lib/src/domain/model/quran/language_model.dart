import 'package:dart_mappable/dart_mappable.dart';

part 'language_model.mapper.dart';

@MappableClass()
class LanguageModel {
  final String id;
  final String language;
  final String native;
  final String locale;
  final String surah;
  final String rewayah;
  final String reciters;
  final String tafasir;

  LanguageModel(
      this.id, this.language, this.native, this.locale, this.surah, this.rewayah, this.reciters, this.tafasir);

  factory LanguageModel.fromJson(Map<String, dynamic> map) => _ensureContainer.fromMap<LanguageModel>(map);

  factory LanguageModel.fromString(String json) => _ensureContainer.fromJson<LanguageModel>(json);

  Map<String, dynamic> toJson() {
    return _ensureContainer.toMap(this);
  }

  @override
  String toString() {
    return _ensureContainer.toJson(this);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || (runtimeType == other.runtimeType && _ensureContainer.isEqual(this, other));
  }

  @override
  int get hashCode {
    return _ensureContainer.hash(this);
  }

  LanguageModelCopyWith<LanguageModel, LanguageModel, LanguageModel> get copyWith {
    return _LanguageModelCopyWithImpl(this, $identity, $identity);
  }

  static final MapperContainer _ensureContainer = () {
    LanguageModelMapper.ensureInitialized();
    return MapperContainer.globals;
  }();

  static LanguageModelMapper ensureInitialized() => LanguageModelMapper.ensureInitialized();
}
