import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' as Flutter;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:note_app/core/Services/locator.dart';
import 'package:note_app/core/strings/string.dart';
import 'package:note_app/core/utils/images/svg_logos.dart';
import 'package:note_app/features/main/domain/entity/data_entity.dart';
import 'package:note_app/features/main/domain/entity/sketch_entity.dart';
import 'package:note_app/features/main/presentation/screens/home.dart';
import 'package:path/path.dart' as path;
import 'package:video_player/video_player.dart';

import '../../data/model/drawing_mode.dart';
import '../../data/model/sketch.dart';
import '../bloc/note_list_bloc.dart';
import '../widgets/cannvas_side_bar.dart';
import '../widgets/drawing_canvas.dart';
import '../widgets/sketchPainter.dart';

class AddNoteScreen extends HookWidget {
  final List<quill.QuillController> textControllers = [];
  final DataEntity? note;
  late DataEntity data;


  AddNoteScreen(this.note, {Key? key}) : super(key: key){
    data = note != null ? _initializeDataEntity() : DataEntity(   sketchEntity: [],
      name: "",
      text: [],
      dateTime: DateTime.now(),
      drawingBytes: [],
      imagePath: [],
      videoPath: [],
      elementOrder: [],);
  }
  DataEntity _initializeDataEntity() {
    final List<int> elementOrder = [];

    // Populate elementOrder based on note elements
    for (final index in note!.elementOrder) {
      if (index == DataElementType.sketch.index) {
        elementOrder.add(DataElementType.sketch.index);
      } else if (index == DataElementType.text.index) {
        elementOrder.add(DataElementType.text.index);
      }
    }

    return DataEntity(
      sketchEntity: note!.sketchEntity,
      name: note!.name,
      text: note!.text,
      dateTime: note!.dateTime,
      drawingBytes: note!.drawingBytes,
      imagePath: note!.imagePath,
      videoPath: note!.videoPath,
      elementOrder: elementOrder,
    );
  }


