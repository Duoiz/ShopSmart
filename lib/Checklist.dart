//Di pa working ung computation dito sa backend pa yon

import 'package:flutter/material.dart';

class Checklist extends StatefulWidget {
  const Checklist({super.key});

  @override
  State<Checklist> createState() => _ChecklistState();
}

class _ChecklistState extends State<Checklist> {
  // Independent checkbox states
  final Map<String, bool> _checkedItems = {"Apple": false, "Banana": false};

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
          Expanded(
            child: ListView(
              children: [
                _buildHeaderRow(),
                _buildChecklistRow("Apple", "2"),
                _buildChecklistRow(
                  "Banana",
                  "1.5",
                ), //eto ung mga item list na magbabago rin sa future pag mag babackend na
              ],
            ),
          ),
          _buildBottomSummaryBar(),
          Container(height: 4),
          //tinawag ung bottomsummarybar
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
              "Fruits",
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
    bool isChecked = _checkedItems[itemName] ?? false;

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
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 8,
                ),
              ),
              style: TextStyle(fontSize: 12),
            ),
          ),
          Container(
            height: 35,
            width: 65,
            padding: EdgeInsets.symmetric(horizontal: 2),
            child: TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 8,
                ),
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
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade400)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Trippings sa checked ewan pero ung nga magbabago rin to ata
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Checked ${_checkedItems.values.where((v) => v).length}/${_checkedItems.length} items",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "Est: ₱0.00  |  Actual: ₱0.00",
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
                    "Save more",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green,
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
