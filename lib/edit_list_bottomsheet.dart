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
    final categoryController = TextEditingController(text: item['category']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Item"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController),
            SizedBox(height: 10),
            TextField(controller: qtyController),
            SizedBox(height: 10),
            TextField(controller: categoryController),
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
                  'category': categoryController.text.trim(),
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