  @override
  Widget build(BuildContext context) {
    final imageType = useState<String>("large");
    final _selectedFile = useState<File?>(null);
    final selectedColor = useState(Colors.black);
    final strokeSize = useState<double>(10);
    final eraserSize = useState<double>(30);
    final drawingMode = useState(DrawingMode.pencil);
    final filled = useState<bool>(false);
    final polygonSides = useState<int>(3);
    final backgroundImage = useState<Image?>(null);
    final canvasGlobalKey = GlobalKey();
    var textValue = useState<List<String>>(note?.text ?? []);
    var name = useMemoized(() => note?.name, [note]);
    final focusNode = useFocusNode();
    final quillControllers = useState<List<quill.QuillController>>([]);
    ValueNotifier<SketchEntity?> currentSketch = useState(null);
    ValueNotifier<List<List<SketchEntity>>> allSketches = useState([[]]);
    final availableElements = useState<List<Widget>>([]);
    OverlayEntry? _currentOverlayEntry;
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 150),
      initialValue: 1,
    );
    final isDrawingMode = useState<bool>(false);
    final isWritingMode = useState<bool>(true);
    final themeData = Theme.of(context);
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final screenHeight = MediaQuery
        .of(context)
        .size
        .height;
    final paddingFactor = 0.01;
    final diagonalSize = sqrt(pow(screenWidth, 2) + pow(screenHeight, 2));
    final quillController = useState<quill.QuillController>(
      quill.QuillController.basic(),
    );
    FocusNode _focusNode = FocusNode();

    useEffect(() {
      if (_selectedFile.value != null) {
        print('Selected file: ${_selectedFile.value}');
      }
      return null;
    }, [_selectedFile.value]);

    useEffect(() {
      if (isWritingMode.value) {
        focusNode.requestFocus();
      }
      return null;
    }, [isWritingMode.value]);

    useEffect(() {
      if (isWritingMode.value) {
        final newController = quill.QuillController.basic();
        textControllers.add(newController);
        quillControllers.value.add(newController);
        // textValue.value.add("");
      }
      return null;
    }, [isWritingMode.value]);

    Widget _buildQuillEditor(int index) {
      final controller = quillControllers.value[index];
      if (controller != null) {
        return GestureDetector(
          onTap: () {
            isWritingMode.value = true;
            quillController.value = controller;
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: quill.QuillEditor(
              configurations: quill.QuillEditorConfigurations(
                controller: controller,
                readOnly: false,
                enableInteractiveSelection: true,
                requestKeyboardFocusOnCheckListChanged: false,
              ),

              focusNode: _focusNode,
              scrollController: Flutter.ScrollController(),
            ),
          ),
        );
      } else {
        return SizedBox();
      }
    }
    DataEntity saveElements() {
      final List<int> elementOrder = [];
      textValue.value.clear();

      // Save text values from Quill controllers
      for (final controller in quillControllers.value) {
        final delta = controller.document.toDelta();
        final d=controller.document.toString();
        print("$d documnet");
        if (delta != null) {
          final jsonString = jsonEncode(delta.toJson());
          final sanitizedString = jsonString.replaceAll("\n", "");
          textValue.value.add(sanitizedString);
        }
      }

      // Update element order
      for (final element in availableElements.value) {
        if (element is DrawingCanvas) {
          elementOrder.add(DataElementType.sketch.index);
        } else if (element is GestureDetector) {
          elementOrder.add(DataElementType.text.index);
        }
      }

      final data = DataEntity(
        sketchEntity: allSketches.value,
        name: name?.toString() ?? "",
        text: textValue.value,
        dateTime: DateTime.now(),
        drawingBytes: [],
        imagePath: [],
        videoPath: [],
        elementOrder: elementOrder,
      );

      return data;
    }

    void removeOverlay() {
      _currentOverlayEntry?.remove();
      _currentOverlayEntry = null;
    }

    ValueNotifier<bool> _showOverlay = ValueNotifier<bool>(false);



    void showFormattingOptionsOverlay(Offset position) {
      removeOverlay();
      _showOverlay.value = false;
      OverlayState? overlay = Overlay.of(context);
      _currentOverlayEntry = OverlayEntry(
        builder: (context) {
          return Stack(
            children: [
              GestureDetector(
                onTap: () {
                  removeOverlay(); // Remove overlay on tap outside
                },
                child: Container(
                  width: MediaQuery
                      .of(context)
                      .size
                      .width,
                  height: MediaQuery
                      .of(context)
                      .size
                      .height,
                  color: Colors.transparent,
                ),
              ),
              Positioned(
                left: position.dx,
                top: position.dy,
                child: Material(
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.format_bold),
                        onPressed: () {
                          quillController.value!
                              .formatSelection(quill.Attribute.bold);
                          removeOverlay(); // Remove overlay on button press
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.format_italic),
                        onPressed: () {
                          quillController.value!
                              .formatSelection(quill.Attribute.italic);
                          removeOverlay(); // Remove overlay on button press
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.format_underline),
                        onPressed: () {
                          quillController.value!
                              .formatSelection(quill.Attribute.underline);
                          removeOverlay(); // Remove overlay on button press
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      );

      overlay!.insert(_currentOverlayEntry!);
    }
    void _showImageOptions(BuildContext context, Key uniqueId) {
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text((imageType.value == "large") ? "Small" : "Large"),
                  onTap: () {
                    imageType.value =
                    (imageType.value == "large") ? "small" : "large";
                    Navigator.pop(context);
                    // Update the size of the selected image widget
                    for (int i = 0; i < availableElements.value.length; i++) {
                      if (availableElements.value[i] is GestureDetector) {
                        Widget image = availableElements.value[i];
                        if (image.key == uniqueId) {
                          availableElements.value[i] = GestureDetector(
                            key: uniqueId,
                            onLongPress: () {
                              _showImageOptions(context, uniqueId);
                            },
                            child: SizedBox(
                              height: MediaQuery
                                  .of(context)
                                  .size
                                  .height *
                                  ((imageType.value == "large") ? 0.6 : 0.3),
                              width: MediaQuery
                                  .of(context)
                                  .size
                                  .width *
                                  ((imageType.value == "large") ? 0.6 : 0.3),
                              child: image,
                            ),
                          );
                          break;
                        }
                      }
                    }
                  },
                ),
                ListTile(
                  title: Text('Remove'),
                  onTap: () {
                    availableElements.value.removeWhere((element) {
                      if (element is GestureDetector) {
                        return element.key == uniqueId;
                      }
                      return false;
                    });
                    _selectedFile.value = null;
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          );
        },
      );
    }
    useEffect(() {
      if (_selectedFile.value != null) {
        final fileExtension =
        _selectedFile.value!
            .path
            .split('.')
            .last
            .toLowerCase();
        final imageSize = (imageType.value == "large") ? 0.6 : 0.3;
        final uniqueId = UniqueKey();

        Widget imageWidget;
        if (fileExtension == 'mp4') {
          imageWidget = GestureDetector(
            key: uniqueId,
            onLongPress: () {
              _showImageOptions(context, uniqueId);
            },
            child: SizedBox(
              height: MediaQuery
                  .of(context)
                  .size
                  .height * imageSize,
              width: MediaQuery
                  .of(context)
                  .size
                  .width * imageSize,
              child: VideoPlayerWidget(file: _selectedFile.value!),
            ),
          );
        } else {
          imageWidget = GestureDetector(
            key: uniqueId,
            onLongPress: () {
              _showImageOptions(context, uniqueId);
            },
            child: SizedBox(
              height: diagonalSize * imageSize,
              width: diagonalSize * imageSize,
              child: Image.file(
                _selectedFile.value!,
                fit: BoxFit.fill,
              ),
            ),
          );
        }

        if (imageWidget != null) {
          availableElements.value.add(imageWidget);
        }
      }
      return () {
        // Cleanup function if needed
      };
    }, [_selectedFile.value, imageType.value]);


    useEffect(() {
      availableElements.value.clear();

      if (note != null) {
        // Clear the existing elements
        // availableElements.value.clear();
        print(note!.elementOrder);
        final text=note!.text;
        print("$text is text ");
        for (final index in note!.elementOrder) {
          if (index == DataElementType.sketch.index) {
            // Add sketches from note
            for (final sketchList in note!.sketchEntity) {
              allSketches.value.add(sketchList);
              availableElements.value.add(DrawingCanvas(
                key: UniqueKey(),
                width:diagonalSize,
                height: diagonalSize,
                drawingMode: drawingMode,
                selectedColor: selectedColor,
                strokeSize: strokeSize,
                eraserSize: eraserSize,
                sideBarController: animationController,
                currentSketch: currentSketch,
                allSketches: allSketches,
                canvasGlobalKey: GlobalKey(),
                filled: filled,
                polygonSides: polygonSides,
                backgroundImage: backgroundImage,
                isDrawingMode: isDrawingMode,
              ));
            }
          } else if (index == DataElementType.text.index) {
            // Add text editors from note
            for (int i = 0; i < note!.text.length; i++) {
              final newController = quill.QuillController.basic();
              final jsonText = note!.text[i];
              if (jsonText != null && jsonText!=" [{\"insert\":\"\n\"}]" && jsonText.isNotEmpty) {
                final jsonList = jsonDecode(jsonText) as List<dynamic>;
                newController.document = quill.Document.fromJson(jsonList);
                print("$jsonList JSON LIST");
                textControllers.add(newController);
                quillControllers.value.add(newController);
                availableElements.value.add(
                    _buildQuillEditor(quillControllers.value.length - 1));
                _focusNode.requestFocus();
              }
            }
          }
        }
      }

      return null;
    }, [note]);


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
                            children: [
                              Expanded(
                                child: _CustomAppBar(
                                  animationController: animationController,
                                ),
                              ),
                              InkWell(
                                  onTap: () async {
                                    if (!isDrawingMode.value && name == null) {
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
                                                // saveElements( textValue.value,
                                                //   name,
                                                //   allSketches.value,
                                                //   availableElements.value,blocContext);
                                                BlocProvider.of<NoteListBloc>(blocContext)
                                                    .add(SaveDataEvent(saveElements(
                                                )));
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(builder: (context) => HomeScreen()),
                                                );
                                              },
                                              child: Text('OK'),
                                            ),
                                          ],
                                        ),
                                      );
                                    }

                                    if (name != null && !isDrawingMode.value) {
                                      // saveElements( textValue.value,
                                      //   name,
                                      //   allSketches.value,
                                      //   availableElements.value,
                                      //   blocContext);
                                      BlocProvider.of<NoteListBloc>(blocContext)
                                          .add(SaveDataEvent(saveElements(

                                      )));
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => HomeScreen()),
                                      );
                                    }

                                    if (isDrawingMode.value) {
                                      isDrawingMode.value = false;
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
                              child: Flutter.Column(
                                children: availableElements.value,
                              ),
                            ),
                          ),
                          if (isDrawingMode.value == true)
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
                    if (isDrawingMode.value == true) {
                      currentSketch.value = null;
                      if (!availableElements.value.any((
                          element) => element is DrawingCanvas)) {
                        availableElements.value.add(
                          DrawingCanvas(
                            key: UniqueKey(),
                            width: MediaQuery
                                .of(context)
                                .size
                                .width,
                            height: MediaQuery
                                .of(context)
                                .size
                                .height,
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
                          ),);
                      }
                    }
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
                  if (isWritingMode.value == true) {
                    final newController = quill.QuillController.basic();
                    textControllers.add(newController);
                    quillControllers.value.add(newController);
                    availableElements.value.add(
                        _buildQuillEditor(quillControllers.value.length - 1));
                    _focusNode.requestFocus();
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
                    uploadFile(context, _selectedFile);
                    // availableElements.value.add(SizedBox(
                    //   child: _displaySelectedFile(_selectedFile.value!),
                    // ),);
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
  // void saveElements(
  //     List<String> textValues,
  //     String? name,
  //     List<List<SketchEntity>> allSketches,
  //     List<Widget> availableElements,
  //      context
  //     ) {
  //   final List<int> elementOrder = [];
  //
  //   // Populate elementOrder based on availableElements
  //   for (final element in availableElements) {
  //     if (element is DrawingCanvas) {
  //       elementOrder.add(DataElementType.sketch.index);
  //     } else if (element is GestureDetector) {
  //       elementOrder.add(DataElementType.text.index);
  //     }
  //   }
  //
  //   // Update data entity properties
  //   data.sketchEntity = allSketches;
  //   data.name = name ?? "";
  //   data.text = textValues;
  //   data.dateTime = DateTime.now();
  //   data.elementOrder = elementOrder;
  //
  //   // Dispatch SaveDataEvent with the updated data entity
  //   BlocProvider.of<NoteListBloc>(context).add(SaveDataEvent(data));
  // }
}



