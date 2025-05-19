
import 'package:flutter/material.dart';
import 'package:flutter_shopsmart/list_provider.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:provider/provider.dart';
import 'package:flutter_shopsmart/dashboard.dart';
import 'package:flutter_shopsmart/MyLists.dart';
import 'package:flutter_shopsmart/checklist.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

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
    final List<Widget> _pages = [
      MyLists(),
      Dashboard(),
      Checklist(selectedList: listProvider.latestList),
    ];

    return Scaffold(
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
        backgroundColor: Colors.grey.shade300,
      ),
      backgroundColor: Colors.grey[300],
      body: _pages[_selectedIndex],
    );
  }
}