// ignore_for_file: file_names

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_flashcards/screens/SetDetails.dart';
import 'package:hive_flutter/hive_flutter.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = const SetPage();
        break;
      case 1:
        page = const Placeholder();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                extended: constraints.maxWidth >= 600,
                backgroundColor: Theme.of(context).colorScheme.outline,
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(
                      Icons.home,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(
                      Icons.question_answer,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                    label: Text('Favorites'),
                  ),
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) {
                  setState(() {
                    selectedIndex = value;
                  });
                },
              ),
            ),
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: page,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class SetPage extends StatefulWidget {
  const SetPage({Key? key}) : super(key: key);

  @override
  State<SetPage> createState() => _SetPageState();
}

class _SetPageState extends State<SetPage> {
  List<Map<String, dynamic>> items = [];

  final sets = Hive.box('sets_box');

  @override
  void initState() {
    super.initState();
    refreshItems(); // Load data when app starts
  }

  void refreshItems() {
    final data = sets.keys.map((key) {
      final value = sets.get(key);
      return {
        "key": key,
        "name": value["name"],
        "description": value['description']
      };
    }).toList();
    stdout.writeln(data);
    setState(() {
      items = data.reversed.toList();
    });
  }

  Future<void> createItem(Map<String, dynamic> newItem) async {
    await sets.add(newItem);
    refreshItems();
  }

  Map<String, dynamic> readItem(int key) {
    final item = sets.get(key);
    return item;
  }

  Future<void> updateItem(int key, Map<String, dynamic> value) async {
    await sets.put(key, value);
    refreshItems();
  }

  Future<void> deleteItem(int key) async {
    await sets.delete(key);
    refreshItems();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('A set has been deleted.'),
    ));
  }

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  void showForm(BuildContext context, int? itemKey) async {
    if (itemKey != null) {
      final existingCard =
          items.firstWhere((element) => element['key'] == itemKey);
      nameController.text = existingCard['name'];
      descriptionController.text = existingCard['description'];
    }

    showModalBottomSheet(
        context: context,
        elevation: 5,
        isScrollControlled: true,
        builder: (_) => Container(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  top: 15,
                  left: 15,
                  right: 15),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(hintText: 'Name'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: descriptionController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: 'Description'),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      // Save new item
                      if (itemKey == null) {
                        createItem({
                          "name": nameController.text,
                          "description": descriptionController.text
                        });
                      }

                      // update an existing item
                      if (itemKey != null) {
                        updateItem(itemKey, {
                          'name': nameController.text.trim(),
                          'description': descriptionController.text.trim()
                        });
                      }

                      // Clear the text fields
                      nameController.text = '';
                      descriptionController.text = '';

                      Navigator.of(context).pop(); // Close the bottom sheet
                    },
                    child: Text(itemKey == null ? 'Create New' : 'Update'),
                  ),
                  const SizedBox(
                    height: 15,
                  )
                ],
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Flashcards'),
      ),
      body: items.isEmpty
          ? const Center(
              child: Text(
                'No Data',
                style: TextStyle(fontSize: 30),
              ),
            )
          : ListView.builder(
              // the list of items
              itemCount: items.length,
              itemBuilder: (_, index) {
                final currentItem = items[index];
                return Card(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  margin: const EdgeInsets.all(10),
                  elevation: 3,
                  child: ListTile(
                    title: Text(currentItem['name']),
                    subtitle: Text(currentItem['description'].toString()),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => SetDetails(set: currentItem)));
                    },
                  ),
                );
              }),
      // Add new item button
      floatingActionButton: FloatingActionButton(
        onPressed: () => showForm(context, null),
        child: const Icon(Icons.add),
      ),
    );
  }
}
