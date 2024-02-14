import '../../../../core/resorces/data_state.dart';
import '../../../../core/usecases/use_case.dart';
import '../entity/data_entity.dart';
import '../repository/data_repository.dart';

class SaveDataUseCase implements UseCase <DataState<DataEntity>,DataEntity>{
  final DataRepository dataRepository;

  SaveDataUseCase({required this.dataRepository});


  @override
  Future<DataState<DataEntity>> call(DataEntity dataEntity) {
    return dataRepository.createOrUpdate(dataEntity);
  }
}