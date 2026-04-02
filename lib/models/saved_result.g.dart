// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_result.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SavedResultAdapter extends TypeAdapter<SavedResult> {
  @override
  final int typeId = 1;

  @override
  SavedResult read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SavedResult(
      id: fields[0] as String,
      siteKey: fields[1] as String,
      siteName: fields[2] as String,
      url: fields[3] as String,
      query: fields[4] as String,
      savedAt: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, SavedResult obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.siteKey)
      ..writeByte(2)
      ..write(obj.siteName)
      ..writeByte(3)
      ..write(obj.url)
      ..writeByte(4)
      ..write(obj.query)
      ..writeByte(5)
      ..write(obj.savedAt);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavedResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}