Future<void> uploadFile(BuildContext context,
    ValueNotifier<File?> _selectedFile) async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'mp4', 'mov', 'avi'],
  );

  if (result != null) {
    String? filePath = result.files.single.path;
    if (filePath != null) {
      final file = File(filePath);
      _selectedFile.value = file;
    }
  } else {

  }
}


class VideoPlayerWidget extends HookWidget {
  final File file;

  const VideoPlayerWidget({required this.file});

  @override
  Widget build(BuildContext context) {
    final _controller = useVideoPlayerController(file);
    final isPlaying = useState<bool>(false);

    useEffect(() {
      _controller.initialize().then((_) {
        if (!isPlaying.value) {
          _controller.play();
          isPlaying.value = true;
        }
      });
      return () {
        _controller.dispose(); // Dispose the controller to release resources
      };
    }, [file]);

    return _controller.value.isInitialized
        ? AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: Stack(
        children: [
          VideoPlayer(_controller),
          Align(
            alignment: Alignment.center,
            child: IconButton(
              icon:
              Icon(isPlaying.value ? Icons.pause : Icons.play_arrow),
              onPressed: () {
                if (isPlaying.value) {
                  _controller.pause();
                } else {
                  _controller.play();
                }
                isPlaying.value = !isPlaying.value;
              },
            ),
          ),
        ],
      ),
    )
        : CircularProgressIndicator(); // Show loading indicator until video is initialized
  }

  VideoPlayerController useVideoPlayerController(File file) {
    return use(_VideoPlayerControllerHook(file));
  }
}

