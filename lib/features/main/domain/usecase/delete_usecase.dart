import 'package:note_app/core/resorces/data_state.dart';

import '../entity/data_entity.dart';
import '../repository/data_repository.dart';

class DeleteAllUseCase {
  final DataRepository dataRepository;

  DeleteAllUseCase({required this.dataRepository});


  @override
  Future<DataState> call() {
    return dataRepository.deleteAll();

  }


}