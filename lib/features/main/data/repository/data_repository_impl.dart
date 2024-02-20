import 'package:hive/hive.dart';
import 'package:note_app/core/resorces/data_state.dart';
import 'package:note_app/features/main/data/data_source/local/data.dart';
import 'package:note_app/features/main/domain/entity/data_entity.dart';
import 'package:note_app/features/main/domain/entity/sketch_entity.dart';
import 'package:note_app/features/main/domain/repository/data_repository.dart';

import '../../../../main.dart';

class DataRepositoryImpl extends DataRepository {
  final box = Hive.box<Data>(taskBoxName);

  @override
  Future<DataState<DataEntity>> createOrUpdate(DataEntity data) async {
    try {
      Data task = Data.fromDataEntity(data);
      await box.add(task);
      print(task);
      return DataSuccess(data);
    } on HiveError catch (error) {
      return DataFailed(error.message);
    }
  }

  @override
  Future<void> delete(int index) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future<void> deleteAll() {
    // TODO: implement deleteAll
    throw UnimplementedError();
  }

  @override
  Future<DataState<List<DataEntity>>> getAll({String? searchKeyword}) async {
    List<Data> tasks = box.values.toList();
    try {

      List<DataEntity> data = tasks
          .map(
            (task) {
              List<SketchEntity> sketchEntities = task.drawingDataList.map((drawingData) {
                return SketchEntity(
                  points: drawingData.points,
                  size: drawingData.size,
                  color: drawingData.color,
                  filled: drawingData.filled,
                  sides: drawingData.sides,
                );
              }).toList();
              return  DataEntity(
              name: task.name,
              dateTime: task.dateTime,
              text: task.text,
              imagePath: task.imagePath,
              videoPath: task.videoPath,
              drawingBytes: task.drawingBytes,
              sketchEntity:sketchEntities,
            );}
          )
          .toList();
      return DataSuccess(data);
    } catch (e) {
      return DataFailed(e.toString());
    }
  }
}
