import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
              print("loading data");}
            else if (state.getAllDataStatus is GetAllDataCompleted) {
              print("get all data complated");
              GetAllDataCompleted getAllCityCompleted =
                  state.getAllDataStatus as GetAllDataCompleted;
              List<DataEntity> data = getAllCityCompleted.data;
              print(data.toString() + "is data");
              if (data.isEmpty) {
                return
                    // Text("emoty...............");
                    Padding(
                        padding: EdgeInsets.all( diagonalSize*paddingFactor),
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
                              child:InkWell(
                                onTap:() {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) =>AddNoteScreen()),
                                  );

                                },
                                child: SvgPicture.string(svgAddNote,
                                width: diagonalSize*0.03,
                                height: diagonalSize*0.03,
                                ),
                              )

                            )
                          ],
                        ));
              }
              return Padding(
                padding: EdgeInsets.only(
                  top: diagonalSize * paddingFactor,
                  right: diagonalSize * paddingFactor,
                  left: diagonalSize * paddingFactor,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: diagonalSize * paddingFactor,
                    ),
                    Text(
                      AppStrings.notes,
                      style: themeData.textTheme.headline6,
                    ),
                    SizedBox(
                      height: diagonalSize * paddingFactor,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: themeData.scaffoldBackgroundColor,
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        itemCount: 1,
                        itemBuilder: (BuildContext context, int index) {
                          return Padding(
                              padding: EdgeInsets.only(
                                right: diagonalSize * paddingFactor,
                                left: diagonalSize * paddingFactor,
                                top: diagonalSize * paddingFactor,
                                bottom: diagonalSize * paddingFactor,
                              ),
                              child: Column());
                        },
                      ),
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
}


