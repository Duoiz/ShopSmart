import 'package:flutter/material.dart';
import 'package:flutter_shopsmart/additempage.dart';
import 'package:table_calendar/table_calendar.dart';

class AddList extends StatefulWidget {
  final Function(String, String, List<DateTime>) onAddList;

  const AddList({super.key, required this.onAddList});

  @override
  State<AddList> createState() => _AddListState();
}

class _AddListState extends State<AddList> {
  String? selectedRepeat;
  DateTime selectedDay = DateTime.now();
  List<DateTime> highlightedDates = [];
  String listName = '';

  List<DropdownMenuItem<String>> repeat = const [
    DropdownMenuItem(value: "Weekly", child: Text("Weekly")),
    DropdownMenuItem(value: "Monthly", child: Text("Monthly")),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add List"),
        backgroundColor: Colors.grey.shade300,
        actions: [
          TextButton(
            onPressed: () {
              widget.onAddList(
                listName,
                selectedRepeat ?? '',
                highlightedDates,
              );
              Navigator.pop(context); // Go back to MyLists after adding
            },
            child: Text(
              "Add to List",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.grey.shade300,
      body: ListView(
        children: [
          // Calendaryo
          Padding(
            padding: const EdgeInsets.all(10),
            child: Container(
              height: 390,
              width: 220,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: TableCalendar(
                shouldFillViewport: true,
                focusedDay: selectedDay,
                firstDay: DateTime.utc(2010, 10, 16),
                lastDay: DateTime.utc(2030, 3, 14),
                calendarFormat: CalendarFormat.month,
                availableCalendarFormats: const {CalendarFormat.month: 'Month'},
                headerStyle: HeaderStyle(formatButtonVisible: true),
                selectedDayPredicate: (day) => isSameDay(day, selectedDay),
                onDaySelected: (selected, focused) {
                  setState(() {
                    selectedDay = selected;
                    _highlightDates();
                  });
                },
                availableGestures: AvailableGestures.none,
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, events) {
                    if (highlightedDates.contains(date)) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.blue, // Circle color
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${date.day}', //wan ko ano to basta nilagay ko nalang
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    }
                    return null;
                  },
                ),
              ),
            ),
          ),

          // List name input thingy
          Padding(
            padding: const EdgeInsets.all(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              height: 70,
              width: 350,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                color: Colors.white,
              ),
              child: Row(
                children: [
                  Text(
                    "List name: ",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          listName = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: "Enter name",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Repeat
          Padding(
            padding: const EdgeInsets.all(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              height: 70,
              width: 350,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                color: Colors.white,
              ),
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  labelText: "Repeat:",
                  labelStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                value: selectedRepeat,
                items: repeat,
                onChanged: (value) {
                  setState(() {
                    selectedRepeat = value;
                    _highlightDates();
                  });
                },
              ),
            ),
          ),

          // Add item button thingy
          Padding(
            padding: const EdgeInsets.all(8),
            child: Container(
              padding: const EdgeInsets.all(15),
              height: 70,
              width: 350,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                color: Colors.white,
              ),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Additempage()),
                  );
                },
                child: Center(
                  child: Text(
                    "Add Item",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _highlightDates() {
    setState(() {
      highlightedDates.clear();
      //hinahighlight ung days sa weekly
      if (selectedRepeat == "Weekly") {
        for (int i = 0; i < 12; i++) {
          highlightedDates.add(selectedDay.add(Duration(days: i * 7)));
        }
      } else if (selectedRepeat == "Monthly") {
        // dapat for every month makikita ung date kaso wan ko ayaw gumana lamao
        for (int i = 0; i < 12; i++) {
          DateTime targetDate = DateTime(
            selectedDay.year,
            selectedDay.month + i,
            selectedDay.day,
          );

          int lastDayOfMonth =
              DateTime(targetDate.year, targetDate.month + 1, 0).day;

          if (targetDate.day > lastDayOfMonth) {
            targetDate = DateTime(
              targetDate.year,
              targetDate.month + i,
              lastDayOfMonth,
            );
          }

          highlightedDates.add(targetDate);
        }
      }
    });
  }
}
