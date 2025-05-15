import 'package:flutter/material.dart';
import 'package:flutter_shopsmart/util/my_button.dart';

class DialogBox extends StatefulWidget {
  final Function(String, String, String) onSave;

  const DialogBox({super.key, required this.onSave});

  @override
  State<DialogBox> createState() => _DialogBoxState();
}

class _DialogBoxState extends State<DialogBox> {
  final TextEditingController itemController = TextEditingController();
  final TextEditingController qtyController = TextEditingController();
  String? selectedCategory;

  //dadagdagan pa to
  List<DropdownMenuItem<String>> category = const [
    DropdownMenuItem(value: "Vegetable", child: Text("Vegetable")),
    DropdownMenuItem(value: "Fruit", child: Text("Fruit")),
    DropdownMenuItem(value: "Meat", child: Text("Meat")),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        AlertDialog(
          backgroundColor: Colors.white,
          content: SizedBox(
            height: 320,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Add Item", style: TextStyle(fontSize: 20)),
                SizedBox(height: 10),
                TextField(
                  controller: itemController,
                  decoration: InputDecoration(
                    hintText: "Insert item name",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: qtyController,
                  decoration: InputDecoration(
                    hintText: "Insert QTY/KG",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Select Category',
                  ),
                  value: selectedCategory,
                  items: category,
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value;
                    });
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    MyButton(
                      text: "Save",
                      onPressed: () {
                        widget.onSave(
                          itemController.text,
                          qtyController.text,
                          selectedCategory ?? "",
                        );
                        Navigator.pop(context);
                      },
                    ),
                    MyButton(
                      text: "Cancel",
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
