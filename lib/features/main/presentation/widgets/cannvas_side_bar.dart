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
  final ValueNotifier<List<SketchEntity>> allSketches;
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
    final bool selectedpen=false;
    final bool selectedLine=false;
    bool selectedBrush=false;

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
                    onTap: (){
                      selectedBrush=true;
                      drawingMode.value = DrawingMode.pencil;
                      strokeSize.value=diagonalSize*0.01;
                    },
                    child: SvgPicture.string(
                      brush,
                      height: (selectedBrush=true) ? diagonalSize * 0.18 :diagonalSize * 0.15,
                    ),
                  ),


                  InkWell(
                    onTap: (){
                      drawingMode.value = DrawingMode.pencil;
                      strokeSize.value=diagonalSize*0.03;
                    },
                    child: SvgPicture.string(
                      linePen,
                      height: diagonalSize * 0.15,
                    ),
                  ),
                  InkWell(
                    onTap: (){
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
                        valueListenable: undoRedoStack.value._canRedo,
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
                child: ColorPalette(selectedColor: selectedColor)),

        ]);
    // return Container(
    //   width: 300,
    //   height: MediaQuery.of(context).size.height < 680 ? 450 : 610,
    //   decoration: BoxDecoration(
    //     color: Colors.white,
    //     borderRadius: const BorderRadius.horizontal(right: Radius.circular(10)),
    //     boxShadow: [
    //       BoxShadow(
    //         color: Colors.grey.shade200,
    //         blurRadius: 3,
    //         offset: const Offset(3, 3),
    //       ),
    //     ],
    //   ),
    //   child:
    //   Container(
    //     // controller: scrollController,
    //     // thumbVisibility: true,
    //     // trackVisibility: true,
    //     child: ListView(
    //       padding: const EdgeInsets.all(10.0),
    //       controller: scrollController,
    //       children: [
    //         const SizedBox(height: 10),
    //         const Text(
    //           'Shapes',
    //           style: TextStyle(fontWeight: FontWeight.bold),
    //         ),
    //         const Divider(),
    //         Wrap(
    //           alignment: WrapAlignment.start,
    //           spacing: 5,
    //           runSpacing: 5,
    //           children: [
    //             _IconBox(
    //               iconData: FontAwesomeIcons.pencil,
    //               selected: drawingMode.value == DrawingMode.pencil,
    //               onTap: () => drawingMode.value = DrawingMode.pencil,
    //               tooltip: 'Pencil',
    //             ),
    //             _IconBox(
    //               selected: drawingMode.value == DrawingMode.line,
    //               onTap: () => drawingMode.value = DrawingMode.line,
    //               tooltip: 'Line',
    //               child: Column(
    //                 mainAxisAlignment: MainAxisAlignment.center,
    //                 children: [
    //                   Container(
    //                     width: 22,
    //                     height: 2,
    //                     color: drawingMode.value == DrawingMode.line
    //                         ? Colors.grey[900]
    //                         : Colors.grey,
    //                   ),
    //                 ],
    //               ),
    //             ),
    //
    //             _IconBox(
    //               iconData: FontAwesomeIcons.eraser,
    //               selected: drawingMode.value == DrawingMode.eraser,
    //               onTap: () => drawingMode.value = DrawingMode.eraser,
    //               tooltip: 'Eraser',
    //             ),
    //           ],
    //         ),
    //         const SizedBox(height: 8),
    //         Row(
    //           children: [
    //             const Text(
    //               'Fill Shape: ',
    //               style: TextStyle(fontSize: 12),
    //             ),
    //             Checkbox(
    //               value: filled.value,
    //               onChanged: (val) {
    //                 filled.value = val ?? false;
    //               },
    //             ),
    //           ],
    //         ),
    //
    //         AnimatedSwitcher(
    //           duration: const Duration(milliseconds: 150),
    //           child: drawingMode.value == DrawingMode.polygon
    //               ? Row(
    //             children: [
    //               const Text(
    //                 'Polygon Sides: ',
    //                 style: TextStyle(fontSize: 12),
    //               ),
    //               Slider(
    //                 value: polygonSides.value.toDouble(),
    //                 min: 3,
    //                 max: 8,
    //                 onChanged: (val) {
    //                   polygonSides.value = val.toInt();
    //                 },
    //                 label: '${polygonSides.value}',
    //                 divisions: 5,
    //               ),
    //             ],
    //           )
    //               : const SizedBox.shrink(),
    //         ),
    //         const SizedBox(height: 10),
    //         const Text(
    //           'Colors',
    //           style: TextStyle(fontWeight: FontWeight.bold),
    //         ),
    //         const Divider(),
    //         ColorPalette(
    //           selectedColor: selectedColor,
    //         ),
    //         const SizedBox(height: 20),
    //         const Text(
    //           'Size',
    //           style: TextStyle(fontWeight: FontWeight.bold),
    //         ),
    //         const Divider(),
    //         Row(
    //           children: [
    //             const Text(
    //               'Stroke Size: ',
    //               style: TextStyle(fontSize: 12),
    //             ),
    //             Slider(
    //               value: strokeSize.value,
    //               min: 0,
    //               max: 50,
    //               onChanged: (val) {
    //                 strokeSize.value = val;
    //               },
    //             ),
    //           ],
    //         ),
    //         Row(
    //           children: [
    //             const Text(
    //               'Eraser Size: ',
    //               style: TextStyle(fontSize: 12),
    //             ),
    //             Slider(
    //               value: eraserSize.value,
    //               min: 0,
    //               max: 80,
    //               onChanged: (val) {
    //                 eraserSize.value = val;
    //               },
    //             ),
    //           ],
    //         ),
    //         const SizedBox(height: 20),
    //         const Text(
    //           'Actions',
    //           style: TextStyle(fontWeight: FontWeight.bold),
    //         ),
    //         const Divider(),
    //         Wrap(
    //           children: [
    //             TextButton(
    //               onPressed: allSketches.value.isNotEmpty
    //                   ? () => undoRedoStack.value.undo()
    //                   : null,
    //               child: const Text('Undo'),
    //             ),
    //             ValueListenableBuilder<bool>(
    //               valueListenable: undoRedoStack.value._canRedo,
    //               builder: (_, canRedo, __) {
    //                 return TextButton(
    //                   onPressed:
    //                   canRedo ? () => undoRedoStack.value.redo() : null,
    //                   child: const Text('Redo'),
    //                 );
    //               },
    //             ),
    //             TextButton(
    //               child: const Text('Clear'),
    //               onPressed: () => undoRedoStack.value.clear(),
    //             ),
    //
    //
    //           ],
    //         ),
    //         //////////////////////
    //
    //
    //         const SizedBox(height: 20),
    //         const Text(
    //           'Export',
    //           style: TextStyle(fontWeight: FontWeight.bold),
    //         ),
    //         const Divider(),
    //         Row(
    //           children: [
    //             SizedBox(
    //               width: 140,
    //               child: TextButton(
    //                 child: const Text('Export PNG'),
    //                 onPressed: () async {
    //                   Uint8List? pngBytes = await getBytes();
    //                   if (pngBytes != null) saveFile(pngBytes, 'png');
    //                 },
    //               ),
    //             ),
    //             SizedBox(
    //               width: 140,
    //               child: TextButton(
    //                 child: const Text('Export JPEG'),
    //                 onPressed: () async {
    //                   Uint8List? pngBytes = await getBytes();
    //                   if (pngBytes != null) saveFile(pngBytes, 'jpeg');
    //                 },
    //               ),
    //             ),
    //           ],
    //         ),
    //         // add about me button or follow buttons
    //
    //       ],
    //     ),
    //   ),
    // );
  }

  void saveFile(Uint8List bytes, String extension) async {
    // if (kIsWeb) {
    //   html.AnchorElement()
    //     ..href = '${Uri.dataFromBytes(bytes, mimeType: 'image/$extension')}'
    //     ..download =
    //         'FlutterLetsDraw-${DateTime.now().toIso8601String()}.$extension'
    //     ..style.display = 'none'
    //     ..click();
    // } else
    // {
    await FileSaver.instance.saveFile(
      name: 'FlutterLetsDraw-${DateTime.now().toIso8601String()}.$extension',
      bytes: bytes,
      ext: extension,
      mimeType: extension == 'png' ? MimeType.png : MimeType.jpeg,
    );
    // }
  }

  Future<ui.Image> get _getImage async {
    final completer = Completer<ui.Image>();
    // if (!kIsWeb && !Platform.isAndroid && !Platform.isIOS) {
    //   final file = await FilePicker.platform.pickFiles(
    //     type: FileType.image,
    //     allowMultiple: false,
    //   );
    //   if (file != null) {
    //     final filePath = file.files.single.path;
    //     final bytes = filePath == null
    //         ? file.files.first.bytes
    //         : File(filePath).readAsBytesSync();
    //     if (bytes != null) {
    //       completer.complete(decodeImageFromList(bytes));
    //     } else {
    //       completer.completeError('No image selected');
    //     }
    //   }
    // }

    // else {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      completer.complete(
        decodeImageFromList(bytes),
      );
    } else {
      completer.completeError('No image selected');
    }
    // }

    return completer.future;
  }

  Future<Uint8List?> getBytes() async {
    RenderRepaintBoundary boundary = canvasGlobalKey.currentContext
        ?.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage();
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List? pngBytes = byteData?.buffer.asUint8List();
    return pngBytes;
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

  final ValueNotifier<List<SketchEntity>> sketchesNotifier;
  final ValueNotifier<SketchEntity?> currentSketchNotifier;

  ///Collection of sketches that can be redone.
  late final List<Sketch> _redoStack = [];

  ///Whether redo operation is possible.
  ValueNotifier<bool> get canRedo => _canRedo;
  late final ValueNotifier<bool> _canRedo = ValueNotifier(false);

  late int _sketchCount;

  void _sketchesCountListener() {
    if (sketchesNotifier.value.length > _sketchCount) {
      //if a new sketch is drawn,
      //history is invalidated so clear redo stack
      _redoStack.clear();
      _canRedo.value = false;
      _sketchCount = sketchesNotifier.value.length;
    }
  }

  void clear() {
    _sketchCount = 0;
    sketchesNotifier.value = [];
    _canRedo.value = false;
    currentSketchNotifier.value = null;
  }

  void undo() {
    final sketches = List<Sketch>.from(sketchesNotifier.value);
    if (sketches.isNotEmpty) {
      _sketchCount--;
      _redoStack.add(sketches.removeLast());
      sketchesNotifier.value = sketches;
      _canRedo.value = true;
      currentSketchNotifier.value = null;
    }
  }

  void redo() {
    if (_redoStack.isEmpty) return;
    final sketch = _redoStack.removeLast();
    _canRedo.value = _redoStack.isNotEmpty;
    _sketchCount++;
    sketchesNotifier.value = [...sketchesNotifier.value, sketch];
  }

  void dispose() {
    sketchesNotifier.removeListener(_sketchesCountListener);
  }
}
