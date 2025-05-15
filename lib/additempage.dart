import 'package:flutter/material.dart';
import 'package:flutter_shopsmart/util/dialog_box.dart';

class Additempage extends StatefulWidget {
  const Additempage({super.key});

  @override
  State<Additempage> createState() => _AdditempageState();
}

class _AdditempageState extends State<Additempage> {
  List<Map<String, String>> items = [];

  void newitembox() {
    showDialog(
      context: context,
      builder: (context) {
        return DialogBox(
          onSave: (name, qty, category) {
            setState(() {
              items.add({'name': name, 'qty': qty, 'category': category});
            });
          },
        );
      },
    );
  }

  void deleteItem(int index) {
    setState(() {
      items.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        title: Text("Add Item u focc not"),
        backgroundColor: Colors.grey.shade300,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: newitembox,
        backgroundColor: Colors.white,
        child: Icon(Icons.add),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(15),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Container(
            margin: EdgeInsets.symmetric(vertical: 8),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 30.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: TextStyle(fontSize: 16),
                          children: [
                            TextSpan(
                              text: "ITEM NAME: ",
                              style: TextStyle(color: Colors.red),
                            ),
                            TextSpan(
                              text: item['name'],
                              style: TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 5),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(fontSize: 16),
                          children: [
                            TextSpan(
                              text: "QTY/KG: ",
                              style: TextStyle(color: Colors.red),
                            ),
                            TextSpan(
                              text: item['qty'],
                              style: TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 5),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(fontSize: 16),
                          children: [
                            TextSpan(
                              text: "CATEGORY: ",
                              style: TextStyle(color: Colors.red),
                            ),
                            TextSpan(
                              text: item['category'],
                              style: TextStyle(color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: () => deleteItem(index),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
