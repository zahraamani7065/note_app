import '../../../../core/resorces/data_state.dart';
import '../entity/data_entity.dart';

abstract class DataRepository{
  Future<DataState<List<DataEntity>>> getAll({String searchKeyword});
  Future<DataState> deleteAll();
  Future<DataState>  delete(int index);
  Future<DataState<DataEntity>> createOrUpdate(DataEntity data);

}