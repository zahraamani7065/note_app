
import 'package:equatable/equatable.dart';

import '../../../domain/entity/data_entity.dart';

abstract class GetAllDataStatus extends Equatable {}
class GetAllDataLoading extends GetAllDataStatus {

  @override
  // TODO: implement props
  List<Object?> get props => [];

}
class GetAllDataCompleted extends GetAllDataStatus {
  final List<DataEntity> data;
  GetAllDataCompleted(this.data);

  @override
  // TODO: implement props
  List<Object?> get props => [data];

}

class GetAllDataError extends GetAllDataStatus {

  final String? message;
  GetAllDataError(this.message);

  @override
  // TODO: implement props
  List<Object?> get props => [message];

}