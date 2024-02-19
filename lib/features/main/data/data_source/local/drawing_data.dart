
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../model/sketch.dart';
part 'drawing_data.g.dart';


@HiveType(adapterName: "DrawingAdapter", typeId: 1)
class DrawingData{
  @HiveField(0)
  final List<Offset> points=[];
  @HiveField(1)
  final Color color=Colors.black;


  @HiveField(2)
  final double size=1.0;

  @HiveField(3)
  final SketchType type=SketchType.line;

  @HiveField(4)
  final bool filled=false;

  @HiveField(5)
  final int sides=1;

}