import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'dart:ui';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:note_app/core/utils/images/svg_logos.dart';
import 'package:note_app/features/main/domain/entity/sketch_entity.dart';
import '../../data/model/drawing_mode.dart';
import '../../data/model/sketch.dart';
import 'color_palette.dart';

class CanvasSideBar extends HookWidget {
  final ValueNotifier<Color> selectedColor;
  final ValueNotifier<double> strokeSize;
  final ValueNotifier<double> eraserSize;
  final ValueNotifier<DrawingMode> drawingMode;
  final ValueNotifier<SketchEntity?> currentSketch;
  final ValueNotifier<List<List<SketchEntity>>> allSketches;
  final GlobalKey canvasGlobalKey;
  final ValueNotifier<bool> filled;
  final ValueNotifier<int> polygonSides;
  final ValueNotifier<Image?> backgroundImage;

  const CanvasSideBar({
    Key? key,
    required this.selectedColor,
    required this.strokeSize,
    required this.eraserSize,
    required this.drawingMode,
    required this.currentSketch,
    required this.allSketches,
    required this.canvasGlobalKey,
    required this.filled,
    required this.polygonSides,
    required this.backgroundImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    double diagonalSize = sqrt(pow(screenWidth, 2) + pow(screenHeight, 2));
    double paddingFactor = 0.01;

    final undoRedoStack = useState(
      _UndoRedoStack(
        sketchesNotifier: allSketches,
        currentSketchNotifier: currentSketch,
      ),
    );
    final scrollController = useScrollController();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Container(
            height: diagonalSize * 0.13,
            width: screenWidth,
            decoration: BoxDecoration(
              color: themeData.backgroundColor,
              borderRadius: BorderRadius.circular(paddingFactor),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                InkWell(
                  onTap: () {
                    drawingMode.value = DrawingMode.pencil;
                    strokeSize.value = diagonalSize * 0.01;
                  },
                  child: SvgPicture.string(
                    brush,
                    height: diagonalSize * 0.15,
                  ),
                ),
                InkWell(
                  onTap: () {
                    drawingMode.value = DrawingMode.pencil;
                    strokeSize.value = diagonalSize * 0.03;
                  },
                  child: SvgPicture.string(
                    linePen,
                    height: diagonalSize * 0.15,
                  ),
                ),
                InkWell(
                  onTap: () {
                    drawingMode.value = DrawingMode.line;
                  },
                  child: SvgPicture.string(
                    firstPen,
                    height: diagonalSize * 0.15,
                  ),
                ),
                Wrap(
                  children: [
                    _IconBox(
                      iconData: CupertinoIcons.delete_simple,
                      selected: drawingMode.value == DrawingMode.eraser,
                      onTap: () => drawingMode.value = DrawingMode.eraser,
                      tooltip: 'Eraser',
                    ),
                    TextButton(
                      onPressed: allSketches.value.isNotEmpty
                          ? () => undoRedoStack.value.undo()
                          : null,
                      child: const Text('Undo'),
                    ),
                    ValueListenableBuilder<bool>(
                      valueListenable: undoRedoStack.value.canRedo,
                      builder: (_, canRedo, __) {
                        return TextButton(
                          onPressed: canRedo
                              ? () => undoRedoStack.value.redo()
                              : null,
                          child: const Text('Redo'),
                        );
                      },
                    ),
                    TextButton(
                      child: const Text('Clear'),
                      onPressed: () => undoRedoStack.value.clear(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: ColorPalette(selectedColor: selectedColor),
        ),
      ],
    );
  }
}

class _IconBox extends StatelessWidget {
  final IconData? iconData;
  final Widget? child;
  final bool selected;
  final VoidCallback onTap;
  final String? tooltip;

  const _IconBox({
    Key? key,
    this.iconData,
    this.child,
    this.tooltip,
    required this.selected,
    required this.onTap,
  })  : assert(child != null || iconData != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 35,
          width: 35,
          decoration: BoxDecoration(
            border: Border.all(
              color: selected ? Colors.grey[900]! : Colors.grey,
              width: 1.5,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(5)),
          ),
          child: Tooltip(
            message: tooltip,
            preferBelow: false,
            child: child ??
                Icon(
                  iconData,
                  color: selected ? Colors.grey[900] : Colors.grey,
                  size: 20,
                ),
          ),
        ),
      ),
    );
  }
}

///A data structure for undoing and redoing sketches.
class _UndoRedoStack {
  _UndoRedoStack({
    required this.sketchesNotifier,
    required this.currentSketchNotifier,
  }) {
    _sketchCount = sketchesNotifier.value.length;
    sketchesNotifier.addListener(_sketchesCountListener);
  }

  final ValueNotifier<List<List<SketchEntity>>> sketchesNotifier;
  final ValueNotifier<SketchEntity?> currentSketchNotifier;

  ///Collection of sketches that can be redone.
  final List<List<Sketch>> _redoStacks = [];

  ///Whether redo operation is possible.
  final ValueNotifier<bool> canRedo = ValueNotifier(false);

  late int _sketchCount;

  void _sketchesCountListener() {
    if (sketchesNotifier.value.length > _sketchCount) {
      //if a new sketch is drawn,
      //history is invalidated so clear redo stack
      _redoStacks.clear();
      canRedo.value = false;
      _sketchCount = sketchesNotifier.value.length;
    }
  }

  void clear() {
    _sketchCount = 0;
    sketchesNotifier.value = [];
    canRedo.value = false;
    currentSketchNotifier.value = null;
  }

  void undo() {
    final sketches = List<List<Sketch>>.from(sketchesNotifier.value);
    if (sketches.isNotEmpty) {
      _sketchCount--;
      _redoStacks.add(sketches.removeLast());
      sketchesNotifier.value = sketches;
      canRedo.value = true;
      currentSketchNotifier.value = null;
    }
  }

  void redo() {
    if (_redoStacks.isEmpty) return;
    final sketch = _redoStacks.removeLast();
    canRedo.value = _redoStacks.isNotEmpty;
    _sketchCount++;
    sketchesNotifier.value = [...sketchesNotifier.value, sketch];
  }

  void dispose() {
    sketchesNotifier.removeListener(_sketchesCountListener);
  }
}
