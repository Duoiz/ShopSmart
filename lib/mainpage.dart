import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shopsmart/Checklist.dart';
import 'package:flutter_shopsmart/Dashboard.dart';
import 'package:flutter_shopsmart/addlistpage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Widget> _pages = [MyLists(), Dashboard(), Checklist()];

  int _selectedIndex = 1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
        index: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          Icon(Icons.list_outlined),
          Icon(Icons.dashboard),
          Icon(Icons.checklist),
        ],
        backgroundColor: Colors.grey.shade300,
      ),

      backgroundColor: Colors.grey[300],
      body: _pages[_selectedIndex],
    );
  }
}