class _VideoPlayerControllerHook extends Hook<VideoPlayerController> {
  final File file;

  const _VideoPlayerControllerHook(this.file);

  @override
  _VideoPlayerControllerHookState createState() =>
      _VideoPlayerControllerHookState();
}

class _VideoPlayerControllerHookState
    extends HookState<VideoPlayerController, _VideoPlayerControllerHook> {
  late VideoPlayerController _controller;

  @override
  void initHook() {
    _controller = VideoPlayerController.file(hook.file);
    super.initHook();
  }

  @override
  VideoPlayerController build(BuildContext context) => _controller;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _CustomAppBar extends StatelessWidget {
  final AnimationController animationController;

  const _CustomAppBar({Key? key, required this.animationController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return SizedBox(
      height: kToolbarHeight,
      width: double.maxFinite,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          IconButton(
            onPressed: () {
              if (animationController.value == 0) {
                animationController.forward();
              } else {
                animationController.reverse();
              }
            },
            icon: Flutter.InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                  );
                },
                child: Icon(
                  Icons.arrow_back_ios,
                  color: themeData.primaryColor,
                )),
          ),
          SizedBox(
            width: 0,
          ),
          Text(
            AppStrings.alliCloud,
            style: themeData.textTheme.headline5,
          ),
          const SizedBox.shrink(),
        ],
      ),
    );
  }
}
enum DataElementType {
  sketch,
  text,
  image,
  video,
}