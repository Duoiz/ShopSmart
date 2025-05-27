import 'package:flutter/material.dart';
import 'package:flutter_shopsmart/list_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_shopsmart/edit_list_bottomsheet.dart';
import 'package:flutter_shopsmart/additempage.dart';

class Checklist extends StatefulWidget {
  final Map<String, dynamic>? selectedList;

  const Checklist({super.key, this.selectedList});

  @override
  State<Checklist> createState() => _ChecklistState();
}

class _ChecklistState extends State<Checklist> {
  late List<Map<String, dynamic>> items;
  late Map<String, bool> _checkedItems;
  late Map<String, TextEditingController> _estPriceControllers;
  late Map<String, TextEditingController> _actualPriceControllers;

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
      item['estPrice'] = item['estPrice'] ?? "";
      item['actualPrice'] = item['actualPrice'] ?? "";

      _estPriceControllers[itemName] =
          TextEditingController(text: item['estPrice'].toString());
      _estPriceControllers[itemName]!.addListener(() {
        item['estPrice'] = _estPriceControllers[itemName]!.text;
        final listProvider = Provider.of<ListProvider>(context, listen: false);
        _saveUpdatedList(listProvider);
        setState(() {});
      });

      _actualPriceControllers[itemName] =
          TextEditingController(text: item['actualPrice'].toString());
      _actualPriceControllers[itemName]!.addListener(() {
        item['actualPrice'] = _actualPriceControllers[itemName]!.text;
        final listProvider = Provider.of<ListProvider>(context, listen: false);
        _saveUpdatedList(listProvider);
        setState(() {});
      });
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

