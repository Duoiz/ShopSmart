import 'package:flutter/material.dart';
import 'package:flutter_shopsmart/mainpage.dart';
import 'package:flutter_shopsmart/list_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_shopsmart/notification_service.dart';

// hours wasted: 220hrs

// good luck you need it 
//                  -Lee
Future<void> main() async {
 WidgetsFlutterBinding.ensureInitialized();

  // Initialize Notification Service
  final notificationService = NotificationService();
  await notificationService.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ListProvider()),
        // If you want to access notificationService globally:
        Provider<NotificationService>(create: (_) => notificationService),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: HomePage());
  }
}
