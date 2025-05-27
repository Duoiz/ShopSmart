import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'dart:convert';



class ListProvider with ChangeNotifier {
  final List<Map<String, dynamic>> _lists = [];
  Map<String, dynamic>? _latestList;

  // Get all lists
  List<Map<String, dynamic>> get lists => _lists;

  // Get latest list
  Map<String, dynamic>? get latestList => _latestList;

  // Load lists from DB on startup
  Future<void> loadLists() async {
    final dbLists = await DBHelper().getLists();
    _lists.clear();
    _lists.addAll(dbLists.map((list) {
      return {
        ...list,
        'dates': list['dates'] != null
            ? (jsonDecode(list['dates']) as List<dynamic>)
                .map((e) => DateTime.parse(e as String))
                .toList()
            : [],
        'items': list['items'] != null
            ? jsonDecode(list['items']) as List<dynamic>
            : [],
      };
    }));
    if (_lists.isNotEmpty) {
      _latestList = _lists.last;
    }
    notifyListeners();
  }

  // Add new list (CREATE)
  Future<void> addList(String name, String repeat, List<DateTime> dates, List<Map<String, String>> items) async {
    final newList = {
      'name': name,
      'repeat': repeat,
      'dates': jsonEncode(dates.map((d) => d.toIso8601String()).toList()),
      'items': jsonEncode(items),
    };
    final id = await DBHelper().insertList(newList);

    //a decoded version forda diretso naA
    final newListDecoded = Map<String, dynamic>.from(newList);
    newListDecoded['id'] = id;
    newListDecoded['dates'] = List<String>.from(jsonDecode(newList['dates'] as String)).map((e) => DateTime.parse(e)).toList();
    newListDecoded['items'] = jsonDecode(newList['items'] as String);

    _lists.add(newListDecoded);
    _latestList = newListDecoded;
    notifyListeners();
  }

  // Update an existing list (UPDATE)
  Future<void> updateList(Map<String, dynamic> oldList, Map<String, dynamic> newList) async {
    final index = _lists.indexWhere((list) => list['id'] == oldList['id']);
    if (index != -1) {
      final dbList = {
        'name': newList['name'],
        'repeat': newList['repeat'],
        'dates': jsonEncode((newList['dates'] as List<DateTime>).map((d) => d.toIso8601String()).toList()),
        'items': jsonEncode(newList['items']),
      };
      await DBHelper().updateList(oldList['id'], dbList);
      _lists[index] = {...newList, 'id': oldList['id']};
      notifyListeners();
    }
  }

  // Remove a list (DELETE)
  Future<void> removeList(int index) async {
    if (index >= 0 && index < _lists.length) {
      final id = _lists[index]['id'];
      await DBHelper().deleteList(id);
      _lists.removeAt(index);
      _latestList = _lists.isNotEmpty ? _lists.last : null;
      notifyListeners();
    }
  }
}