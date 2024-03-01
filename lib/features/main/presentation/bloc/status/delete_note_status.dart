import 'package:equatable/equatable.dart';

abstract class DeleteDataStatus extends Equatable {}

class DeleteDataLoading extends DeleteDataStatus {
  @override
  List<Object?> get props => [];
}

class DeleteDataCompleted extends DeleteDataStatus {
  @override
  List<Object?> get props => [];
}

class DeleteDataError extends DeleteDataStatus {
  final String? message;

  DeleteDataError(this.message);

  @override
  List<Object?> get props => [message];
}