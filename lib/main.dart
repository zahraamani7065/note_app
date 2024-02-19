import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:note_app/core/Services/locator.dart';
import 'package:note_app/core/configs/theme_config.dart';
import 'package:note_app/features/main/presentation/screens/home.dart';

import 'features/main/data/data_source/local/data.dart';
const taskBoxName="tasks";
void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter<Data>(NoteAdapter());
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


