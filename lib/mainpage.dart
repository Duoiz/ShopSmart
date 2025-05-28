import 'package:flutter/material.dart';
import 'package:flutter_shopsmart/list_provider.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:provider/provider.dart';
import 'package:flutter_shopsmart/dashboard.dart';
import 'package:flutter_shopsmart/MyLists.dart';
import 'package:flutter_shopsmart/checklist.dart';
// Import the debugger

class HomePage extends StatefulWidget {
  const HomePage({super.key}); // Add Key? key

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    // Access ListProvider inside build method
    final listProvider = Provider.of<ListProvider>(context);

    // Define pages here, inside build()
    final List<Widget> pages = [
      MyLists(),
      Dashboard(),
      Checklist(selectedList: listProvider.latestList),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F4EB),
      appBar: AppBar(
      backgroundColor: const Color.fromARGB(255, 63, 73, 77),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          Icon(Icons.list_outlined),
          Icon(Icons.dashboard),
          Icon(Icons.checklist),
        ],
      backgroundColor: const Color(0xFFF8F4EB),
      ),
      body: Column(
        children: [
          Expanded(child: pages[_selectedIndex]),
          // Remove the Notification Debugger button
          // ElevatedButton(
          //   onPressed: () {
          //     Navigator.pushNamed(context, '/notification_debugger');
          //   },
          //   child: const Text('Open Notification Debugger'),
          // ),
        ],
      ),
    );
  }

}