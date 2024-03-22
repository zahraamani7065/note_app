import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:note_app/core/Services/locator.dart';
import 'package:note_app/core/configs/theme_config.dart';
import 'package:note_app/features/main/data/data_source/local/drawing_data.dart';
import 'package:note_app/features/main/presentation/screens/home.dart';
import 'features/main/data/data_source/local/data.dart';
import 'features/main/data/data_source/local/offset_adapter.dart';
import 'features/main/data/data_source/local/sketch_type_adapter.dart';
import 'features/main/data/model/sketch.dart';

const taskBoxName="NoteAdapter";
const drawingAdapter="DrawingAdapter";
void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(OffsetAdapter());
  Hive.registerAdapter<Data>(NoteAdapter());
  Hive.registerAdapter<DrawingData>(DrawingAdapter());
  Hive.registerAdapter<SketchType>(SketchTypeAdapter());
  Hive.registerAdapter<Color>(ColorAdapter());
  await Hive.openBox<DrawingData>(drawingAdapter);
  await Hive.openBox<Data>(taskBoxName);

  await setUp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeConfig().getTheme(context),
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}


