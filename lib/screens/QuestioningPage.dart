// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class QuestioningPage extends StatelessWidget {
  QuestioningPage({super.key});

  final sets = Hive.box('sets_box').keys.map((key) {
    final value = Hive.box('sets_box').get(key);
    return {
      "key": key,
      "name": value["name"],
      "description": value['description'],
    };
  });

  @override
  Widget build(BuildContext context) {
    // create a dropwdown of a list, when the user selects an item, navigate to the Questioning page and pass the selected item as an argument
    return Scaffold(
      appBar: AppBar(
        title: const Text('Questioning'),
      ),
      body: Center(
        child: Column(
          children: [
            const Text('Select a set to question'),
            const SizedBox(
              height: 32,
            ),
            DropdownMenu<int>(
              label: const Text('Select a set'),
              dropdownMenuEntries: [
                ...sets.map((e) => DropdownMenuEntry<int>(
                      value: e['key'],
                      label: (e['name']),
                    ))
              ],
              onSelected: (value) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Questioning(
                      setKey: value,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class Questioning extends StatefulWidget {
  final int? setKey;
  const Questioning({this.setKey, super.key});

  @override
  State<Questioning> createState() => _QuestioningState();
}

class _QuestioningState extends State<Questioning> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Questioning'),
      ),
      body: const Center(
        child: Text('Questioning'),
      ),
    );
  }
}
