// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reciter_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReciterModelAdapter extends TypeAdapter<ReciterModel> {
  @override
  final int typeId = 2;

  @override
  ReciterModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReciterModel(
      fields[0] as int,
      fields[1] as String,
      fields[2] as String,
      (fields[3] as List).cast<MoshafModel>(),
    );
  }

  @override
  void write(BinaryWriter writer, ReciterModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.letter)
      ..writeByte(3)
      ..write(obj.moshaf);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReciterModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
