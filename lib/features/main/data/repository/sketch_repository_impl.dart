import 'package:hive/hive.dart';
import '../../domain/entity/sketch_entity.dart';
import '../../domain/repository/drawing_repository.dart';
import '../data_source/local/drawing_data.dart';
import '../../../../main.dart';

class SketchRepositoryImpl implements SketchRepository {
  final box = Hive.box<DrawingData>(drawingAdapter);


  @override
  Future<void> addSketch(List<SketchEntity> sketches) async {
    final dataList = sketches.map((sketch) => _convertToDrawingData(sketch)).toList();
    for (var data in dataList) {
      await box.add(data);
    }

  }

  DrawingData _convertToDrawingData(SketchEntity sketch) {
    return DrawingData(
      points: sketch.points,
      color: sketch.color,
      size: sketch.size,
      filled: sketch.filled,
      type: sketch.type,
      sides: sketch.sides,
    );
  }

  @override
  Future<void> undoSketch() async {
    // Implement undoing sketch in local data source


  }

  @override
  Future<void> redoSketch() async {
    // Implement redoing sketch in local data source
  }

  @override
  Future<void> clearSketches() async {
    // Implement clearing sketches in local data source
  }
}