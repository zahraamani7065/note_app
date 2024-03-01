import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart' as Flutter;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill/quill_delta.dart';
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
  final DataEntity? note;

  AddNoteScreen(this.note, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Flutter.Widget> elements=[

    ];
    final _selectedFile = useState<File?>(null);

    useEffect(() {
      if (_selectedFile.value != null) {
        // If a file is selected, display it
        print('Selected file: ${_selectedFile.value}');
      }
      return null;
    }, [_selectedFile.value]);

    final selectedColor = useState(Colors.black);
    final strokeSize = useState<double>(10);
    final eraserSize = useState<double>(30);
    final drawingMode = useState(DrawingMode.pencil);
    final filled = useState<bool>(false);
    final polygonSides = useState<int>(3);
    final backgroundImage = useState<Image?>(null);
    final canvasGlobalKey = GlobalKey();
    var textValue = useState<String>(note?.text ?? '');
    var name = useMemoized(() => note?.name, [note]);
    final focusNode = useFocusNode();
    ValueNotifier<SketchEntity?> currentSketch = useState(null);
    ValueNotifier<List<SketchEntity>> allSketches = useState([]);
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 150),
      initialValue: 1,
    );
    final isDrawingMode = useState<bool>(false);
    final isWritingMode = useState<bool>(true);
    final themeData = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final paddingFactor = 0.01;
    final diagonalSize = sqrt(pow(screenWidth, 2) + pow(screenHeight, 2));
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
        textValue.value = '';
      } else {
        name = note!.name;
        allSketches.value = note!.sketchEntity;
        textValue.value = note!.text;
      }
      return null;
    }, [note]);

    final quillController = useState<quill.QuillController?>(null);
    final overlayEntry = useState<OverlayEntry?>(null);

    useEffect(() {
      final controller = quill.QuillController.basic();
      quillController.value = controller;
      if (textValue.value.isNotEmpty) {
        final delta = Delta.fromJson(jsonDecode(textValue.value));
        controller.replaceText(0, controller.document.length, delta, null);
      }
      return () {
        controller.dispose();
      };
    }, []);
    void saveQuillText() {
      final delta = quillController.value?.document.toDelta();
      if (delta != null) {
        final jsonString = jsonEncode(delta.toJson());
        textValue.value = jsonString;
      }
    }

    OverlayEntry? _currentOverlayEntry;
    void removeOverlay() {
      _currentOverlayEntry?.remove();
      _currentOverlayEntry = null;
    }

    FocusNode _focusNode = FocusNode();
    ValueNotifier<bool> _showOverlay = ValueNotifier<bool>(false);
    void showFormattingOptionsOverlay(Offset position) {
      // Remove any existing overlay
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
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
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
                                saveQuillText();
                                if (!isDrawingMode.value && name == null) {
                                  // Show dialog to get the name
                                  name = await showDialog(
                                    context: blocContext,
                                    builder: (context) => AlertDialog(
                                      title: Flutter.Text('Enter a name'),
                                      content: TextField(
                                        onChanged: (value) => name = value,
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            saveQuillText();
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
                                          child: Flutter.Text('OK'),
                                        ),
                                      ],
                                    ),
                                  );
                                }

                                if (name != null && !isDrawingMode.value) {
                                  saveQuillText();
                                  final data = DataEntity(
                                      sketchEntity: allSketches.value,
                                      name: name.toString(),
                                      text: textValue.value,
                                      dateTime: DateTime.now(),
                                      drawingBytes: [],
                                      imagePath: "",
                                      videoPath: "");
                                  BlocProvider.of<NoteListBloc>(blocContext)
                                      .add(SaveDataEvent(data));
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
                            children: [
                              if (isWritingMode.value)
                                IntrinsicHeight(
                                  child: GestureDetector(
                                    onLongPressStart: (details) {
                                      _showOverlay.value = true;
                                    },
                                    child: Padding(
                                      padding:
                                          EdgeInsets.all(diagonalSize * 0.01),
                                      child: ValueListenableBuilder<bool>(
                                        valueListenable: _showOverlay,
                                        builder: (context, showOverlay, child) {
                                          if (showOverlay) {
                                            _focusNode.unfocus();
                                          } else {
                                            _focusNode.requestFocus();
                                          }
                                          return quill.QuillEditor.basic(
                                            configurations:
                                                quill.QuillEditorConfigurations(
                                              controller:
                                                  quillController.value!,
                                              readOnly: false,
                                              enableInteractiveSelection: true,
                                              requestKeyboardFocusOnCheckListChanged:
                                                  false,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
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
                                    child: quill.QuillEditor.basic(
                                      configurations:
                                          quill.QuillEditorConfigurations(
                                        controller: quillController.value!,
                                        readOnly: true,
                                        enableInteractiveSelection: false,
                                      ),
                                    ),
                                  ),
                                ),

                              SizedBox(
                                height: diagonalSize * 0.007,
                              ),

                              if (_selectedFile.value != null)
                              SizedBox(
                                  child: _displaySelectedFile(
                                      _selectedFile.value!),
                                ),

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
                          uploadFile(context, _selectedFile);
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

  Widget _displaySelectedFile(File _selectedFile) {
    final fileExtension = path.extension(_selectedFile.path).toLowerCase();
    if (fileExtension == '.mp4') {
      // If the selected file is a video
      return VideoPlayerWidget(file: _selectedFile);
    } else {
      // If the selected file is an image
      return Image.file(
        _selectedFile,
        fit: BoxFit.cover, // Adjust this property to control image size
      );
    }
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
      // User canceled the picker
    }
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
