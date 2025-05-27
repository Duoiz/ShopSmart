import 'package:flutter/material.dart';
import 'package:flutter_shopsmart/list_provider.dart';
import 'package:provider/provider.dart';
import 'notification_service.dart';
import 'notification_debugger.dart'; 
import 'package:flutter_shopsmart/mainpage.dart'; 

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Notification Service
  final notificationService = NotificationService();
  await notificationService.initialize();

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
      home: HomePage(),
      routes: {
        '/notification_debugger': (context) => const NotificationDebugger(), // Add the route
      },
    );
  }
}
