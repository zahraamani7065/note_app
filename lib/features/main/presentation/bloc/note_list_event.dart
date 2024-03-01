
part of 'note_list_bloc.dart';


@immutable
abstract class NoteListEvent{}

class GetAllDataEvent extends NoteListEvent{}
class SaveDataEvent extends NoteListEvent{
  final DataEntity dataEntity;

  SaveDataEvent(this.dataEntity);

}
class DeleteAllEvent extends NoteListEvent{}
class DeleteEvent extends NoteListEvent{
  final int index;

  DeleteEvent({required this.index});


}