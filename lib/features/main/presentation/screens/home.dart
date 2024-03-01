import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:note_app/core/Services/locator.dart';
import 'package:note_app/core/strings/string.dart';

import '../../../../core/utils/images/svg_logos.dart';
import '../../domain/entity/data_entity.dart';
import '../bloc/note_list_bloc.dart';
import '../bloc/status/get_note_status.dart';
import '../widgets/empty_state.dart';
import 'add_note_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    double diagonalSize = sqrt(pow(screenWidth, 2) + pow(screenHeight, 2));
    double paddingFactor = 0.01;
    print((diagonalSize * paddingFactor).toString() + " is  ratio");

    return Scaffold(
        backgroundColor: themeData.backgroundColor,
        body: SafeArea(
            child: BlocProvider(
          create: (context) => locator<NoteListBloc>(),
          child: BlocBuilder<NoteListBloc, NoteListState>(
              // buildWhen: (previous, current) {
              // if (current.getAllDataStatus == previous.getAllDataStatus) {
              //   return false;
              // }
              // return true;
              // },
              builder: (context, state) {
            if (state.getAllDataStatus is GetAllDataLoading) {
              BlocProvider.of<NoteListBloc>(context).add(GetAllDataEvent());
              print("loading data");
            } else if (state.getAllDataStatus is GetAllDataCompleted) {
              print("get all data complated");
              GetAllDataCompleted getAllCityCompleted =
                  state.getAllDataStatus as GetAllDataCompleted;
              List<DataEntity> data = getAllCityCompleted.data;
              print(data.toString() + "is data");
              if (data.isEmpty) {
                return
                    // Text("emoty...............");
                    Padding(
                        padding: EdgeInsets.all(diagonalSize * paddingFactor),
                        child: Column(
                          children: [
                            Expanded(
                              child: EmptyState(
                                themeData: themeData,
                                diagonalSize: diagonalSize,
                              ),
                            ),
                            Align(
                                alignment: Alignment.bottomRight,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              AddNoteScreen(null)),
                                    );
                                  },
                                  child: SvgPicture.string(
                                    svgAddNote,
                                    width: diagonalSize * 0.03,
                                    height: diagonalSize * 0.03,
                                  ),
                                )),
                          ],
                        ));
              }
              return Padding(
                padding: EdgeInsets.only(
                  top: diagonalSize * paddingFactor,
                  right: diagonalSize * paddingFactor,
                  left: diagonalSize * paddingFactor,
                ),
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            height: diagonalSize * paddingFactor,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children:[ Text(
                              AppStrings.notes,
                              style: themeData.textTheme.headline6,
                            ),

                            IconButton(onPressed: (){
                              BlocProvider.of<NoteListBloc>(context).add(DeleteAllEvent());

                            }, icon:  Icon(CupertinoIcons.delete),)
                            ]
                          ),
                          SizedBox(
                            height: diagonalSize * paddingFactor,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(diagonalSize * 0.03),
                              color: themeData.scaffoldBackgroundColor,
                            ),
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              scrollDirection: Axis.vertical,
                              itemCount: data.length,
                              itemBuilder: (BuildContext context, int index) {
                                final DataEntity task = data[index];
                                GlobalKey _inkWellKey = GlobalKey();
                                return Padding(
                                  padding: EdgeInsets.only(
                                    right: diagonalSize * paddingFactor,
                                    left: diagonalSize * paddingFactor,
                                    top: diagonalSize * paddingFactor,
                                    bottom: diagonalSize * paddingFactor,
                                  ),
                                  child: InkWell(
                                    key: _inkWellKey,
                                    onLongPress: () {
                                      final RenderObject? renderObject =
                                          _inkWellKey.currentContext
                                              ?.findRenderObject();
                                      if (renderObject is RenderBox) {
                                        final position = renderObject
                                            .localToGlobal(Offset.zero);
                                        if (position != null) {
                                          _showContextMenu(
                                              context, position, index);
                                        }
                                      }
                                    },
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              AddNoteScreen(task),
                                        ),
                                      );
                                    },
                                    child: SizedBox(
                                      width: screenWidth,
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(task.name),
                                            SizedBox(
                                              height: diagonalSize * 0.005,
                                            ),
                                            Text(
                                              DateFormat('yyyy-MM-dd HH:mm')
                                                  .format(task.dateTime),
                                              style:
                                                  TextStyle(color: Colors.grey),
                                            ),
                                            SizedBox(
                                              height: diagonalSize * 0.01,
                                            ),

                                            if (index != data.length - 1)
                                              Divider(
                                                color:
                                                    themeData.backgroundColor,
                                                thickness: 2,
                                                // Optional: Set the thickness of the divider
                                                height:
                                                    20, // Optional: Set the height of the divider
                                              ),
                                            // Divider(),
                                          ]),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: diagonalSize * 0.015,
                        right: diagonalSize * 0.015,
                      ),
                      child: Align(
                          alignment: Alignment.bottomRight,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AddNoteScreen(null)),
                              );
                            },
                            child: SvgPicture.string(
                              svgAddNote,
                              width: diagonalSize * 0.03,
                              height: diagonalSize * 0.03,
                            ),
                          )),
                    ),
                  ],
                ),
              );
            }
            return Container(
              child: Text("...."),
            );
          }),
        )));
  }

  void _showContextMenu(
      BuildContext context, Offset position, int index) async {
    final RenderBox overlay =
        Overlay.of(context)!.context.findRenderObject() as RenderBox;
    final relativePosition = RelativeRect.fromRect(
      Rect.fromPoints(
        position,
        position,
      ),
      Offset.zero & overlay.size,
    );

    final result = await showMenu<String>(
      context: context,
      position: relativePosition,
      items: <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'delete',
          child: ListTile(
            leading: Icon(Icons.delete),
            title: Text(AppStrings.delete),
          ),
        ),
        PopupMenuItem<String>(
          value: 'pin',
          child: ListTile(
            leading: Icon(Icons.push_pin),
            title: Text(AppStrings.pin),
          ),
        ),
      ],
    );

    if (result != null) {
      if (result == 'delete') {
        BlocProvider.of<NoteListBloc>(context).add(DeleteEvent(index: index));
      } else if (result == 'pin') {
        // Handle pin action
      }
    }
  }
}
