

part of 'note_list_bloc.dart';

class NoteListState extends Equatable{
  final GetAllDataStatus getAllDataStatus;
  final SaveDataStatus saveDataStatus;

   NoteListState({required this.getAllDataStatus, required this.saveDataStatus});

  NoteListState copywith({
    GetAllDataStatus? newGetAllDataStatus,
    SaveDataStatus? newSaveDataStatus,

  }) {
    return NoteListState(
      saveDataStatus: newSaveDataStatus ?? saveDataStatus,
      getAllDataStatus: newGetAllDataStatus ?? getAllDataStatus,

    );
  }

  @override
  // TODO: implement props
  List<Object?> get props => [saveDataStatus,getAllDataStatus,];

}