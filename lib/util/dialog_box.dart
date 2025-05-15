import 'package:flutter/material.dart';
import 'package:flutter_shopsmart/util/utils.dart';
class DialogBox extends StatelessWidget {
  final Function(String name, String qty, String category) onSave;

  const DialogBox({
    super.key,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final itemController = TextEditingController();
    final qtyController = TextEditingController();
    String? selectedCategory;

    List<DropdownMenuItem<String>> categories = const [
      DropdownMenuItem(value: "Vegetable", child: Text("Vegetable")),
      DropdownMenuItem(value: "Fruit", child: Text("Fruit")),
      DropdownMenuItem(value: "Meat", child: Text("Meat")),
    ];

    return AlertDialog(
      backgroundColor: Colors.white,
      title: Text("Add Item"),
      content: SizedBox(
        height: 320,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Insert QTY/KG",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Select Category',
                border: OutlineInputBorder(),
              ),
              value: selectedCategory,
              items: categories,
              onChanged: (value) {
                selectedCategory = value;
              },
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    String name = itemController.text.trim();
                    String qty = qtyController.text.trim();
                    String category = selectedCategory ?? "";

                    // Validation
                    if (name.isEmpty || qty.isEmpty || category.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("All fields are required!"),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 50),
                        duration: Duration(seconds: 3),
                      ),
                    );
                    return;
                  }

                  if (!RegExp(r'^\d+$').hasMatch(qty)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Quantity must be a number!"),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 50),
                        duration: Duration(seconds: 3),
                      ),
                    );
                    return;
                  }

                    onSave(name, qty, category);
                    Navigator.pop(context); // Close dialog
                  },
                  child: Text("Save"),
                ),
                TextButton(
                  onPressed: Navigator.of(context).pop,
                  child: Text("Cancel"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}