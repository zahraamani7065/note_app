import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_app/features/main/presentation/bloc/status/delete_all_note_status.dart';
import 'package:note_app/features/main/presentation/bloc/status/delete_note_status.dart';
import 'package:note_app/features/main/presentation/bloc/status/get_note_status.dart';
import 'package:note_app/features/main/presentation/bloc/status/save_note_status.dart';

import '../../../../core/resorces/data_state.dart';
import '../../data/data_source/local/data.dart';
import '../../domain/entity/data_entity.dart';
import '../../domain/usecase/delete_all_usecase.dart';
import '../../domain/usecase/delete_usecase.dart';
import '../../domain/usecase/get_all_data_usecase.dart';
import '../../domain/usecase/save_data_usecase.dart';

part 'note_list_event.dart';

part 'note_list_state.dart';

class NoteListBloc extends Bloc<NoteListEvent, NoteListState> {
  GetAllDataUseCase getAllDataUseCase;
  SaveDataUseCase saveDataUseCase;
  DeleteAllUseCase deleteAllUseCase;
  DeleteUseCase deleteUseCase;

  NoteListBloc(
    this.getAllDataUseCase,
    this.deleteAllUseCase,
    this.deleteUseCase,
    this.saveDataUseCase,
  ) : super(NoteListState(
            getAllDataStatus: GetAllDataLoading(),
            saveDataStatus: SaveTaskLoading(),
            deleteDataStatus: DeleteDataLoading(),
            deleteAllDataStatus: DeleteAllDataLoading())) {
    on<GetAllDataEvent>((event, emit) async {
      try {
        emit(state.copywith(newGetAllDataStatus: GetAllDataLoading()));
        DataState dataState = await getAllDataUseCase(NoParams());

        if (dataState is DataSuccess) {
          emit(state.copywith(
              newGetAllDataStatus: GetAllDataCompleted(dataState.data)));

        }

        if (dataState is DataFailed) {
          emit(state.copywith(
              newGetAllDataStatus: GetAllDataError(dataState.error)));
        }
      } catch (e) {
        emit(
            state.copywith(newGetAllDataStatus: GetAllDataError(e.toString())));
      }
    });

    on<SaveDataEvent>((event, emit) async {
      try {
        emit(state.copywith(newSaveDataStatus: SaveTaskLoading()));

        final saveResult = await saveDataUseCase(event.dataEntity);
        DataState dataState = await getAllDataUseCase(NoParams());

        if (saveResult is DataSuccess) {
          emit(state.copywith(
            newSaveDataStatus: SaveTaskCompleted(saveResult.data!),
            newGetAllDataStatus: GetAllDataCompleted(dataState.data),
          ));

          print("save and get  are worked");
        } else if (saveResult is DataFailed) {
          emit(state.copywith(
              newSaveDataStatus: SaveTaskError(saveResult.error)));
          print("save task error");
        }
      } catch (e) {
        emit(state.copywith(newSaveDataStatus: SaveTaskError(e.toString())));
      }
    });
    on<DeleteAllEvent>((event, emit) async{

      try {
        emit(state.copywith(newDeleteAllDataStatus: DeleteAllDataLoading()));


        final deleteResult = await deleteAllUseCase();

        if (deleteResult is DataSuccess) {

          emit(state.copywith(newDeleteAllDataStatus: DeleteAllDataCompleted()));
          DataState dataState = await getAllDataUseCase(NoParams());
          emit(state.copywith(
              newGetAllDataStatus: GetAllDataCompleted(dataState.data)));
          print("All data deleted successfully.");
        } else if (deleteResult is DataFailed) {

          emit(state.copywith(
              newDeleteAllDataStatus: DeleteAllDataError(deleteResult.error)));
          print("Failed to delete all data: ${deleteResult.error}");
        }
      } catch (e) {

        emit(state.copywith(newDeleteAllDataStatus: DeleteAllDataError(e.toString())));
        print("Error deleting all data: $e");
      }

    });
    on<DeleteEvent>((event, emit) async{
      try {
        emit(state.copywith(newDeleteDataStatus: DeleteDataLoading()));

        final deleteResult = await deleteUseCase(event.index);

        if (deleteResult is DataSuccess) {

          emit(state.copywith(newDeleteDataStatus: DeleteDataCompleted()));
          DataState dataState = await getAllDataUseCase(NoParams());
          emit(state.copywith(
              newGetAllDataStatus: GetAllDataCompleted(dataState.data)));
          print("Data at index ${event.index} deleted successfully.");
        } else if (deleteResult is DataFailed) {

          emit(state.copywith(
              newDeleteDataStatus: DeleteDataError(deleteResult.error)));
          print("Failed to delete data at index ${event.index}: ${deleteResult.error}");
        }
      } catch (e) {
        emit(state.copywith(newDeleteDataStatus: DeleteDataError(e.toString())));
        print("Error deleting data at index ${event.index}: $e");
      }


    });
  }
}


