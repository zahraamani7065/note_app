import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:note_app/core/Services/locator.dart';
import 'package:note_app/core/strings/string.dart';
import 'package:note_app/core/utils/images/svg_logos.dart';
import 'package:note_app/features/main/domain/entity/data_entity.dart';
import 'package:note_app/features/main/domain/entity/sketch_entity.dart';
import 'package:note_app/features/main/domain/usecase/add_sketch_useCase.dart';
import 'package:note_app/features/main/presentation/screens/home.dart';

import '../../data/model/drawing_mode.dart';
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
    final textValue = useState<String>('');
    String? name;
    final focusNode = useFocusNode();
    AddSketchUseCase addSketchUseCase =
        AddSketchUseCase(sketchRepository: locator());
    ValueNotifier<SketchEntity?> currentSketch = useState(null);
    ValueNotifier<List<SketchEntity>> allSketches = useState([]);
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 150),
      initialValue: 1,
    );

    final isDrawingMode = useState<bool>(false);
    final isWritingMode = useState<bool>(true);
    final descriptionController = useTextEditingController();

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
          child: BlocProvider(
              create: (context) => locator<NoteListBloc>(),
              child: BlocBuilder<NoteListBloc, NoteListState>(
                  builder: (blocContext, state) {
                return Padding(
                  padding: EdgeInsets.all(diagonalSize * paddingFactor),
                  child: Column(
                    children: [
                      Row(
                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: _CustomAppBar(
                              animationController: animationController,
                            ),
                          ),
                          InkWell(
                              onTap: () async {
                                if (!isDrawingMode.value) {
                                  // Show dialog to get the name
                                  name = await showDialog(
                                    context: blocContext,
                                    builder: (context) => AlertDialog(
                                      title: Text('Enter a name'),
                                      content: TextField(
                                        onChanged: (value) => name = value,
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            final data = DataEntity(
                                                sketchEntity: allSketches.value,
                                                name: name.toString(),
                                                text: textValue.value,
                                                dateTime: DateTime.now(),
                                                drawingBytes: [],
                                                imagePath: "",
                                                videoPath: "");
                                            BlocProvider.of<NoteListBloc>(
                                                    blocContext)
                                                .add(SaveDataEvent(data));
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        HomeScreen()),
                                              );
                                          },
                                          child: Text('OK'),
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  isDrawingMode.value=false;
                                }
                              },
                              child: Text(
                                AppStrings.done,
                                style: themeData.textTheme.headline5,
                              )),
                        ],
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Column(
                            children: [
                              if (isWritingMode.value)
                                IntrinsicHeight(
                                  child: TextField(
                                    focusNode: focusNode,
                                    // Assign the FocusNode to TextField
                                    enabled: isWritingMode.value,
                                    // Enable TextField based on isWritingMode
                                    controller: descriptionController,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                    ),
                                    maxLines: null,
                                    expands: true,
                                    onChanged: (text) {
                                      textValue.value =
                                          text; // Update the text value
                                    },
                                  ),
                                ),

                              if (!isWritingMode.value &&
                                  textValue.value.isNotEmpty)
                                Container(
                                  // Adjust height as needed
                                  padding: EdgeInsets.all(
                                      diagonalSize * paddingFactor),
                                  child: Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      textValue.value,
                                      // Adjust style as needed
                                    ),
                                  ),
                                ),

                              SizedBox(
                                height: 10,
                              ),

                              // if(isDrawingMode.value || textValue.value.isNotEmpty)
                              LayoutBuilder(builder: (BuildContext context,
                                  BoxConstraints constraints) {
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
                                  isDrawingMode: isDrawingMode,
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                      if (isDrawingMode.value)
                        SizedBox(
                          width: screenWidth,
                          child: CanvasSideBar(
                            drawingMode: drawingMode,
                            selectedColor: selectedColor,
                            strokeSize: strokeSize,
                            eraserSize: eraserSize,
                            currentSketch: currentSketch,
                            allSketches: allSketches,
                            canvasGlobalKey: canvasGlobalKey,
                            filled: filled,
                            polygonSides: polygonSides,
                            backgroundImage: backgroundImage,
                          ),
                        ),
                      // SlideTransition(
                      //   position: Tween<Offset>(
                      //     begin: const Offset(-1, 0),
                      //     end: Offset.zero,
                      //   ).animate(animationController),
                      //   child: CanvasSideBar(
                      //     drawingMode: drawingMode,
                      //     selectedColor: selectedColor,
                      //     strokeSize: strokeSize,
                      //     eraserSize: eraserSize,
                      //     currentSketch: currentSketch,
                      //     allSketches: allSketches,
                      //     canvasGlobalKey: canvasGlobalKey,
                      //     filled: filled,
                      //     polygonSides: polygonSides,
                      //     backgroundImage: backgroundImage,
                      //   ),
                      // ),
                    ],
                  ),
                );
              }))),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(bottom: diagonalSize * 0.01),
        child: (!isDrawingMode.value)
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
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
                  Flexible(
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
                  Flexible(
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
              )
            : const SizedBox.shrink(),
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
              icon: const Icon(Icons.add_circle_outline),
            ),
            const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}

// class _CustomAppBar extends StatelessWidget {
//   final double diagonalSize;
//   final AnimationController animationController;
//   final themeData;
//
//   const _CustomAppBar({Key? key, required this.animationController, required this.diagonalSize,required this.themeData})
//       : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: kToolbarHeight,
//       width: double.maxFinite,
//
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//               Expanded(
//                 child: Align(
//                   alignment: Alignment.topLeft,
//                   child: IconButton(
//                     onPressed: () {
//                       if (animationController.value == 0) {
//                         animationController.forward();
//                       } else {
//                         animationController.reverse();
//                       }
//                     },
//                     icon: const Icon(Icons.menu),
//                   ),
//                 ),
//               ),
//              Text(AppStrings.done,style: themeData.textTheme.headline5 ,),
//             const SizedBox.shrink(),
//           ],
//         ),
//
//     );
//   }}
