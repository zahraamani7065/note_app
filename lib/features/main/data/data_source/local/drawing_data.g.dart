// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drawing_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DrawingAdapter extends TypeAdapter<DrawingData> {
  @override
  final int typeId = 1;

  @override
  DrawingData read(BinaryReader reader) {
    return DrawingData();
  }

  @override
  void write(BinaryWriter writer, DrawingData obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.points)
      ..writeByte(1)
      ..write(obj.color)
      ..writeByte(2)
      ..write(obj.size)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.filled)
      ..writeByte(5)
      ..write(obj.sides);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DrawingAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
