import '../entity/data_entity.dart';
import '../repository/data_repository.dart';

class DeleteAllUseCase {
  final DataRepository dataRepository;

  DeleteAllUseCase(this.dataRepository);


  @override
  Future<void> call(int index) {
    return dataRepository.delete(index);

  }


}