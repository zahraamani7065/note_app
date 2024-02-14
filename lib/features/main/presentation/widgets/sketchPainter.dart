import 'package:flutter/cupertino.dart';

import '../../data/model/sketch.dart';

class SketchPainter extends CustomPainter{
  final List<Sketch> sketches;

  SketchPainter(this.sketches);

  @override
  void paint(Canvas canvas, Size size) {

  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }


}