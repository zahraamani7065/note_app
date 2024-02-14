import 'package:equatable/equatable.dart';

class DataEntity extends Equatable {
  final String name;
  final String text;
  final  DateTime dateTime;
  final List<int> drawingBytes;
  final String imagePath;
  final String videoPath;

  DataEntity(
      {required this.name,
      required this.text,
      required this.dateTime,
      required this.drawingBytes,
      required this.imagePath,
      required this.videoPath});

  @override
  // TODO: implement props
  List<Object?> get props =>[];
}
