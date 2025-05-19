import 'package:flutter/material.dart';

class ListProvider with ChangeNotifier {
  List<Map<String, dynamic>> _lists = [];
  Map<String, dynamic>? _latestList;

  // Get all lists
  List<Map<String, dynamic>> get lists => _lists;

  // Get latest list
  Map<String, dynamic>? get latestList => _latestList;

  // Add new list
  void addList(String name, String repeat, List<DateTime> dates, List<Map<String, String>> items) {
    final newList = {
      'name': name,
      'repeat': repeat,
      'dates': dates,
      'items': items,
    };

    _lists.add(newList);
    _latestList = newList; // Update latest list
    notifyListeners();
  }

  // Optional: Update an existing list
  void updateList(int index, Map<String, dynamic> updatedList) {
    _lists[index] = updatedList;
    if (index == _lists.length - 1) {
      _latestList = updatedList;
    }
    notifyListeners();
  }

  // Optional: Remove a list
  void removeList(int index) {
    _lists.removeAt(index);
    if (_lists.isNotEmpty) {
      _latestList = _lists.last; // Set latest to last remaining list
    } else {
      _latestList = null;
    }
    notifyListeners();
  }

  // Optional: Manually set latest list
  void setLatestList(Map<String, dynamic> list) {
    _latestList = list;
    notifyListeners();
  }
}