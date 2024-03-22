// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NoteAdapter extends TypeAdapter<Data> {
  @override
  final int typeId = 14;

  @override
  Data read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Data(
      fields[0] as String,
      fields[1] as DateTime,
      (fields[3] as List).cast<int>(),
      (fields[4] as List).cast<String>(),
      (fields[2] as List).cast<String>(),
      (fields[5] as List).cast<String>(),
    )
      ..drawingDataList = (fields[6] as List)
          .map((dynamic e) => (e as List).cast<DrawingData>())
          .toList()
      ..elementOrder = (fields[7] as List).cast<int>();
  }

  @override
  void write(BinaryWriter writer, Data obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.dateTime)
      ..writeByte(2)
      ..write(obj.text)
      ..writeByte(3)
      ..write(obj.drawingBytes)
      ..writeByte(4)
      ..write(obj.imagePath)
      ..writeByte(5)
      ..write(obj.videoPath)
      ..writeByte(6)
      ..write(obj.drawingDataList)
      ..writeByte(7)
      ..write(obj.elementOrder);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NoteAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
