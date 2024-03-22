import 'package:equatable/equatable.dart';
import 'package:note_app/features/main/domain/entity/sketch_entity.dart';

class DataEntity extends Equatable {
   String name;
   List<String> text;
   DateTime dateTime;
   List<int> drawingBytes;
   List<String> imagePath;
  List<String> videoPath;
   List<List<SketchEntity>>  sketchEntity;
   List<int> elementOrder;

  DataEntity(
      {
      required this.elementOrder,
      required this.sketchEntity,
      required this.name,
      required this.text,
      required this.dateTime,
      required this.drawingBytes,
      required this.imagePath,
      required this.videoPath});

  @override
  // TODO: implement props
  List<Object?> get props => [sketchEntity, name, text, dateTime, drawingBytes,
    imagePath,videoPath,elementOrder
  ];
}
