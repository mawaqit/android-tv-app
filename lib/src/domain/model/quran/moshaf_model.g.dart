// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moshaf_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MoshafModelAdapter extends TypeAdapter<MoshafModel> {
  @override
  final int typeId = 3;

  @override
  MoshafModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MoshafModel(
      fields[0] as int,
      fields[1] as String,
      fields[2] as String,
      fields[3] as int,
      fields[4] as int,
      (fields[5] as List).cast<int>(),
    );
  }

  @override
  void write(BinaryWriter writer, MoshafModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.server)
      ..writeByte(3)
      ..write(obj.surahTotal)
      ..writeByte(4)
      ..write(obj.moshafType)
      ..writeByte(5)
      ..write(obj.surahList);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MoshafModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
