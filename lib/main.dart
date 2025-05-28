import 'package:flutter/material.dart';
import 'package:flutter_shopsmart/list_provider.dart';
import 'package:provider/provider.dart';
import 'notification_service.dart';
import 'package:flutter_shopsmart/mainpage.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'splashscreen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Notification Service
  final notificationService = NotificationService();
  await notificationService.initialize();

  // Listen for notification actions
  notificationService.selectNotificationSubject.stream.listen((String? payload) {
    if (payload != null) {
      // Handle the notification action based on the payload
      if (payload == 'snooze') {
        // Reschedule the notification for 10 minutes later
        final now = DateTime.now();
        final newScheduledDate = now.add(Duration(minutes: 10));
        notificationService.scheduleNotification(
          id: 123, // Replace with the actual notification ID
          title: 'Snoozed Notification',
          body: 'Your snoozed notification!',
          scheduledDate: tz.TZDateTime.from(newScheduledDate, tz.local),
        );
      } else if (payload == 'stop') {
        // Cancel the notification
        notificationService.cancelNotification(123); // Replace with the actual notification ID
      }
    }
  });

  // Create the ListProvider list
  final listProvider = ListProvider();
  await listProvider.loadLists();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => listProvider),
        Provider<NotificationService>(create: (_) => notificationService),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => HomePage(), // Your main app page
      },
    );
  }
}
