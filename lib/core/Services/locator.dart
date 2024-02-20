

import 'package:get_it/get_it.dart';

import '../../features/main/data/data_source/local/calor_adapter.dart';
import '../../features/main/data/data_source/local/drawing_data.dart';
import '../../features/main/data/data_source/local/offset_adapter.dart';
import '../../features/main/data/data_source/local/sketch_type_adapter.dart';
import '../../features/main/data/repository/sketch_repository_impl.dart';
import '../../features/main/domain/repository/drawing_repository.dart';
import '../../features/main/domain/usecase/add_sketch_useCase.dart';
import '../../features/main/data/data_source/local/data.dart';
import '../../features/main/data/repository/data_repository_impl.dart';
import '../../features/main/domain/repository/data_repository.dart';
import '../../features/main/domain/usecase/get_all_data_usecase.dart';
import '../../features/main/domain/usecase/save_data_usecase.dart';
import '../../features/main/presentation/bloc/note_list_bloc.dart';

GetIt locator=GetIt.instance;
setUp() async {
  //adapter
  locator.registerFactory<NoteAdapter>(() => NoteAdapter());
  locator.registerFactory<DrawingAdapter>(() => DrawingAdapter());
  locator.registerFactory<OffsetAdapter>(() => OffsetAdapter());
  locator.registerFactory<ColorAdapter>(() => ColorAdapter());
  locator.registerFactory<SketchTypeAdapter>(() => SketchTypeAdapter());
  //repository
  locator.registerSingleton<DataRepository>(DataRepositoryImpl());
  locator.registerSingleton<SketchRepository>(SketchRepositoryImpl());


  //usecase
  locator.registerSingleton<GetAllDataUseCase>(GetAllDataUseCase(dataRepository: locator()));
  locator.registerSingleton<SaveDataUseCase>(SaveDataUseCase(dataRepository: locator()));
  locator.registerSingleton<AddSketchUseCase>(AddSketchUseCase( sketchRepository:  locator()));



  //bloc
  locator.registerFactory(() => NoteListBloc(locator(),locator()));

}