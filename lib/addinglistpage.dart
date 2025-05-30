import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_shopsmart/list_provider.dart';
import 'additempage.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:fluttertoast/fluttertoast.dart'; 

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
  List<DropdownMenuItem<String>> repeat = const [
    DropdownMenuItem(value: "Weekly", child: Text("Weekly")),
    DropdownMenuItem(value: "Monthly", child: Text("Monthly")),
  ];
  List<Map<String, String>> currentItems = [];

  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    initializeNotifications();
  }

  Future<void> initializeNotifications() async {
    final settings = const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/mijalogo'),
    );

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin.initialize(settings);

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Manila'));
  }

  Future<void> scheduleNotification(DateTime date, String listName, {int id = 0}) async {
    final channelId = 'shopping_list_reminders';
    final channelName = 'Shopping List Notifications';

    final details = AndroidNotificationDetails(
      channelId,
      channelName,
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      ongoing: true,
      playSound: true,
      enableVibration: true,
      autoCancel: true,
      icon: '@mipmap/mijalogo',
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/mijalogo'),
      styleInformation: BigTextStyleInformation(
        'Today is your "$listName" day!',
        htmlFormatBigText: true,
        contentTitle: 'Shopping List Reminder',
        htmlFormatContentTitle: true,
      ),
    );

    final notificationDetails = NotificationDetails(android: details);

    final scheduledDate = tz.TZDateTime.from(date, tz.local);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id, // Use a safe integer ID
      "Shopping List Reminder",
      "Today is your '$listName' day!",
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,

    );
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
              // Validate selected day

            if (selectedDay.year == DateTime.now().year &&
                selectedDay.month == DateTime.now().month &&
                selectedDay.day == DateTime.now().day) {
              Fluttertoast.showToast(
                msg: "The date was not selected. Default set to today.",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.black87,
                textColor: Colors.white,
              );
            }
              // Validate list name
              if (listName.trim().isEmpty) {
                Fluttertoast.showToast(
                  msg: "Please enter a list name.",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  backgroundColor: Colors.black87,
                  textColor: Colors.white,
                );
                return;
              }
              // Validate repeat option
              if ((selectedRepeat ?? '').isEmpty) {
                Fluttertoast.showToast(
                  msg: "Please select a repeat option.",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  backgroundColor: Colors.black87,
                  textColor: Colors.white,
                );
                return;
              }
              // Validate at least one item
              if (currentItems.isEmpty) {
                Fluttertoast.showToast(
                  msg: "Please add at least one item.",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  backgroundColor: Colors.black87,
                  textColor: Colors.white,
                );
                return;
              }
              // Info for time (not required)
              else if (selectedTime == null) {
                Fluttertoast.showToast(
                  msg: "Time was not selected. Default set to 9:00 AM.",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  backgroundColor: Colors.black87,
                  textColor: Colors.white,
                );
              }
              // All validations passed, add to list
              listProvider.addList(
                listName,
                selectedRepeat ?? '',
                highlightedDates,
                currentItems,
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
          // Calendar
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
          // Time picker
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
          // List name input
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
          // Add item button
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
          scheduleNotification(combined, listName, id: i);
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
          scheduleNotification(combined, listName, id: 100 + i);
        }
      } else {
        final combined = _combineDateAndTime(selectedDay);
        highlightedDates.add(combined);
        scheduleNotification(combined, listName, id: 9999);
      }
    });
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
      // Default to 9:00 AM if no time selected
      return DateTime(date.year, date.month, date.day, 9, 0);
    }
  }
}