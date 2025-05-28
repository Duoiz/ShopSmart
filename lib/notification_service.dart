import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:rxdart/rxdart.dart'; // Import rxdart
import 'package:flutter/material.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const channelId = 'shopping_list_reminders';
  static const channelName = 'Shopping List Notifications';

  // Add a BehaviorSubject to handle notification actions
  final BehaviorSubject<String?> selectNotificationSubject =
      BehaviorSubject<String?>();

  Future<void> initialize() async {
    try {
      // Initialize Timezone
      tzdata.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Asia/Manila'));

      // Create notification channel for Android
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/mijalogo');

      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        channelId,
        channelName,
        description: 'Channel for shopping list reminders',
        importance: Importance.max,
        enableVibration: true,
        playSound: true,
      );

      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      // Define action buttons for Android
      final List<AndroidNotificationAction> actions = <AndroidNotificationAction>[
        const AndroidNotificationAction(
          'snooze',
          'Snooze',
          titleColor: Colors.blue,
        ),
        const AndroidNotificationAction(
          'stop',
          'Stop',
          titleColor: Colors.grey,
        ),
      ];

      // Initialize plugin
      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      await flutterLocalNotificationsPlugin.initialize(initializationSettings,
          onDidReceiveNotificationResponse:
              (NotificationResponse notificationResponse) {
        // Handle notification tap event here
        selectNotificationSubject.add(notificationResponse.payload);
      });
    } catch (e) {
      print('NotificationService initialize error: $e');
    }
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
  }) async {
    // Check if the scheduled date is in the past
    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
      print("Scheduled date is in the past. Scheduling for the next minute.");
      scheduledDate = tz.TZDateTime.now(tz.local).add(const Duration(minutes: 1));
    }

    try {
      const AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
        'your_channel_id',
        'your_channel_name',
        channelDescription: 'your_channel_description',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker',
        actions: <AndroidNotificationAction>[
          AndroidNotificationAction('snooze', 'Snooze',
              titleColor: Colors.blue, inputs: []),
          AndroidNotificationAction('stop', 'Stop',
              titleColor: Colors.grey, inputs: []),
        ],
      );
      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidNotificationDetails);
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e) {
      print("Error scheduling notification: $e");
    }
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }
}