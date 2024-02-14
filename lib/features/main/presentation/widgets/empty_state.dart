import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:note_app/core/strings/string.dart';

import '../../../../core/utils/images/svg_logos.dart';

class EmptyState extends StatelessWidget {
   EmptyState(
      {super.key, required this.themeData, required this.diagonalSize});

  final ThemeData themeData;
  final double diagonalSize;
  double paddingFactor = 0.01;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: diagonalSize * paddingFactor),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
                left: diagonalSize * paddingFactor,
                right: diagonalSize * paddingFactor),
            child: Row(
              children: [
                Expanded(
                    child: Center(
                        child: Text(
                  AppStrings.index,
                  style: themeData.textTheme.headline5,
                ))),

              ],
            ),
          ),
          Expanded(
              child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.string(svgSourceHomeScreen),
                Text(
                  AppStrings.emptyText,
                  style: themeData.textTheme.headline6,
                ),
                SizedBox(
                  height: diagonalSize*0.05
                ),
                Text(
                  AppStrings.topToPlus,
                  style: themeData.textTheme.bodyText2,
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
