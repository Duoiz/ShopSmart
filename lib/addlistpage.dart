import 'package:flutter/material.dart';
import 'package:flutter_shopsmart/Checklist.dart';
import 'package:flutter_shopsmart/addinglistpage.dart';

class MyLists extends StatefulWidget {
  const MyLists({super.key});

  @override
  State<MyLists> createState() => _MyListsState();
}

class _MyListsState extends State<MyLists> {
  List<Map<String, dynamic>> lists = [];

  void _addList(String name, String repeat, List<DateTime> dates) {
    setState(() {
      lists.add({'name': name, 'repeat': repeat, 'dates': dates});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("MY LIST"),
        actions: [
          Padding(
            padding: EdgeInsets.all(8),
            child: Container(
              height: 20,
              width: 100,
              color: Colors.grey[300],
              child: GestureDetector(
                child: Text("Add more list"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddList(onAddList: _addList),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
        backgroundColor: Colors.grey.shade300,
      ),
      backgroundColor: Colors.grey.shade300,
      body: ListView.builder(
        itemCount: lists.length,
        itemBuilder: (context, index) {
          var list = lists[index];
          return Card(
            margin: EdgeInsets.all(10),
            color: Colors.white,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Checklist()),
                );
              },
              child: ListTile(
                title: Text(list['name']), // Only show the list name
              ),
            ),
          );
        },
      ),
    );
  }
}
