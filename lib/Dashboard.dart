import 'package:flutter/material.dart';
import 'package:flutter_shopsmart/Checklist.dart';
import 'package:flutter_shopsmart/addlistpage.dart';
import 'package:table_calendar/table_calendar.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(15),
      child: ListView(
        children: [
          // Calendar Title
          Padding(
            padding: const EdgeInsets.all(8),
            child: Container(
              height: 30,
              width: 500,
              color: Colors.grey[300],
              child: Text("CALENDAR", style: TextStyle(fontSize: 28)),
            ),
          ),

          // Calendar Widget
          Padding(
            padding: const EdgeInsets.only(bottom: 25, left: 15, right: 15),
            child: Container(
              padding: const EdgeInsets.all(0),
              height: 300,
              width: 220,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.grey[200],
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade500,
                    offset: Offset(4.0, 4.0),
                    blurRadius: 15,
                    spreadRadius: 1.0,
                  ),
                ],
              ),
              child: TableCalendar(
                shouldFillViewport: true,
                focusedDay: DateTime.now(),
                firstDay: DateTime.utc(2010, 10, 16),
                lastDay: DateTime.utc(2030, 3, 14),
                calendarFormat: CalendarFormat.month,
                availableCalendarFormats: const {CalendarFormat.month: 'Month'},
                headerStyle: HeaderStyle(formatButtonVisible: false),
                calendarStyle: CalendarStyle(
                  weekendTextStyle: TextStyle(color: Colors.red),
                ),
                availableGestures: AvailableGestures.none,
              ),
            ),
          ),
          //Checkbox for calendar
          Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 8, right: 8),
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade500,
                    offset: Offset(4.0, 4.0),
                    blurRadius: 10,
                    spreadRadius: 1.0,
                  ),
                ],
              ),
              child: _CalendarOptions(),
            ),
          ),
          // My List title
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Container(
                  height: 30,
                  width: 290,
                  color: Colors.grey[300],
                  child: Text(
                    "MY LIST",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  color: Colors.grey[300],
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MyLists()),
                      );
                    },
                    child: Text("view all"),
                  ),
                ),
              ],
            ),
          ),

          // Example Items
          Container(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Container(
                    padding: EdgeInsets.all(15),
                    height: 50,
                    width: 350,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Checklist()),
                        );
                      },
                      child: Text("Example list 1"),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Container(
                    padding: EdgeInsets.all(15),
                    height: 50,
                    width: 350,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Checklist()),
                        );
                      },
                      child: Text("Example list 2"),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Container(
                    padding: EdgeInsets.all(15),
                    height: 50,
                    width: 350,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Checklist()),
                        );
                      },
                      child: Text("Example List 3"),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarOptions extends StatefulWidget {
  @override
  __CalendarOptionsState createState() => __CalendarOptionsState();
}

class __CalendarOptionsState extends State<_CalendarOptions> {
  bool weeklySelected = false;
  bool monthlySelected = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildOption("Weekly List", weeklySelected, () {
          setState(() {
            weeklySelected = !weeklySelected;
          });
        }),
        SizedBox(height: 10),
        _buildOption("Monthly List", monthlySelected, () {
          setState(() {
            monthlySelected = !monthlySelected;
          });
        }),
      ],
    );
  }

  Widget _buildOption(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          AnimatedContainer(
            duration: Duration(milliseconds: 200),
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected ? Colors.black : Colors.transparent,
              border: Border.all(
                color: selected ? Colors.white : Colors.grey,
                width: 2,
              ),
            ),
            child:
                selected
                    ? Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
          ),
          SizedBox(width: 10),
          Text(label, style: TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}
