part of 'note_list_bloc.dart';

class NoteListState extends Equatable {
  final GetAllDataStatus getAllDataStatus;
  final SaveDataStatus saveDataStatus;
  final DeleteAllDataStatus deleteAllDataStatus;
  final DeleteDataStatus deleteDataStatus;

  NoteListState(
      {required this.deleteDataStatus,
      required this.getAllDataStatus,
      required this.deleteAllDataStatus,
      required this.saveDataStatus});

  NoteListState copywith({
    GetAllDataStatus? newGetAllDataStatus,
    SaveDataStatus? newSaveDataStatus,
    DeleteAllDataStatus? newDeleteAllDataStatus,
    DeleteDataStatus? newDeleteDataStatus,
  }) {
    return NoteListState(
      saveDataStatus: newSaveDataStatus ?? saveDataStatus,
      getAllDataStatus: newGetAllDataStatus ?? getAllDataStatus,
      deleteDataStatus: newDeleteDataStatus ?? deleteDataStatus,
      deleteAllDataStatus: newDeleteAllDataStatus ?? deleteAllDataStatus,
    );
  }

  @override
  // TODO: implement props
  List<Object?> get props => [
        saveDataStatus,
        getAllDataStatus,
        deleteAllDataStatus,
        deleteDataStatus,
      ];
}
