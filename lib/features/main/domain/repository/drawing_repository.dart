import 'package:note_app/features/main/domain/entity/sketch_entity.dart';

import '../../data/model/sketch.dart';

abstract class DrawingRepository {
  Future<void> addSketch(SketchEntity sketchEntity);
  Future<void> undoSketch();
  Future<void> redoSketch();
  Future<void> clearSketches();
}