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

      void _addList(String name, String repeat, List<DateTime> dates) {
        setState(() {
          lists.add({'name': name, 'repeat': repeat, 'dates': dates});
          latestList = {'name': name, 'repeat': repeat, 'dates': dates};
        });
      }
  Widget build(BuildContext context) {
    final listProvider = Provider.of<ListProvider>(context);


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
                      builder: (context) => AddList(),
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
        itemCount: listProvider.lists.length,
        itemBuilder: (context, index) {
          var list = listProvider.lists[index];
          return Card(
            margin: EdgeInsets.all(10),
            color: Colors.white,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Checklist(selectedList: list),
                  ),
                );
              },
              child: ListTile(
                title: Text(list['name']),
              ),
            ),
          );
        },
      ),
    );
  }
}