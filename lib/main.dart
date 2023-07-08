import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:flutter_flashcards/screens/HomePage.dart';

void main() async {
  await Hive.initFlutter();
  await Hive.openBox('sets_box');
  await Hive.openBox('cards_box');

  await Hive.box('sets_box').clear();
  await Hive.box('cards_box').clear();
  final setId = await Hive.box('sets_box')
      .add({'name': "First set", 'description': "This is the first set"});
  await Hive.box('cards_box').addAll([
    {'name': 'app', 'answer': 'Flutter Flashcards', 'set_id': setId},
    {'name': 'Something', 'answer': 'Nothing', 'set_id': 1}
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Flashcards',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.limeAccent),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}