  @override
  Widget build(BuildContext context) {
    final listProvider = Provider.of<ListProvider>(context);
    // If you want to always use the latest list:
    // _initializeFromList(listProvider.latestList);

    return WillPopScope(
      onWillPop: () async {
        // Save updated list before navigating back
        _saveUpdatedList(listProvider);
        return true;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F4EB),
        appBar: AppBar(
          title: Text("Checklist", style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: const Color(0xFFF8F4EB),
          actions: [
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => EditListBottomSheet(
                    items: items
                        .map<Map<String, String>>((item) => item.map((key, value) => MapEntry(key, value?.toString() ?? "")))
                        .toList(),
                  ),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () async {
                try {
                  final newItem = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddItemPage()),
                  );

                  if (newItem != null && newItem is List<Map<String, String>>) {
                    setState(() {
                      for (var item in newItem) {
                        // Ensure estPrice and actualPrice fields exist
                        item['estPrice'] = item['estPrice'] ?? "";
                        item['actualPrice'] = item['actualPrice'] ?? "";
                        items.add(item);

                        final itemName = item['name']!;
                        _checkedItems[itemName] = false;
                        _estPriceControllers[itemName] = TextEditingController(text: item['estPrice']);
                        _actualPriceControllers[itemName] = TextEditingController(text: item['actualPrice']);

                        _estPriceControllers[itemName]!.addListener(() {
                          item['estPrice'] = _estPriceControllers[itemName]!.text;
                          final listProvider = Provider.of<ListProvider>(context, listen: false);
                          _saveUpdatedList(listProvider);
                          setState(() {});
                        });

                        _actualPriceControllers[itemName]!.addListener(() {
                          item['actualPrice'] = _actualPriceControllers[itemName]!.text;
                          final listProvider = Provider.of<ListProvider>(context, listen: false);
                          _saveUpdatedList(listProvider);
                          setState(() {});
                        });
                      }
                      final listProvider = Provider.of<ListProvider>(context, listen: false);
                      _saveUpdatedList(listProvider);
                    });
                  }
                } catch (e) {
                  // Display a notification to the user
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Cannot add items when no list is selected."),
                    ),
                  );
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
                        // Wrap the row with GestureDetector to handle taps
                        return GestureDetector(
                          onTap: () =>
                              _showEditItemDialog(context, itemName),
                          child: _buildChecklistRow(itemName, qty, category),
                        );
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
      confirmDismiss: (direction) async {
        // Show confirmation dialog before deleting
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Delete Item'),
            content: Text('Are you sure you want to delete "$itemName"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ?? false;
      },
      onDismissed: (direction) {
        setState(() {
          items.removeWhere((item) => item['name'] == itemName);
          _checkedItems.remove(itemName);
          _estPriceControllers.remove(itemName)?.dispose();
          _actualPriceControllers.remove(itemName)?.dispose();
        });
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: 16),
        color: Colors.red,
        child: Icon(Icons.delete, color: Colors.white),
      ),
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
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 4, vertical: 8),
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
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              ),
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
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

  void _showEditItemDialog(BuildContext context, String itemName) {
    final item = items.firstWhere((i) => i['name'] == itemName);
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
            TextField(controller: nameController, decoration: InputDecoration(hintText: "Item Name")),
            SizedBox(height: 10),
            TextField(controller: qtyController, decoration: InputDecoration(hintText: "Quantity/KG")),
            SizedBox(height: 10),
            TextField(controller: categoryController, decoration: InputDecoration(hintText: "Category")),
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
                item['name'] = nameController.text;
                item['qty'] = qtyController.text;
                item['category'] = categoryController.text;
                // Optionally update controllers if name changed
                if (item['name'] != itemName) {
                  _estPriceControllers[item['name']!] = _estPriceControllers.remove(itemName)!;
                  _actualPriceControllers[item['name']!] = _actualPriceControllers.remove(itemName)!;
                  _checkedItems[item['name']!] = _checkedItems.remove(itemName)!;
                }
                final listProvider = Provider.of<ListProvider>(context, listen: false);
                _saveUpdatedList(listProvider);
              });
              Navigator.pop(context);
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  }

  void _saveUpdatedList(ListProvider listProvider) async {
    final updatedList = {
      ...widget.selectedList!,
      'items': items,
    };

    await listProvider.updateList(widget.selectedList!, updatedList);
    await listProvider.loadLists();

    // Get the latest version of this list from the provider
    final latest = listProvider.lists.firstWhere(
      (l) => l['id'] == widget.selectedList!['id'],
      orElse: () => updatedList,
    );
    setState(() {
      items = List<Map<String, dynamic>>.from(latest['items']);
    });
  }

  Widget _buildCategorySummary() {
    Map<String, Map<String, double>> categoryTotals = {};

    // Initialize totals for each category
    for (var item in items) {
      final itemName = item['name']!;
      final category = item['category'] ?? "Uncategorized";
      final isChecked = _checkedItems[itemName] ?? false;
      double estTotal = 0.0;

      final estPrice = double.tryParse(_estPriceControllers[itemName]?.text ?? "0.00") ?? 0.0;
      estTotal += estPrice;

      if (isChecked) {
        final estPrice = double.tryParse(_estPriceControllers[itemName]?.text ?? "0.00") ?? 0.0;
        final actualPrice = double.tryParse(_actualPriceControllers[itemName]?.text ?? "0.00") ?? 0.0;

        if (!categoryTotals.containsKey(category)) {
          categoryTotals[category] = {'est': 0.0, 'actual': 0.0};
        }
        categoryTotals[category]!['est'] = categoryTotals[category]!['est']! + estPrice;
        categoryTotals[category]!['actual'] = categoryTotals[category]!['actual']! + actualPrice;
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
    int totalCount = _checkedItems.length;

    double estTotal = 0.0;
    double actualTotal = 0.0;

    // Compute Est Total (always includes all items)
    for (var item in items) {
      final itemName = item['name']!;
      try {
        final estPriceText = _estPriceControllers[itemName]?.text ?? "0.00";
        final estPrice = double.tryParse(estPriceText) ?? 0.0; // Use tryParse and provide a default value
        estTotal += estPrice;
      } catch (e) {
        print("Error parsing estimated price for $itemName: $e");
        estTotal += 0.0; // Default to 0.0 on error
      }
    }

    // Compute Actual Total (only for checked items)
    for (var item in items) {
      final itemName = item['name']!;
      final isChecked = _checkedItems[itemName] ?? false;
      if (isChecked) {
        try {
          final actualPriceText = _actualPriceControllers[itemName]?.text ?? "0.00";
          final actualPrice = double.tryParse(actualPriceText) ?? 0.0; // Use tryParse and provide a default value
          actualTotal += actualPrice;
        } catch (e) {
          print("Error parsing actual price for $itemName: $e");
          actualTotal += 0.0; // Default to 0.0 on error
        }
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