import 'package:flutter/material.dart';

class Checklist extends StatefulWidget {
  final Map<String, dynamic>? selectedList;

  const Checklist({super.key, this.selectedList});

  @override
  State<Checklist> createState() => _ChecklistState();
}

class _ChecklistState extends State<Checklist> {
  late Map<String, dynamic>? list;
  late List<Map<String, String>> items;
  late Map<String, bool> _checkedItems;
  late Map<String, TextEditingController> _estPriceControllers;
  late Map<String, TextEditingController> _actualPriceControllers;

  @override
  void initState() {
    super.initState();

    // Get items from selected list or use empty list
    list = widget.selectedList;
    items = list?['items'] ?? [];

    // Initialize checkboxes
    _checkedItems = {
      for (var item in items) item['name']!: false
    };

    // Initialize price controllers
    _estPriceControllers = {
      for (var item in items)
        item['name']!: TextEditingController(text: "0.00")
    };

    _actualPriceControllers = {
      for (var item in items)
        item['name']!: TextEditingController(text: "0.00")
    };
  }

  @override
  void dispose() {
    for (var controller in _estPriceControllers.values) {
      controller.dispose();
    }
    for (var controller in _actualPriceControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        title: Text("Checklist", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.grey.shade300,
      ),
      body: Column(
        children: [
          _buildHeaderRow(),
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Text(
                      "No list selected. Tap a list from My Lists.",
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  )
                : ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final itemName = item['name']!;
                      final qty = item['qty'] ?? "1";

                      return _buildChecklistRow(itemName, qty);
                    },
                  ),
          ),
          _buildBottomSummaryBar(),
          Container(height: 4),
        ],
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
            color: Colors.grey[300],
            child: Text(
              "Item",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            padding: EdgeInsets.all(8),
            height: 35,
            width: 65,
            color: Colors.grey[300],
            child: Text("QTY/KG", style: TextStyle(fontSize: 12)),
          ),
          Container(
            alignment: Alignment.center,
            height: 35,
            width: 65,
            color: Colors.grey[300],
            child: Text("EST. PRICE", style: TextStyle(fontSize: 11)),
          ),
          Container(
            alignment: Alignment.center,
            height: 35,
            width: 65,
            color: Colors.grey[300],
            child: Text("ACTUAL", style: TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistRow(String itemName, String qty) {
    final isChecked = _checkedItems[itemName] ?? false;

    return Padding(
      padding: EdgeInsets.only(top: 8, left: 8, right: 8),
      child: Row(
        children: [
          Container(
            height: 50,
            width: 160,
            color: Colors.grey[300],
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
            color: Colors.grey[300],
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
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
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

  Widget _buildBottomSummaryBar() {
    int checkedCount = _checkedItems.values.where((v) => v).length;
    int totalCount = _checkedItems.length;

    double estTotal = 0.0;
    double actualTotal = 0.0;

    for (var item in items) {
      String name = item['name']!;
      try {
        estTotal += double.tryParse(_estPriceControllers[name]?.text ?? "0.00") ?? 0.0;
        actualTotal += double.tryParse(_actualPriceControllers[name]?.text ?? "0.00") ?? 0.0;
      } catch (e) {}
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