import 'package:flutter/material.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});
  @override
  State<ListScreen> createState() => _MyListScreenState();
}

class _MyListScreenState extends State<ListScreen> {
  List<String> items = ['Item A', 'Item B', 'Item C'];

  void _removeItem(int index) {
    setState(() {
      items.removeAt(index); // Removes the item at the specified index
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My List')),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(items[index]),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => _removeItem(index), // Call the remove function
            ),
          );
        },
      ),
    );
  }
}