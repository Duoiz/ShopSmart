import 'package:flutter/material.dart';
import 'package:flutter_shopsmart/list_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_shopsmart/additempage.dart';
import 'package:flutter_shopsmart/edit_list_bottomsheet.dart';

class Checklist extends StatefulWidget {
  final Map<String, dynamic>? selectedList;

  const Checklist({Key? key, this.selectedList}) : super(key: key);

  @override
  _ChecklistState createState() => _ChecklistState();
}

class _ChecklistState extends State<Checklist> {
  List<Map<String, dynamic>> items = [];
  Map<String, bool> _checkedItems = {};
  Map<String, TextEditingController> _estPriceControllers = {};
  Map<String, TextEditingController> _actualPriceControllers = {};

  @override
  void initState() {
    super.initState();
    _initializeFromList(widget.selectedList);
  }

  @override
  void didUpdateWidget(covariant Checklist oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedList != oldWidget.selectedList) {
      _disposeControllers();
      _initializeFromList(widget.selectedList);
      setState(() {});
    }
  }

  void _initializeFromList(Map<String, dynamic>? selectedList) {
    final dynamic itemsData = selectedList?['items'];
    if (itemsData is List) {
      items = List<Map<String, dynamic>>.from(itemsData);
    } else {
      items = [];
    }

    _checkedItems = {
      for (var item in items) item['name']!.toString(): false
    };

    _estPriceControllers = {};
    _actualPriceControllers = {};

    for (var item in items) {
      final itemName = item['name']!.toString();

      // Initialize controllers safely
      _estPriceControllers[itemName] = TextEditingController(text: item['estPrice']?.toString());
      _actualPriceControllers[itemName] = TextEditingController(text: item['actualPrice']?.toString());

      // Add listeners to save changes in real-time
      _estPriceControllers[itemName]!.addListener(() {
        _updateItemPrice(itemName, 'estPrice', _estPriceControllers[itemName]!.text);
      });

      _actualPriceControllers[itemName]!.addListener(() {
        _updateItemPrice(itemName, 'actualPrice', _actualPriceControllers[itemName]!.text);
      });
    }
  }

  void _updateItemPrice(String itemName, String priceType, String newValue) {
    try {
      // Validate the new value to ensure it's a valid number
      if (newValue.isNotEmpty && double.tryParse(newValue) == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Invalid price format. Please enter a valid number.")),
        );
        return; // Exit if the format is invalid
      }

      setState(() {
        final itemIndex = items.indexWhere((item) => item['name'] == itemName);
        if (itemIndex != -1) {
          items[itemIndex][priceType] = newValue;
        }
      });
      _saveUpdatedList(context.read<ListProvider>());
    } catch (e) {
      print("Error updating item price: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update item price. Please try again.")),
      );
    }
  }

  void _disposeControllers() {
    for (var controller in _estPriceControllers.values) {
      controller.dispose();
    }
    for (var controller in _actualPriceControllers.values) {
      controller.dispose();
    }
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  void _saveUpdatedList(ListProvider listProvider) async {
    final updatedList = {
      ...widget.selectedList!,
      'items': items,
    };
    await listProvider.updateList(widget.selectedList!, updatedList);
  }

  void _showEditItemDialog(BuildContext context, String itemName) {
    final item = items.firstWhere((i) => i['name'] == itemName);

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
          TextButton(onPressed: Navigator.of(context).pop, child: Text("Cancel")),
          TextButton(
            onPressed: () {
              try {
                setState(() {
                  item['name'] = nameController.text;
                  item['qty'] = qtyController.text;
                  item['category'] = selectedCategory;
                });
                Navigator.pop(context);
              } catch (e) {
                print("Error updating item: $e");
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Failed to update item. Please try again.")),
                );
              }
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _saveUpdatedList(context.read<ListProvider>());
        return true;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F4EB),
        appBar: AppBar(
          title: Text("Checklist", style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: const Color(0xFFF8F4EB),
          actions: [
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () async {
                final newItem = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddItemPage()),
                );
                if (newItem != null && newItem is List<Map<String, String>>) {
                  // Create a copy of the existing items
                  List<Map<String, dynamic>> updatedItems = List.from(items);

                  // Add the new items to the updated list
                  for (var item in newItem) {
                    // Ensure 'estPrice' and 'actualPrice' are initialized
                    item['estPrice'] = item['estPrice'] ?? "";
                    item['actualPrice'] = item['actualPrice'] ?? "";

                    updatedItems.add(item);
                  }

                  // Update the state with the new items
                  setState(() {
                    items = updatedItems;
                  });

                  // Save the updated list to the ListProvider
                  _saveUpdatedList(context.read<ListProvider>());

                  // Update the latest list in ListProvider
                  context.read<ListProvider>().loadLists();
                }
              },
            ),
          ],
        ),
        body: Column(
          children: [
            _buildHeaderRow(),
            Expanded(
              child: items.isEmpty
                  ? Center(child: Text("No items in this list"))
                  : ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final itemName = item['name']!;
                        final qty = item['qty'] ?? "1";
                        final category = item['category'] ?? "Uncategorized";

                        return _buildChecklistRow(itemName, qty, category);
                      },
                    ),
            ),
            _buildCategorySummary(),
            _buildBottomSummaryBar(),
            Container(height: 4),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Padding(
      padding: EdgeInsets.only(top: 8, left: 8, right: 8),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            height: 35,
            width: 160,
            color: const Color(0xFFF8F4EB),
            child: Text(
              "Item",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            padding: EdgeInsets.all(8),
            height: 35,
            width: 65,
            color: const Color(0xFFF8F4EB),
            child: Text("QTY/KG", style: TextStyle(fontSize: 12)),
          ),
          Container(
            alignment: Alignment.center,
            height: 35,
            width: 65,
            color: const Color(0xFFF8F4EB),
            child: Text("EST. PRICE", style: TextStyle(fontSize: 11)),
          ),
          Container(
            alignment: Alignment.center,
            height: 35,
            width: 65,
            color: const Color(0xFFF8F4EB),
            child: Text("ACTUAL", style: TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistRow(String itemName, String qty, String category) {
    final isChecked = _checkedItems[itemName] ?? false;

    return Dismissible(
      key: Key(itemName),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: 16),
        color: Colors.red,
        child: Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        setState(() {
          items.removeWhere((item) => item['name'] == itemName);
          _checkedItems.remove(itemName);
          _estPriceControllers.remove(itemName);
          _actualPriceControllers.remove(itemName);
        });
        _saveUpdatedList(context.read<ListProvider>());
        context.read<ListProvider>().loadLists(); // If you have a loadLists() method
      },
      child: GestureDetector(
        onTap: () => _showEditItemDialog(context, itemName),
        child: Row(
          children: [
            Container(
              height: 50,
              width: 160,
              color: const Color(0xFFF8F4EB),
              child: CheckboxListTile(
                title: _buildCheckboxLabel(itemName, isChecked),
                value: isChecked,
                onChanged: (bool? newValue) {
                  setState(() {
                    _checkedItems[itemName] = newValue ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 10, left: 20),
              height: 35,
              width: 65,
              color: const Color(0xFFF8F4EB),
              child: Text(qty),
            ),
            Container(
              height: 35,
              width: 65,
              padding: EdgeInsets.symmetric(horizontal: 2),
              child: TextField(
                controller: _estPriceControllers[itemName],
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                ),
                style: TextStyle(fontSize: 12),
              ),
            ),
            Container(
              height: 35,
              width: 65,
              padding: EdgeInsets.symmetric(horizontal: 2),
              child: TextField(
                controller: _actualPriceControllers[itemName],
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                ),
                style: TextStyle(fontSize: 12),
              ),
            ),
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () => _showEditItemDialog(context, itemName),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckboxLabel(String text, bool isChecked) {
    Widget label = Text(
      text,
      style: TextStyle(
        fontSize: 14,
        decoration: isChecked ? TextDecoration.lineThrough : null,
        color: isChecked ? Colors.grey : Colors.black,
      ),
    );

    return isChecked
        ? ColorFiltered(
            colorFilter: const ColorFilter.matrix(<double>[
              0.2126,
              0.7152,
              0.0722,
              0,
              0,
              0.2126,
              0.7152,
              0.0722,
              0,
              0,
              0.2126,
              0.7152,
              0.0722,
              0,
              0,
              0,
              0,
              0,
              1,
              0,
            ]),
            child: label,
          )
        : label;
  }

  Widget _buildCategorySummary() {
    Map<String, Map<String, double>> categoryTotals = {};

    for (var item in items) {
      final itemName = item['name']!;
      final category = item['category'] ?? "Uncategorized";
      final isChecked = _checkedItems[itemName] ?? false;

      if (isChecked) {
        final estPrice = double.tryParse(_estPriceControllers[itemName]?.text ?? "0.00") ?? 0.0;
        final actualPrice = double.tryParse(_actualPriceControllers[itemName]?.text ?? "0.00") ?? 0.0;

        if (!categoryTotals.containsKey(category)) {
          categoryTotals[category] = {'est': 0.0, 'actual': 0.0};
        }

        categoryTotals[category]!['est'] = (categoryTotals[category]!['est'] ?? 0.0) + estPrice;
        categoryTotals[category]!['actual'] = (categoryTotals[category]!['actual'] ?? 0.0) + actualPrice;
      }
    }

    if (categoryTotals.isEmpty) {
      return Container();
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.yellow.shade100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: categoryTotals.entries.map((entry) {
          final categoryName = entry.key;
          final estTotal = entry.value['est']!;
          final actualTotal = entry.value['actual']!;

          return Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "$categoryName:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "Est: ₱${estTotal.toStringAsFixed(2)} | Actual: ₱${actualTotal.toStringAsFixed(2)}",
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBottomSummaryBar() {
    int checkedCount = _checkedItems.values.where((v) => v).length;
    int totalCount = items.length;

    double estTotal = 0.0;
    double actualTotal = 0.0;

    for (var item in items) {
      final itemName = item['name']!;
      final category = item['category'] ?? "Uncategorized";
      final isChecked = _checkedItems[itemName] ?? false;

      final estPrice = double.tryParse(_estPriceControllers[itemName]?.text ?? "0.00") ?? 0.0;
      final actualPrice = double.tryParse(_actualPriceControllers[itemName]?.text ?? "0.00") ?? 0.0;

      estTotal += estPrice;
      if (isChecked) {
        actualTotal += actualPrice;
      }
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade400)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Checked $checkedCount/$totalCount items",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "Est: ₱${estTotal.toStringAsFixed(2)}  |  Actual: ₱${actualTotal.toStringAsFixed(2)}",
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    "Summary: ",
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  Text(
                    estTotal > actualTotal ? "Save more!" : "Spent more",
                    style: TextStyle(
                      fontSize: 12,
                      color: estTotal > actualTotal ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}