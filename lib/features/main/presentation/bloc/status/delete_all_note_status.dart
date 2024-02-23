import 'package:equatable/equatable.dart';

abstract class DeleteAllDataStatus extends Equatable {}

class DeleteAllDataLoading extends DeleteAllDataStatus {
  @override
  List<Object?> get props => [];
}

class DeleteAllDataCompleted extends DeleteAllDataStatus {
  @override
  List<Object?> get props => [];
}

class DeleteAllDataError extends DeleteAllDataStatus {
  final String? message;

  DeleteAllDataError(this.message);

  @override
  List<Object?> get props => [message];
}