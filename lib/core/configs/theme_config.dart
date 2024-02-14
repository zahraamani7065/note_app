import 'dart:ui';

import 'package:flutter/material.dart';

class ThemeConfig {
  final primaryColor = Color(0xFFE3AE08);
  final Color primaryTextColor = Colors.black;
  final Color secondaryTextColor = Colors.white;
  final Color backgroundColor = Colors.white;
  final Color itemBackgroundColor=Color(0xFFf2f2f2);

  // final Color onPrimary;
  ThemeData getTheme() {

    return ThemeData(

      colorScheme: ColorScheme(
        primary: primaryColor,
        onPrimary: primaryTextColor,
        secondary: primaryTextColor,
        onSecondary: primaryTextColor,
        surface: primaryTextColor,
        onSurface: primaryTextColor,
        background: primaryTextColor,
        onBackground: primaryTextColor,
        error: primaryTextColor,
        onError: primaryTextColor,
        brightness: Brightness.light,
      ),


        scaffoldBackgroundColor: backgroundColor,
        brightness: Brightness.light,
        backgroundColor: itemBackgroundColor,

        textTheme: TextTheme(
            headline6: TextStyle(
              color: primaryTextColor,
              fontWeight: FontWeight.bold,
            ),
            bodyText2: TextStyle(
              color: primaryTextColor,
              fontSize: 16,
              fontWeight: FontWeight.normal,
            ),
           ),

     );
  }
}
