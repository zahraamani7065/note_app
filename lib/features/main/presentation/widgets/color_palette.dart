import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';


class ColorPalette extends HookWidget {
  final ValueNotifier<Color> selectedColor;


  List<Color> colors = [
    Colors.black,
    Colors.white,
    ...Colors.primaries,
  ];

   ColorPalette( {
    Key? key,
    required this.selectedColor,

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final diagonalSize = sqrt(pow(screenWidth, 2) + pow(screenHeight, 2));
    final isColorListVisible = useState(false);


    return Column(
      mainAxisAlignment: MainAxisAlignment.end,

      children: [
        if (isColorListVisible.value) ..._buildColorList(context,diagonalSize),
        GestureDetector(
          onTap: () {
            isColorListVisible.value = !isColorListVisible.value;
          },
          child: Container(
            height: diagonalSize*0.03,
            width: diagonalSize*0.03,
            margin: EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              color: selectedColor.value,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.blue,
                width: 2,
              ),
            ),
          ),
        ),

      ],
    );
  }

  List<Widget> _buildColorList(BuildContext context,double diagonalSize) {
    return [
      SizedBox(height: 10), // Add some space between the selected color and the color list
      Container(
        height: diagonalSize*0.1,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,

          child: Column(
            children: colors.map((color) {
              return GestureDetector(
                onTap: () {
                  selectedColor.value = color;
                },
                child: Container(
                  height: diagonalSize*0.03,
                  width: diagonalSize*0.03,
                  margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selectedColor.value == color ? Colors.blue : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    ];
  }
}


