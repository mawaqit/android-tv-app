import 'package:dart_mappable/dart_mappable.dart';
import 'package:hive_flutter/adapters.dart';

part 'moshaf_model.mapper.dart';

part 'moshaf_model.g.dart';

@HiveType(typeId: 3)
@MappableClass()
class MoshafModel {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String server;

  @HiveField(3)
  @MappableField(key: 'surah_total')
  final int surahTotal;

  @HiveField(4)
  @MappableField(key: 'moshaf_type')
  final int moshafType;

  @HiveField(5)
  @MappableField(key: 'surah_list')
  final List<int> surahList;

  MoshafModel(this.id, String name, this.server, this.surahTotal, this.moshafType, this.surahList)
      :
        // Clean up the name property to remove duplicates
        name = _removeDuplicateSubstrings(name);

  factory MoshafModel.fromJson(Map<String, dynamic> map) => _ensureContainer.fromMap<MoshafModel>(map);

  factory MoshafModel.fromString(String json) => _ensureContainer.fromJson<MoshafModel>(json);

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

  MoshafModelCopyWith<MoshafModel, MoshafModel, MoshafModel> get copyWith {
    return _MoshafModelCopyWithImpl(this, $identity, $identity);
  }

  static final MapperContainer _ensureContainer = () {
    MoshafModelMapper.ensureInitialized();
    return MapperContainer.globals;
  }();

  static MoshafModelMapper ensureInitialized() => MoshafModelMapper.ensureInitialized();

  // Method to remove duplicate substrings
  static String _removeDuplicateSubstrings(String input) {
    // Regular expression to find repeated substrings
    final RegExp regex = RegExp(r'(.*) - \1');

    // Replace duplicates with the first occurrence
    String result = input.replaceAllMapped(regex, (match) => match.group(1)!);

    return result;
  }
}
