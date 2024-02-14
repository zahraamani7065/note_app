import '../../../../core/resorces/data_state.dart';
import '../../../../core/usecases/use_case.dart';
import '../../data/data_source/local/data.dart';
import '../entity/data_entity.dart';
import '../repository/data_repository.dart';

class GetAllDataUseCase implements UseCase<DataState<List<DataEntity>>,NoParams>{
  final DataRepository dataRepository;

  GetAllDataUseCase({required this.dataRepository});


  @override
  Future<DataState<List<DataEntity>>> call(NoParams noParams) {
    return dataRepository.getAll();

  }
}