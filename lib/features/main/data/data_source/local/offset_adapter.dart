import 'dart:ui';

import 'package:hive/hive.dart';

class OffsetAdapter extends TypeAdapter<Offset> {
  @override
  final typeId = 100; // You can choose any unique positive integer here

  @override
  Offset read(BinaryReader reader) {
    final dx = reader.readDouble();
    final dy = reader.readDouble();
    return Offset(dx, dy);
  }

  @override
  void write(BinaryWriter writer, Offset obj) {
    writer.writeDouble(obj.dx);
    writer.writeDouble(obj.dy);
  }
}