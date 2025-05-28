import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'notification_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationDebugger extends StatefulWidget {
  const NotificationDebugger({super.key});

  @override
  State<NotificationDebugger> createState() => _NotificationDebuggerState();
}

class _NotificationDebuggerState extends State<NotificationDebugger> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _idController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final notificationService = Provider.of<NotificationService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Debugger'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: _bodyController,
                decoration: const InputDecoration(labelText: 'Body'),
              ),
              TextField(
                controller: _idController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'ID'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text('Date: ${_selectedDate.toLocal()}'),
                  TextButton(
                    onPressed: () => _selectDate(context),
                    child: const Text('Select Date'),
                  ),
                ],
              ),
              Row(
                children: [
                  Text('Time: ${_selectedTime.format(context)}'),
                  TextButton(
                    onPressed: () => _selectTime(context),
                    child: const Text('Select Time'),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  final title = _titleController.text;
                  final body = _bodyController.text;
                  final id = int.tryParse(_idController.text) ?? 0;
                  final scheduledDate = tz.TZDateTime(
                    tz.local,
                    _selectedDate.year,
                    _selectedDate.month,
                    _selectedDate.day,
                    _selectedTime.hour,
                    _selectedTime.minute,
                  );

                  try {
                    notificationService.flutterLocalNotificationsPlugin.zonedSchedule(
                      id,
                      title,
                      body,
                      scheduledDate,
                      const NotificationDetails(
                        android: AndroidNotificationDetails(
                          'your_channel_id',
                          'your_channel_name',
                          channelDescription: 'your_channel_description',
                        ),
                      ),
                      androidScheduleMode: AndroidScheduleMode.exact,
                    );
                  } catch (e) {
                    print('Error scheduling notification: $e');
                  }
                },
                child: const Text('Schedule Notification'),
              ),
              ElevatedButton(
                onPressed: () {
                  final id = int.tryParse(_idController.text) ?? 0;
                  notificationService.cancelNotification(id);
                },
                child: const Text('Cancel Notification'),
              ),
              const SizedBox(height: 32),
              const Text(
                'Scheduled Notifications:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              FutureBuilder<List<PendingNotificationRequest>>(
                future: notificationService.flutterLocalNotificationsPlugin
                    .pendingNotificationRequests(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final notifications = snapshot.data!;
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final notification = notifications[index];
                        return ListTile(
                          title: Text(notification.title ?? 'No Title'),
                          subtitle: Text(notification.body ?? 'No Body'),
                          trailing: Text('ID: ${notification.id}'),
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}