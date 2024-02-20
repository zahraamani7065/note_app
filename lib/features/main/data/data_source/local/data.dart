import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:note_app/features/main/domain/entity/data_entity.dart';
import 'package:note_app/features/main/domain/entity/sketch_entity.dart';
import '../../model/sketch.dart';
import 'drawing_data.dart';

part 'data.g.dart';

@HiveType(adapterName: "NoteAdapter", typeId: 1)
class Data {
  @HiveField(0)
  String name = '';

  @HiveField(1)
  DateTime dateTime = DateTime.now();

  @HiveField(2)
  String text = '';

  @HiveField(3)
  List<int> drawingBytes = [];

  @HiveField(4)
  String imagePath = '';

  @HiveField(5)
  String videoPath = '';

  @HiveField(6)
  List<DrawingData> drawingDataList = [];


  Data(this.name, this.dateTime, this.drawingBytes, this.imagePath, this.text,
      this.videoPath);

  DrawingData convertDrawingDataToCategory(SketchEntity sketchEntity) {
    return DrawingData(points: sketchEntity.points,
        color: sketchEntity.color,
        size:sketchEntity. size,
        type:sketchEntity. type,
        filled:sketchEntity. filled,
        sides:sketchEntity. sides);
  }

  Data.fromDataEntity(DataEntity dataEntity){
    name = dataEntity.name;
    dateTime = dataEntity.dateTime;
    text = dataEntity.text;
    drawingBytes = dataEntity.drawingBytes;
    imagePath = dataEntity.imagePath;
    videoPath = dataEntity.videoPath;
    drawingDataList = dataEntity.sketchEntity.map((sketchEntity) {
      return DrawingData(
        points: sketchEntity.points,
        color: sketchEntity.color,
        size: sketchEntity.size,
        type: sketchEntity.type,
        filled: sketchEntity.filled,
        sides: sketchEntity.sides,
      );
    }).toList();

  }

}

class NoParams {}
