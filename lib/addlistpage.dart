import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_shopsmart/list_provider.dart';
import 'additempage.dart';
import 'package:table_calendar/table_calendar.dart';
import 'notification_service.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';

class AddList extends StatefulWidget {
  const AddList({super.key});

  @override
  State<AddList> createState() => _AddListState();
}

class _AddListState extends State<AddList> {
  String? selectedRepeat;
  DateTime selectedDay = DateTime.now();
  TimeOfDay? selectedTime;
  List<DateTime> highlightedDates = [];
  String listName = '';
  List<Map<String, String>> currentItems = [];

  List<DropdownMenuItem<String>> repeat = const [
    DropdownMenuItem(value: "Weekly", child: Text("Weekly")),
    DropdownMenuItem(value: "Monthly", child: Text("Monthly")),
  ];

  late NotificationService notificationService;

  @override
  void initState() {
    super.initState();
    notificationService = Provider.of<NotificationService>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    final listProvider = Provider.of<ListProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Add List"),
        backgroundColor: Colors.grey.shade300,
        actions: [
          TextButton(
            onPressed: () {
              // Validate list name
              if (listName.trim().isEmpty) {
                Fluttertoast.showToast(
                  msg: "Please enter a list name.",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                );
                return; // Stop further execution
              }
              // Validate repeat option
              else if ((selectedRepeat ?? '').isEmpty) {
                Fluttertoast.showToast(
                  msg: "Please select a repeat option.",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                );
                return; // Stop further execution
              }
              // Validate at least one item
              else if (currentItems.isEmpty) {
                Fluttertoast.showToast(
                  msg: "Please add at least one item.",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                );
                return; // Stop further execution
              }

              // Info for time (not required)
              else if (selectedTime == null) {
                Fluttertoast.showToast(
                  msg: "Time not selected. Default set to 9:00 AM.",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                );
              }

              // All validations passed, add to list
              listProvider.addList(
                listName,
                selectedRepeat ?? '',
                highlightedDates,
                currentItems,
              );

              Navigator.pop(context);
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
          // Calendar UI - same as before
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
                    if (highlightedDates.any((d) =>
                        d.year == date.year &&
                        d.month == date.month &&
                        d.day == date.day)) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${date.day}',
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
          // Time Picker UI - same as before
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
                    "Time: ",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: selectedTime ?? TimeOfDay.now(),
                        );
                        if (picked != null) {
                          setState(() {
                            selectedTime = picked;
                            _highlightDates();
                          });
                        }
                      },
                      child: Text(
                        selectedTime != null
                            ? selectedTime!.format(context)
                            : "Select Time",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // List name input UI - same as before
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
          // Repeat dropdown UI - same as before
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
          // Add Item Button UI - same as before
          Padding(
            padding: const EdgeInsets.all(8),
            child: InkWell(
              borderRadius: BorderRadius.circular(40),
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddItemPage()),
                );
                if (result != null && result is List<Map<String, String>>) {
                  setState(() {
                    currentItems = result;
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.all(15),
                height: 70,
                width: 350,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  color: Colors.white,
                ),
                alignment: Alignment.center,
                child: Text(
                  "Add Item",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
      if (selectedRepeat == "Weekly") {
        for (int i = 0; i < 12; i++) {
          final date = selectedDay.add(Duration(days: i * 7));
          final combined = _combineDateAndTime(date);
          highlightedDates.add(combined);
          _schedule(combined, listName, i);
        }
      } else if (selectedRepeat == "Monthly") {
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
              targetDate.month,
              lastDayOfMonth,
            );
          }
          final combined = _combineDateAndTime(targetDate);
          highlightedDates.add(combined);
          _schedule(combined, listName, 100 + i);
        }
      } else {
        final combined = _combineDateAndTime(selectedDay);
        highlightedDates.add(combined);
        _schedule(combined, listName, 9999);
      }
    });
  }

  void _schedule(DateTime date, String listName, int id) {
    final scheduledDate = tz.TZDateTime.from(date, tz.local);
    notificationService.scheduleNotification(
      scheduledDate: scheduledDate,
      title: "Shopping List Reminder",
      body: "Today is your '$listName' day!",
      id: id,
    );
  }

  DateTime _combineDateAndTime(DateTime date) {
    if (selectedTime != null) {
      return DateTime(
        date.year,
        date.month,
        date.day,
        selectedTime!.hour,
        selectedTime!.minute,
      );
    } else {
      return DateTime(date.year, date.month, date.day, 9, 0); // default
    }
  }

  Future<void> requestNotificationPermission() async {
    final status = await Permission.notification.status;
    if (status.isDenied) {
      if (await Permission.notification.request().isGranted) {
        // Permission granted, proceed with scheduling
        print('Notification permission granted');
      } else {
        // Permission denied, handle accordingly
        print('Notification permission denied');
      }
    } else if (status.isGranted) {
      // Permission already granted, proceed with scheduling
      print('Notification permission already granted');
    }
  }
}