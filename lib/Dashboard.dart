import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_shopsmart/list_provider.dart';
import 'package:flutter_shopsmart/Checklist.dart';
import 'package:flutter_shopsmart/MyLists.dart';
import 'package:table_calendar/table_calendar.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<DateTime> highlightedDates = [];
  DateTime selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
  }

  void updateHighlightedDates(List<DateTime> dates) {
    setState(() {
      highlightedDates = dates;
    });
  }

  // Helper to collect all highlightedDates from all lists
  List<DateTime> _getAllHighlightedDates(List<Map<String, dynamic>> lists) {
    return lists
        .expand((list) => (list['highlightedDates'] as List<dynamic>? ?? []))
        .map((d) => d is DateTime ? d : DateTime.tryParse(d.toString()))
        .whereType<DateTime>()
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final listProvider = Provider.of<ListProvider>(context);
    final recentLists = listProvider.lists.take(3).toList();
    final allHighlightedDates = _getAllHighlightedDates(listProvider.lists);


    return Scaffold(
      appBar: AppBar(
      title: Text(
        "DASHBOARD",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      backgroundColor: const Color(0xFFF8F4EB),
      elevation: 0,
      ),
      backgroundColor: const Color(0xFFF8F4EB), // Only this line for background
      body: Padding(
        padding: EdgeInsets.all(15),
        child: ListView(
          children: [
            // Calendar Title
            Padding(
              padding: const EdgeInsets.all(8),
              child: SizedBox(
                height: 30,
                width: 500,
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
                    });
                  },
                ),
              ),
            ),

            // Checkbox for calendar
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
                child: _CalendarOptions(
                  onHighlightDates: updateHighlightedDates,
                ),
              ),
            ),

            // My List title
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  SizedBox(
                    height: 30,
                    width: 290,
                    child: Text(
                      "MY LIST",
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    color: const Color(0xFFF8F4EB),
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

            // Recent Lists Section
            if (listProvider.lists.isEmpty)
              Center(
                child: Text(
                  "No lists yet. Add one from 'Add more list'.",
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      "Recent Lists",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 10),
                  ...recentLists.map((list) {
                    return Card(
                      color: Colors.white,  
                      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Text(list['name']),
                        subtitle: Text("Repeat: ${list['repeat']}"),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Checklist(selectedList: list),
                            ),
                          );
                        },
                      ),
                    );
                  }),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

// Calendar Options Checkbox Widget
class _CalendarOptions extends StatefulWidget {
  final void Function(List<DateTime>) onHighlightDates;
  const _CalendarOptions({required this.onHighlightDates});

  @override
  __CalendarOptionsState createState() => __CalendarOptionsState();
}

class __CalendarOptionsState extends State<_CalendarOptions> {
  bool weeklySelected = false;
  bool monthlySelected = false;
  List<Map<String, dynamic>> dueLists = [];

  void _filterLists(BuildContext context) {
    final listProvider = Provider.of<ListProvider>(context, listen: false);
    List<Map<String, dynamic>> filtered = [];

    if (weeklySelected && !monthlySelected) {
      filtered = listProvider.lists
          .where((list) => (list['repeat'] ?? '').toLowerCase() == 'weekly')
          .toList();
    } else if (!weeklySelected && monthlySelected) {
      filtered = listProvider.lists
          .where((list) => (list['repeat'] ?? '').toLowerCase() == 'monthly')
          .toList();
    } else if (weeklySelected && monthlySelected) {
      filtered = listProvider.lists
          .where((list) =>
              (list['repeat'] ?? '').toLowerCase() == 'weekly' ||
              (list['repeat'] ?? '').toLowerCase() == 'monthly')
          .toList();
    } 
    setState(() {
      dueLists = filtered;
    });

    // Gather all highlightedDates from filtered lists
    final List<DateTime> highlightDates = filtered
        .expand((list) => (list['highlightedDates'] as List<dynamic>? ?? []))
        .map((d) => d is DateTime ? d : DateTime.tryParse(d.toString()))
        .whereType<DateTime>()
        .toList();

    widget.onHighlightDates(highlightDates);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildOption("Weekly List", weeklySelected, () {
          setState(() {
            weeklySelected = !weeklySelected;
          });
          _filterLists(context);
        }),
        SizedBox(height: 10),
        _buildOption("Monthly List", monthlySelected, () {
          setState(() {
            monthlySelected = !monthlySelected;
          });
          _filterLists(context);
        }),
        SizedBox(height: 20),
        if (dueLists.isNotEmpty)
          ...dueLists.map((list) => Card(
                margin: EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  title: Text(list['name'] ?? ''),
                  subtitle: Text("Repeat: ${list['repeat'] ?? ''}"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Checklist(selectedList: list),
                      ),
                    );
                  },
                ),
              )),
        if (dueLists.isEmpty && (weeklySelected || monthlySelected))
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "No lists due for this category.",
              style: TextStyle(color: Colors.grey),
            ),
          ),
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
            child: selected
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