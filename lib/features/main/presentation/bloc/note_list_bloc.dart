import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_app/features/main/presentation/bloc/status/get_note_status.dart';
import 'package:note_app/features/main/presentation/bloc/status/save_note_status.dart';

import '../../../../core/resorces/data_state.dart';
import '../../data/data_source/local/data.dart';
import '../../domain/entity/data_entity.dart';
import '../../domain/usecase/get_all_data_usecase.dart';
import '../../domain/usecase/save_data_usecase.dart';

part 'note_list_event.dart';

part 'note_list_state.dart';

class NoteListBloc extends Bloc<NoteListEvent, NoteListState> {
  GetAllDataUseCase getAllDataUseCase;
  SaveDataUseCase saveDataUseCase;

  NoteListBloc(this.getAllDataUseCase,
      this.saveDataUseCase,) : super(NoteListState(
      getAllDataStatus: GetAllDataLoading(),
      saveDataStatus: SaveTaskLoading())) {
    on<GetAllDataEvent>((event, emit) async {
      try {
        emit(state.copywith(newGetAllDataStatus: GetAllDataLoading()));
        DataState dataState = await getAllDataUseCase(NoParams());

        // print("$dataState data state.");
        print("oo");
        if (dataState is DataSuccess) {
          emit(state.copywith(
              newGetAllDataStatus: GetAllDataCompleted(dataState.data)));
          print("Data fetched successfullyy...");
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
  }


}
