import 'dart:ui';
import 'package:flutter/material.dart';

import '../../data/model/sketch.dart';


class SketchEntity {
  final List<Offset> points;
  final Color color;
  final double size;
  final SketchType type;
  final bool filled;
  final int sides;

  SketchEntity({
    required this.points,
    this.color = Colors.black,
    this.type = SketchType.scribble,
    this.filled = true,
    this.sides = 3,
    required this.size,
  });
}