import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
      DropdownMenuItem(value: "Baby Products", child: Text("Baby Products")),
      DropdownMenuItem(value: "Bakery", child: Text("Bakery")),
      DropdownMenuItem(value: "Beverage", child: Text("Beverage")),
      DropdownMenuItem(value: "Canned Goods", child: Text("Canned Goods")),
      DropdownMenuItem(value: "Cleaning Supplies", child: Text("Cleaning Supplies")),
      DropdownMenuItem(value: "Dairy", child: Text("Dairy")),
      DropdownMenuItem(value: "Frozen Food", child: Text("Frozen Food")),
      DropdownMenuItem(value: "Fruit", child: Text("Fruit")),
      DropdownMenuItem(value: "Grains & Pasta", child: Text("Grains & Pasta")),
      DropdownMenuItem(value: "Household", child: Text("Household")),
      DropdownMenuItem(value: "Meat", child: Text("Meat")),
      DropdownMenuItem(value: "Personal Care", child: Text("Personal Care")),
      DropdownMenuItem(value: "Pet Supplies", child: Text("Pet Supplies")),
      DropdownMenuItem(value: "Pharmacy", child: Text("Pharmacy")),
      DropdownMenuItem(value: "Seafood", child: Text("Seafood")),
      DropdownMenuItem(value: "Snack", child: Text("Snack")),
      DropdownMenuItem(value: "Spices", child: Text("Spices")),
      DropdownMenuItem(value: "Vegetable", child: Text("Vegetable")),
      DropdownMenuItem(value: "Others", child: Text("Others")),
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
                      Fluttertoast.showToast(
                        msg: "All fields are required!",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                      );
                      return;
                    }

                    if (!RegExp(r'^[0-9]+$').hasMatch(qty)) {
                      Fluttertoast.showToast(
                        msg: "Quantity must be a number!",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
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