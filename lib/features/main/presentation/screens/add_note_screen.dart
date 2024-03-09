import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' as Flutter;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
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
import '../bloc/note_list_bloc.dart';
import '../widgets/cannvas_side_bar.dart';
import '../widgets/drawing_canvas.dart';

class AddNoteScreen extends HookWidget {
  final List<quill.QuillController> textControllers = [];
  final DataEntity? note;


  AddNoteScreen(this.note, {Key? key}) : super(key: key);

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
      if (note == null) {
        currentSketch.value = null;
        allSketches.value = [];
        textValue.value = [];
      } else {
        name = note!.name;
        allSketches.value = note!.sketchEntity;
        textValue.value = note!.text;
      }
      return null;
    }, [note]);

    useEffect(() {
      if (isWritingMode.value) {
        final newController = quill.QuillController.basic();
        textControllers.add(newController);
        quillControllers.value.add(newController);
        textValue.value.add("");
      }
      return null;
    }, [isWritingMode.value]);


    DataEntity saveQuillText() {
      textValue.value.clear();
      for (final controller in quillControllers.value) {
        final delta = controller.document.toDelta();
        if (delta != null) {
          final jsonString = jsonEncode(delta.toJson());
          final sanitizedString = jsonString.replaceAll("\n", "");
          textValue.value.add(sanitizedString);
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
      );
      return data;
    }

    OverlayEntry? _currentOverlayEntry;
    void removeOverlay() {
      _currentOverlayEntry?.remove();
      _currentOverlayEntry = null;
    }

    ValueNotifier<bool> _showOverlay = ValueNotifier<bool>(false);
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
    final availableElements = useState<List<Widget>>([]);

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
                    imageType.value = (imageType.value == "large") ? "small" : "large";
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
                              height: MediaQuery.of(context).size.height *
                                  ((imageType.value == "large") ? 0.6 : 0.3),
                              width: MediaQuery.of(context).size.width *
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
        _selectedFile.value!.path.split('.').last.toLowerCase();
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
              height: MediaQuery.of(context).size.height * imageSize,
              width: MediaQuery.of(context).size.width * imageSize,
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






    // useEffect(() {
    //   if (_selectedFile.value != null) {
    //     final imageSize = (imageType.value == "large") ? 0.6 : 0.3;
    //     final fileExtension = path.extension(_selectedFile.value!.path).toLowerCase();
    //     var gestureDetector;
    //     if (fileExtension == '.mp4') {
    //       gestureDetector = GestureDetector(
    //         onLongPress: () {
    //           AddNoteScreen.showImageOptions(context, _selectedFile.value!, diagonalSize, imageType.value, (selectedType) {
    //             imageType.value = selectedType;
    //             print("Selected file type: $imageType");
    //           });
    //         },
    //         child: SizedBox(
    //           height: diagonalSize * imageSize,
    //           width: diagonalSize * imageSize,
    //           child: VideoPlayerWidget(file: _selectedFile.value!),
    //         ),
    //       );
    //     } else {
    //       gestureDetector = GestureDetector(
    //         onLongPress: () {
    //           AddNoteScreen.showImageOptions(context, _selectedFile.value!, diagonalSize, imageType.value, (selectedType) {
    //             imageType.value = selectedType;
    //             print("Selected file type: $imageType");
    //           });
    //         },
    //         child: SizedBox(
    //           height: diagonalSize * imageSize,
    //           width: diagonalSize * imageSize,
    //           child: Image.file(
    //             _selectedFile.value!,
    //             fit: BoxFit.fill,
    //           ),
    //         ),
    //       );
    //     }
    //
    //     // Find and update the existing image widget
    //     bool found = false;
    //     for (int i = 0; i < availableElements.value.length; i++) {
    //       Widget element = availableElements.value[i];
    //       if (element is GestureDetector) {
    //         Widget child = element.child!;
    //         if (child is SizedBox && child.child is Image) {
    //           Image image = child.child as Image;
    //           if (image.image is FileImage && (image.image as FileImage).file.path == _selectedFile.value!.path) {
    //             availableElements.value[i] = gestureDetector; // Update the existing image widget
    //             found = true;
    //             break;
    //           }
    //         }
    //       }
    //     }
    //
    //     // If the image widget doesn't exist, add it
    //     if (!found) {
    //       availableElements.value.add(gestureDetector);
    //     }
    //   }
    //   return null;
    // }, [_selectedFile.value, imageType.value]);

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
                                    saveQuillText();
                                    if (!isDrawingMode.value && name == null) {
                                      // Show dialog to get the name
                                      name = await showDialog(
                                        context: blocContext,
                                        builder: (context) =>
                                            AlertDialog(
                                              title: Flutter.Text(
                                                  'Enter a name'),
                                              content: TextField(
                                                onChanged: (value) =>
                                                name = value,
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    BlocProvider.of<
                                                        NoteListBloc>(
                                                        blocContext)
                                                        .add(SaveDataEvent(
                                                        saveQuillText()));
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              HomeScreen()),
                                                    );
                                                  },
                                                  child: Flutter.Text('OK'),
                                                ),
                                              ],
                                            ),
                                      );
                                    }

                                    if (name != null && !isDrawingMode.value) {
                                      BlocProvider.of<NoteListBloc>(blocContext)
                                          .add(SaveDataEvent(saveQuillText()));
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => HomeScreen()),
                                      );
                                    }

                                    if (isDrawingMode.value) {
                                      isDrawingMode.value = false;
                                    }
                                  },
                                  child: Flutter.Text(
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
  // static void showImageOptions(BuildContext context, File selectedFile, double diagonalSize, String currentFileType, void Function(String) onFileTypeSelected, void Function() onResize) {
  //   String newFileType = currentFileType;
  //   showModalBottomSheet(
  //     context: context,
  //     builder: (context) {
  //       return Container(
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             ListTile(
  //               title: Text((currentFileType == "large") ? "small" : "large"),
  //               onTap: () {
  //                 newFileType = (currentFileType == "large") ? "small" : "large";
  //                 Navigator.pop(context);
  //                 onFileTypeSelected(newFileType); // Pass the selected file type to the callback function
  //                 onResize(); // Trigger the resize action
  //               },
  //             ),
  //             ListTile(
  //               title: Text('Remove'),
  //               onTap: () {
  //                 selectedFile =null;
  //                 Navigator.pop(context);
  //               },
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }
// String _showImageOptions(BuildContext context, File selectedFile,
  //     double diagonalSize, String currentFileType) {
  //
  //   late String newFileType="large";
  //   showModalBottomSheet(
  //     context: context,
  //     builder: (context) {
  //       return Container(
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             ListTile(
  //               title: Text((currentFileType == "large") ? "small" : "large"),
  //               onTap: () {
  //                 newFileType = (currentFileType == "large") ? "small" : "large";
  //                 Navigator.pop(context);
  //                 // print("$newFileType current fyle");
  //               },
  //             ),
  //             ListTile(
  //               title: Text('Remove'),
  //               onTap: () {
  //                 Navigator.pop(context);
  //               },
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  //   print("$newFileType current fyle");
  //   return newFileType;
  //
  // }

  // Widget _displaySelectedFile(File _selectedFile, context, String imageType, double diagonalSize) {
  //   final fileExtension = path.extension(_selectedFile.path).toLowerCase();
  //   final imageSize = (imageType == "large") ? 0.6 : 0.3;
  //   print("$imageSize imagesize");
  //
  //   if (fileExtension == '.mp4') {
  //     return GestureDetector(
  //       onLongPress: () {
  //         // Show options for changing image size
  //         _showImageOptions(context, _selectedFile, diagonalSize, imageType);
  //       },
  //       child: SizedBox(
  //         height: diagonalSize * imageSize,
  //         width: diagonalSize * imageSize,
  //         child: VideoPlayerWidget(file: _selectedFile),
  //       ),
  //     );
  //   } else {
  //     return GestureDetector(
  //       onLongPress: () {
  //         _showImageOptions(context, _selectedFile, diagonalSize, imageType);
  //       },
  //       child: SizedBox(
  //         height: diagonalSize * imageSize,
  //         width: diagonalSize * imageSize,
  //         child: Image.file(
  //           _selectedFile,
  //           fit: BoxFit.fill,
  //         ),
  //       ),
  //     );
  //   }
  // }


}


  Future<void> uploadFile(
      BuildContext context, ValueNotifier<File?> _selectedFile) async {
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
