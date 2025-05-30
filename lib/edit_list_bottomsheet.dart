import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_shopsmart/list_provider.dart';


class EditListBottomSheet extends StatefulWidget {
  final List<Map<String, String>> items;

  const EditListBottomSheet({super.key, required this.items});

  @override
  State<EditListBottomSheet> createState() => _EditListBottomSheetState();
}

class _EditListBottomSheetState extends State<EditListBottomSheet> {
  late List<Map<String, String>> editedItems;

  @override
  void initState() {
    super.initState();
    editedItems = List.from(widget.items);
  }

  void _editItem(int index) {
    final item = editedItems[index];

    final nameController = TextEditingController(text: item['name']);
    final qtyController = TextEditingController(text: item['qty']);
    String selectedCategory = item['category'] ?? "Uncategorized";

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Item"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: InputDecoration(hintText: "Item Name")),
            SizedBox(height: 10),
            TextField(controller: qtyController, decoration: InputDecoration(hintText: "Quantity/KG")),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: InputDecoration(hintText: "Category"),
              items: const [
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
              ],
              onChanged: (value) {
                selectedCategory = value ?? "Uncategorized";
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                editedItems[index] = {
                  'name': nameController.text.trim(),
                  'qty': qtyController.text.trim(),
                  'category': selectedCategory,
                };
              });
              Navigator.pop(context);
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              "Edit Items",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: editedItems.length,
            itemBuilder: (context, index) {
              final item = editedItems[index];
              return ListTile(
                title: Text(item['name'] ?? ''),
                subtitle: Text("${item['qty']} - ${item['category']}"),
                onTap: () => _editItem(index),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {
                final listProvider =
                    Provider.of<ListProvider>(context, listen: false);

                final updatedList = {
                  ...listProvider.latestList!,
                  'items': editedItems,
                };

                listProvider.updateList(listProvider.latestList!, updatedList);
                Navigator.pop(context);
              },
              child: Text("Save All Changes"),
            ),
          ),
        ],
      ),
    );
  }
}