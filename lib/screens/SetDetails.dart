// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SetDetails extends StatefulWidget {
  final set;

  const SetDetails({Map<String, dynamic>? this.set, Key? key})
      : super(key: key);

  @override
  _SetDetailsState createState() => _SetDetailsState();
}

class _SetDetailsState extends State<SetDetails> {
  List<Map<String, dynamic>> items = [];
  final cards = Hive.box('cards_box');

  @override
  void initState() {
    super.initState();
    refreshItems(); // Load data when app starts
  }

  void refreshItems() {
    final data = cards.keys
        .map((key) {
          final value = cards.get(key);
          return {
            "key": key,
            "name": value["name"],
            "answer": value['answer'],
            'setId': value['set_id']
          };
        })
        .where(
          (element) => element['setId'] == widget.set['key'],
        )
        .toList();

    setState(() {
      items = data.reversed.toList();
    });
  }

  Future<void> createItem(Map<String, dynamic> newItem) async {
    await cards.add(newItem);
    refreshItems();
  }

  Map<String, dynamic> readItem(int key) {
    final item = cards.get(key);
    return item;
  }

  Future<void> updateItem(int key, Map<String, dynamic> value) async {
    await cards.put(key, value);
    refreshItems();
  }

  Future<void> deleteItem(int key) async {
    await cards.delete(key);
    refreshItems();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('A card has been deleted.'),
    ));
  }

  final TextEditingController nameController = TextEditingController();
  final TextEditingController answerController = TextEditingController();

  void showForm(BuildContext context, int? itemKey) async {
    if (itemKey != null) {
      final existingCard =
          items.firstWhere((element) => element['key'] == itemKey);
      nameController.text = existingCard['name'];
      answerController.text = existingCard['answer'];
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
                    controller: answerController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: 'Answer'),
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
                          "answer": answerController.text,
                          'set_id': widget.set['key'],
                        });
                      }

                      // update an existing item
                      if (itemKey != null) {
                        updateItem(itemKey, {
                          'name': nameController.text.trim(),
                          'answer': answerController.text.trim()
                        });
                      }

                      // Clear the text fields
                      nameController.text = '';
                      answerController.text = '';

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
        title: Text(widget.set['name']),
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
                      subtitle: Text(currentItem['answer'].toString()),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Edit button
                          IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () =>
                                  showForm(context, currentItem['key'])),
                          // Delete button
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => deleteItem(currentItem['key']),
                          ),
                        ],
                      )),
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
