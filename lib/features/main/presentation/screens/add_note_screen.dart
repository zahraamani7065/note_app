import 'package:flutter_hooks/flutter_hooks.dart';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:note_app/core/utils/images/svg_logos.dart';
import 'package:note_app/features/main/presentation/widgets/sketchPainter.dart';
import 'package:signature/signature.dart';
import 'package:flutter/widgets.dart' show Image;
import '../../../../core/Services/locator.dart';
import '../../data/model/drawing_mode.dart';
import '../../data/model/sketch.dart';
import '../bloc/note_list_bloc.dart';
import '../widgets/cannvas_side_bar.dart';
import '../widgets/drawing_canvas.dart';

class AddNoteScreen extends HookWidget {
  const AddNoteScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final selectedColor = useState(Colors.black);
    final strokeSize = useState<double>(10);
    final eraserSize = useState<double>(30);
    final drawingMode = useState(DrawingMode.pencil);
    final filled = useState<bool>(false);
    final polygonSides = useState<int>(3);
    final backgroundImage = useState<Image?>(null);
    final canvasGlobalKey = GlobalKey();
    final containerHeight = useState<double?>(null);
    final textValue = useState<String>('');
    final focusNode = useFocusNode();
    ValueNotifier<Sketch?> currentSketch = useState(null);
    ValueNotifier<List<Sketch>> allSketches = useState([]);
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 150),
      initialValue: 1,
    );
    final isDrawingMode = useState<bool>(false);
    final isWritingMode = useState<bool>(true);
    final descriptionController = useTextEditingController();
    final ctrlSing = useMemoized(() => SignatureController(
      penStrokeWidth: 5,
      penColor: Colors.red,
      exportBackgroundColor: Colors.transparent,
    ));

    final themeData = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final paddingFactor = 0.01;
    final diagonalSize = sqrt(pow(screenWidth, 2) + pow(screenHeight, 2));
    useEffect(() {
      if (isWritingMode.value) {
        focusNode.requestFocus(); // Request focus when in writing mode
      }
      return null;
    }, [isWritingMode.value]);

    return Scaffold(
      backgroundColor: themeData.backgroundColor,
      body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children:[
                        if (isWritingMode.value)
                          Container(
                            height: 100,
                            padding: EdgeInsets.all(diagonalSize * paddingFactor),
                             child: Padding(
                                      padding: EdgeInsets.all(diagonalSize * paddingFactor),
                                      child: TextField(
                                        focusNode: focusNode, // Assign the FocusNode to TextField
                                        enabled: isWritingMode.value, // Enable TextField based on isWritingMode
                                        controller: descriptionController,
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          hintText: 'Type something...',
                                        ),
                                        maxLines: null,
                                        expands: true,
                                        onChanged: (text) {
                                          textValue.value = text; // Update the text value
                                        },
                                      ),
                                ),
                           ),

                        if (!isWritingMode.value && textValue.value.isNotEmpty)
                        Container(
                            // Adjust height as needed
                            padding: EdgeInsets.all(diagonalSize * paddingFactor),
                            child: Text(
                              textValue.value,
                               // Adjust style as needed
                            ),
                          ),


                        SizedBox(height: 10,),


                        if(isDrawingMode.value && textValue.value.isNotEmpty)
                        LayoutBuilder(
                          builder: (BuildContext context, BoxConstraints constraints) {
                          return DrawingCanvas(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                            drawingMode: drawingMode,
                            selectedColor: selectedColor,
                            strokeSize: strokeSize,
                            eraserSize: eraserSize,
                            sideBarController: animationController,
                            currentSketch: currentSketch,
                            allSketches: allSketches,
                            canvasGlobalKey: canvasGlobalKey,
                            filled: filled,
                            polygonSides: polygonSides,
                            backgroundImage: backgroundImage,
                          );}
                        ),
                        // Positioned(
                        //   top: kToolbarHeight + 10,
                        //   // left: -5,
                        //   child: SlideTransition(
                        //     position: Tween<Offset>(
                        //       begin: const Offset(-1, 0),
                        //       end: Offset.zero,
                        //     ).animate(animationController),
                        //     child: CanvasSideBar(
                        //       drawingMode: drawingMode,
                        //       selectedColor: selectedColor,
                        //       strokeSize: strokeSize,
                        //       eraserSize: eraserSize,
                        //       currentSketch: currentSketch,
                        //       allSketches: allSketches,
                        //       canvasGlobalKey: canvasGlobalKey,
                        //       filled: filled,
                        //       polygonSides: polygonSides,
                        //       backgroundImage: backgroundImage,
                        //     ),
                        //   ),
                        // ),
                        // _CustomAppBar(animationController: animationController),
              ],
            ),
          ),

        ),
      bottomNavigationBar:
      Padding(
        padding: EdgeInsets.only(bottom: diagonalSize * 0.01),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: diagonalSize * 0.1),
                child: InkWell(
                  onTap: () async {
                    isDrawingMode.value = !isDrawingMode.value;
                    isWritingMode.value = false;
                    // Set drawing bytes if needed
                  },
                  child: SvgPicture.string(
                    isDrawingMode.value ? selectedSvgPaint : SvgPaint,
                    width: diagonalSize * 0.03,
                    height: diagonalSize * 0.03,
                  ),
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () async {
                  isDrawingMode.value = false;
                  isWritingMode.value = !isWritingMode.value;
                  if (isWritingMode.value) {
                    focusNode.requestFocus();
                  }
                  // Set drawing bytes if needed
                },
                child: SvgPicture.string(
                  isWritingMode.value ? selectedSvgAddNote : svgAddNote,
                  width: diagonalSize * 0.03,
                  height: diagonalSize * 0.03,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: diagonalSize * 0.1),
                child: InkWell(
                  onTap: () {
                    // Implement upload functionality
                  },
                  child: SvgPicture.string(
                    SvgUpload,
                    width: diagonalSize * 0.03,
                    height: diagonalSize * 0.03,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

    );
  }
   }
class _CustomAppBar extends StatelessWidget {
  final AnimationController animationController;

  const _CustomAppBar({Key? key, required this.animationController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: kToolbarHeight,
      width: double.maxFinite,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {
                if (animationController.value == 0) {
                  animationController.forward();
                } else {
                  animationController.reverse();
                }
              },
              icon: const Icon(Icons.menu),
            ),
            const Text(
              'Let\'s Draw',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 19,
              ),
            ),
            const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }}