import 'package:hive/hive.dart';
import '../../model/sketch.dart';


class SketchTypeAdapter extends TypeAdapter<SketchType> {
  @override
  final typeId = 102; // Choose any unique positive integer here

  @override
  SketchType read(BinaryReader reader) {
    final index = reader.readInt();
    return SketchType.values[index];
  }

  @override
  void write(BinaryWriter writer, SketchType obj) {
    writer.writeInt(obj.index);
  }
}