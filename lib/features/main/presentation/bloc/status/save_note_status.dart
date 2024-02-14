
import 'package:equatable/equatable.dart';

import '../../../domain/entity/data_entity.dart';

abstract class SaveDataStatus extends Equatable{}

class  SaveTaskLoading extends SaveDataStatus{
  @override
  // TODO: implement props
  List<Object?> get props =>[];
}
class  SaveTaskCompleted extends SaveDataStatus{
  final DataEntity dataEntity;

  SaveTaskCompleted(this.dataEntity);
  @override
  // TODO: implement props
  List<Object?> get props => [dataEntity];

}
class  SaveTaskError extends SaveDataStatus{
  final String? message;

  SaveTaskError(this.message);
  @override
  // TODO: implement props
  List<Object?> get props =>[message];
}