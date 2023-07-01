import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:flutter_flashcards/screens/HomePage.dart';

void main() async {
  await Hive.initFlutter();
  await Hive.openBox('cards_box');
  await Hive.box('cards_box').clear();
  await Hive.box('cards_box')
      .add({'name': 'app', 'answer': 'Flutter Flashcards'});
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
