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
      final existingData = await _findExistingData(data);
      if (existingData != null) {
        // Get the index of the existing data
        final index = box.values.toList().indexOf(existingData);
        if (index != -1) {
          await box.putAt(index, Data.fromDataEntity(data));
          print("Data updated: $data");
        } else {
          // Handle error: Existing data not found in the box
        }
      } else {
        Data task = Data.fromDataEntity(data);
        await box.add(task);
        print("Data added: $data");
      }
      return DataSuccess(data);
    } on HiveError catch (error) {
      return DataFailed(error.message);
    }
    // try {
    //   // box.clear();
    //   final existingData = await _findExistingData(data);
    //   if (existingData != null) {
    //     final key = box.key(existingData);
    //     await box.put( existingData, Data.fromDataEntity(data));
    //     print("Data updated: $data");
    //   } else {
    //
    //     Data task = Data.fromDataEntity(data);
    //     await box.add(task);
    //     print("Data added: $data");
    //   }
    //   return DataSuccess(data);
    // } on HiveError catch (error) {
    //   return DataFailed(error.message);
    // }
  }

  Future<Data?> _findExistingData(DataEntity newData) async {
    for (var data in box.values) {
      if (data.name == newData.name ) {
        return data;
      }
    }
    return null;
  }


  @override
  Future<DataState> delete(int index) async {
    try {
      await box.deleteAt(index);
      return DataSuccess(box.values);
    } catch (error) {
      return DataFailed(error.toString());

    }
  }

  @override
  Future<DataState> deleteAll() async{
    try {
      await box.clear();
      return DataSuccess(box.values);
    } catch (error) {
      return DataFailed(error.toString());
    }
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
