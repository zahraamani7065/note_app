import 'package:note_app/features/main/domain/entity/sketch_entity.dart';

import '../../domain/repository/drawing_repository.dart';

class DrawingRepositoryImpl implements DrawingRepository {


  DrawingRepositoryImpl();

  @override
  Future<void> addSketch(SketchEntity sketchEntity) async {
    // Implement adding sketch to local data source
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