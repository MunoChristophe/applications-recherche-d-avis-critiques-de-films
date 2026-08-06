// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_query.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SearchQueryAdapter extends TypeAdapter<SearchQuery> {
  @override
  final int typeId = 0;

  @override
  SearchQuery read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SearchQuery(
      id: fields[0] as String,
      genre: fields[1] as String?,
      title: fields[2] as String?,
      keywords: fields[3] as String?,
      createdAt: fields[4] as DateTime,
      siteKeys: (fields[5] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, SearchQuery obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.genre)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.keywords)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.siteKeys);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchQueryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;

  @override
  int get hashCode => typeId.hashCode;
}
