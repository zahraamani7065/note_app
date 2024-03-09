import 'package:equatable/equatable.dart';
import 'package:note_app/features/main/domain/entity/sketch_entity.dart';

class DataEntity extends Equatable {
  final String name;
  final List<String> text;
  final DateTime dateTime;
  final List<int> drawingBytes;
  final List<String> imagePath;
  final List<String> videoPath;
  final List<List<SketchEntity>>  sketchEntity;

  DataEntity(
      {required this.sketchEntity,
      required this.name,
      required this.text,
      required this.dateTime,
      required this.drawingBytes,
      required this.imagePath,
      required this.videoPath});

  @override
  // TODO: implement props
  List<Object?> get props => [sketchEntity, name, text, dateTime, drawingBytes,
    imagePath,videoPath,
  ];
}
