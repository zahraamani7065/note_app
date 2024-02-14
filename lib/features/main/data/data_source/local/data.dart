import 'package:hive/hive.dart';
import 'package:note_app/features/main/domain/entity/data_entity.dart';

part 'data.g.dart';

@HiveType(adapterName: "NoteAdapter", typeId: 0)
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

  Data(this.name, this.dateTime, this.drawingBytes, this.imagePath, this.text,
      this.videoPath);


  Data.fromDataEntity(DataEntity dataEntity){
    name=dataEntity.name;
    dateTime=dataEntity.dateTime;
    text=dataEntity.text;
    drawingBytes=dataEntity.drawingBytes;
    imagePath=dataEntity.imagePath;
    videoPath=dataEntity.videoPath;

  }

}
class NoParams{}
