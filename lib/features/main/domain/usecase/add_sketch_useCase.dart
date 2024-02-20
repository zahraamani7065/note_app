import '../entity/sketch_entity.dart';
import '../repository/drawing_repository.dart';

class AddSketchUseCase {
  final SketchRepository sketchRepository;

  AddSketchUseCase({required this.sketchRepository});

  Future<void> call(List<SketchEntity> sketches) async {
    try {
      await sketchRepository.addSketch(sketches);
    } catch (e) {

      print('Error saving sketches: $e');
      rethrow;
    }
  }
}