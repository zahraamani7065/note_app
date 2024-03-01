import 'package:note_app/core/resorces/data_state.dart';

import '../repository/data_repository.dart';

class DeleteUseCase {
  final DataRepository dataRepository;

  DeleteUseCase({required this.dataRepository});


  @override
  Future<DataState> call(int index) {
    return dataRepository.delete(index);
  }

}