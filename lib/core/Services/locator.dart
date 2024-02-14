import 'package:get_it/get_it.dart';
import 'package:note_app/features/main/data/data_source/local/data.dart';

import '../../features/main/data/repository/data_repository_impl.dart';
import '../../features/main/domain/repository/data_repository.dart';
import '../../features/main/domain/usecase/get_all_data_usecase.dart';
import '../../features/main/domain/usecase/save_data_usecase.dart';
import '../../features/main/presentation/bloc/note_list_bloc.dart';

GetIt locator=GetIt.instance;
setUp() async {
  //adapter
  locator.registerFactory<NoteAdapter>(() => NoteAdapter());

  //repository
  locator.registerSingleton<DataRepository>(DataRepositoryImpl());


  //usecase
  locator.registerSingleton<GetAllDataUseCase>(GetAllDataUseCase(dataRepository: locator()));
  locator.registerSingleton<SaveDataUseCase>(SaveDataUseCase(dataRepository: locator()));

  //bloc
  locator.registerFactory(() => NoteListBloc(locator(),locator()));

}