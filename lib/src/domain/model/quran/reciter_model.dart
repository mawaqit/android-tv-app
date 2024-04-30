import 'package:dart_mappable/dart_mappable.dart';

import 'moshaf_model.dart';

part 'reciter_model.mapper.dart';

@MappableClass()
class ReciterModel {
  final int id;
  final String name;
  final String letter;
  final List<MoshafModel> moshaf;

  ReciterModel(this.id, this.name, this.letter, this.moshaf);

  factory ReciterModel.fromJson(Map<String, dynamic> map) =>
      _ensureContainer.fromMap<ReciterModel>(map);

  factory ReciterModel.fromString(String json) =>
      _ensureContainer.fromJson<ReciterModel>(json);

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

  ReciterModelCopyWith<ReciterModel, ReciterModel, ReciterModel>
      get copyWith {
    return _ReciterModelCopyWithImpl(this, $identity, $identity);
  }

  static final MapperContainer _ensureContainer = () {
    ReciterModelMapper.ensureInitialized();
    return MapperContainer.globals;
  }();

  static ReciterModelMapper ensureInitialized() =>
      ReciterModelMapper.ensureInitialized();
}
