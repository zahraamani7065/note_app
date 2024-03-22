import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../model/sketch.dart';
part 'drawing_data.g.dart';

@HiveType(adapterName: "DrawingAdapter", typeId:15)
class DrawingData {
  @HiveField(0)
   List<Offset> points = [];

  @HiveField(1)
   Color color = Colors.black;

  @HiveField(2)
  double size = 1.0;

  @HiveField(3)
   SketchType type = SketchType.line;

  @HiveField(4)
   bool filled = false;

  @HiveField(5)
   int sides = 1;

  DrawingData(
      {required this.points,
      required this.color,
      required this.size,
      required this.type,
      required this.filled,
      required this.sides});
}
