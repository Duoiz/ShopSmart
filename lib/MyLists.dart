import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_shopsmart/list_provider.dart';
import 'checklist.dart';
import 'addinglistpage.dart';

class MyLists extends StatefulWidget {
  const MyLists({super.key});

  @override
  State<MyLists> createState() => _MyListsState();
}

class _MyListsState extends State<MyLists> {
  @override
  List<Map<String, dynamic>> lists = [];
  Map<String, dynamic>? latestList;

  @override
  Widget build(BuildContext context) {
    final listProvider = Provider.of<ListProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("MY LIST"),
              backgroundColor: const Color(0xFFF8F4EB),
        actions: [
          Padding(
            padding: EdgeInsets.all(8),
            child: Container(
              height: 20,
              width: 100,
              color: const Color(0xFFF8F4EB),
              child: GestureDetector(
                child: Text("Add new list"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddList(),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF8F4EB),
      body: ListView.builder(
        itemCount: listProvider.lists.length,
        itemBuilder: (context, index) {
          var list = listProvider.lists[index];
          return Dismissible(
            key: Key(list['name']),
            direction: DismissDirection.endToStart,
            confirmDismiss: (direction) async {
              // Show confirmation dialog before deleting
              return await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text("Delete List"),
                  content: Text("Are you sure?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false), // Return false to prevent dismissal
                      child: Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () {
                        listProvider.removeList(index);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("List deleted"),
                            duration: Duration(seconds: 2),
                          ),
                        );
                        Navigator.pop(context, true); // Return true to allow dismissal
                      },
                      child: Text("Delete"),
                    ),
                  ],
                ),
              ) ?? false; // If the dialog is dismissed without a choice, return false
            },
            onDismissed: (direction) {
              // This is now empty because the removal is handled in confirmDismiss
            },
            background: Container(
              alignment: Alignment.centerRight,
              padding: EdgeInsets.symmetric(horizontal: 16),
              color: Colors.red,
              child: Icon(Icons.delete, color: Colors.white),
            ),
            child: Card(
              margin: EdgeInsets.all(10),
              color: Colors.white,
              child: ListTile(
                title: Text(list['name']),
                subtitle: Text("Repeat: ${list['repeat']}"),
                onTap: () {
                  if (listProvider.latestList != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Checklist(selectedList: listProvider.latestList),
                      ),
                    );
                  } else {
                    // Handle the case where latestList is null (e.g., display a message)
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("No list selected.")),
                    );
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }
}