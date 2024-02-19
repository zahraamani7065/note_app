import 'dart:math';

import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
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
    final paddingFactor = 0.01;
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



//
// class ColorPalette extends HookWidget {
//   final ValueNotifier<Color> selectedColor;
//
//   const ColorPalette({
//     Key? key,
//     required this.selectedColor,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     List<Color> colors = [
//       Colors.black,
//       Colors.white,
//       ...Colors.primaries,
//     ];
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       mainAxisAlignment: MainAxisAlignment.start,
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         Wrap(
//           alignment: WrapAlignment.center,
//           spacing: 2,
//           runSpacing: 2,
//           children: [
//             for (Color color in colors)
//               MouseRegion(
//                 cursor: SystemMouseCursors.click,
//                 child: GestureDetector(
//                   onTap: () => selectedColor.value = color,
//                   child: Container(
//                     height: 25,
//                     width: 25,
//                     decoration: BoxDecoration(
//                       color: color,
//                       border: Border.all(
//                         color: selectedColor.value == color
//                             ? Colors.blue
//                             : Colors.grey,
//                         width: 1.5,
//                       ),
//                       borderRadius: const BorderRadius.all(Radius.circular(5)),
//                     ),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//         const SizedBox(height: 10),
//         Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               height: 30,
//               width: 30,
//               decoration: BoxDecoration(
//                 color: selectedColor.value,
//                 border: Border.all(color: Colors.blue, width: 1.5),
//                 borderRadius: const BorderRadius.all(Radius.circular(5)),
//               ),
//             ),
//             const SizedBox(width: 10),
//             MouseRegion(
//               cursor: SystemMouseCursors.click,
//               child: GestureDetector(
//                 onTap: () {
//                   showColorWheel(context, selectedColor);
//                 },
//                 child: SvgPicture.asset(
//                   'assets/svgs/color_wheel.svg',
//                   height: 30,
//                   width: 30,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
//
//   void showColorWheel(BuildContext context, ValueNotifier<Color> color) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Pick a color!'),
//           content: SingleChildScrollView(
//             child: ColorPicker(
//               borderColor: color.value,
//               onColorChanged: (value) {
//                 color.value = value;
//               },
//             ),
//           ),
//           actions: <Widget>[
//             TextButton(
//               child: const Text('Done'),
//               onPressed: () => Navigator.pop(context),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }