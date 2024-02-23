import '../repository/data_repository.dart';

class DeleteUseCase {
  final DataRepository dataRepository;

  DeleteUseCase(this.dataRepository);


  @override
  Future<void> call() {
    return dataRepository.deleteAll();
  }

}