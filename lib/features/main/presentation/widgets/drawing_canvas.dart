import 'dart:math' as math;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:note_app/features/main/domain/entity/sketch_entity.dart';
import 'package:note_app/features/main/presentation/widgets/sketchPainter.dart';
import '../../data/model/drawing_mode.dart';
import '../../data/model/sketch.dart';

class DrawingCanvas extends HookWidget {
  final double height;
  final double width;
  final ValueNotifier<Color> selectedColor;
  final ValueNotifier<double> strokeSize;
  final ValueNotifier<Image?> backgroundImage;
  final ValueNotifier<double> eraserSize;
  final ValueNotifier<DrawingMode> drawingMode;
  final AnimationController sideBarController;
  final ValueNotifier<SketchEntity?> currentSketch;
  final ValueNotifier<List<List<SketchEntity>>> allSketches;
  final GlobalKey canvasGlobalKey;
  final ValueNotifier<int> polygonSides;
  final ValueNotifier<bool> filled;
  final ValueNotifier<bool> isDrawingMode;
  final Key? key;

  DrawingCanvas({
    required this.isDrawingMode,
    required this.height,
    required this.width,
    required this.selectedColor,
    required this.strokeSize,
    required this.backgroundImage,
    required this.eraserSize,
    required this.drawingMode,
    required this.sideBarController,
    required this.currentSketch,
    required this.allSketches,
    required this.canvasGlobalKey,
    required this.polygonSides,
    required this.filled,
    required this.key,


  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final paddingFactor = 0.01;
    final diagonalSize = sqrt(pow(screenWidth, 2) + pow(screenHeight, 2));

    return MouseRegion(
              cursor: SystemMouseCursors.precise,
              child: Stack(
                children: [
                  buildAllSketches(context),
                  if (isDrawingMode.value) buildCurrentPath(context),
                ],
              ),
            );
  }

  void onPointerDown(PointerDownEvent details, BuildContext context) {
    final themeData = Theme.of(context);
    final box = context.findRenderObject() as RenderBox;
    final offset = box.globalToLocal(details.position);
    currentSketch.value = Sketch.fromDrawingMode(
      Sketch(
        points: [offset],
        size: drawingMode.value == DrawingMode.eraser
            ? eraserSize.value
            : strokeSize.value,
        color: drawingMode.value == DrawingMode.eraser
            ? themeData.backgroundColor
            : selectedColor.value,
        sides: polygonSides.value,
      ),
      drawingMode.value,
      filled.value,
    );
  }

  void onPointerMove(PointerMoveEvent details, BuildContext context) {
    final themeData = Theme.of(context);
    final box = context.findRenderObject() as RenderBox;
    final offset = box.globalToLocal(details.position);
    final points = List<Offset>.from(currentSketch.value?.points ?? [])
      ..add(offset);

    currentSketch.value = Sketch.fromDrawingMode(
      Sketch(
        points: points,
        size: drawingMode.value == DrawingMode.eraser
            ? eraserSize.value
            : strokeSize.value,
        color: drawingMode.value == DrawingMode.eraser
            ? themeData.backgroundColor
            : selectedColor.value,
        sides: polygonSides.value,
      ),
      drawingMode.value,
      filled.value,
    );
  }

  void onPointerUp(PointerUpEvent details,BuildContext context) {
    final themeData = Theme.of(context);

    final List<SketchEntity> currentSketchList = currentSketch.value != null
        ? [currentSketch.value!]
        : [];

    allSketches.value = [...allSketches.value, currentSketchList];

    currentSketch.value = Sketch.fromDrawingMode(
      Sketch(
        points: [],
        size: drawingMode.value == DrawingMode.eraser
            ? eraserSize.value
            : strokeSize.value,
        color: drawingMode.value == DrawingMode.eraser
            ? themeData.backgroundColor
            : selectedColor.value,
        sides: polygonSides.value,
      ),
      drawingMode.value,
      filled.value,
    );

  }

  Widget buildAllSketches(BuildContext context) {
    final themeData = Theme.of(context);
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return ValueListenableBuilder<List<List<SketchEntity>>>(
        valueListenable: allSketches,
        builder: (context, sketches, _) {
          return RepaintBoundary(
            key: canvasGlobalKey,
            child: Container(
              width: width,
              height: height,
              color: Colors.transparent,
              child: CustomPaint(
                painter: SketchPainter(
                  sketches: sketches,
                  backgroundImage: backgroundImage.value,
                ),
              ),
            ),
          );
        },
      );
    });
  }

  Widget buildCurrentPath(BuildContext context) {
    return Listener(
      onPointerDown: (details) => onPointerDown(details, context),
      onPointerMove: (details) => onPointerMove(details, context),
      onPointerUp:(details) => onPointerUp(details, context),

      child: ValueListenableBuilder(
        valueListenable: currentSketch,
        builder: (context, sketch, child) {
          final List<SketchEntity> sketchList = sketch != null ? [sketch] : [];
          final List<List<SketchEntity>> nestedSketchList = [sketchList];
          return RepaintBoundary(
            child: SizedBox(
              height: height,
              width: width,
              child: CustomPaint(
                painter: SketchPainter(
                  sketches:nestedSketchList,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

