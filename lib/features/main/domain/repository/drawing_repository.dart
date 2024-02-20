import '../entity/sketch_entity.dart';

abstract class SketchRepository {
  Future<void> addSketch(List< SketchEntity> sketchEntity);
  Future<void> undoSketch();
  Future<void> redoSketch();
  Future<void> clearSketches();
}