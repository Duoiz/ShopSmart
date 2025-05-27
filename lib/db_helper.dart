import 'package:sqflite/sqflite.dart' show Database, getDatabasesPath, openDatabase;
import 'package:path/path.dart';

// andito yung CRUD :D

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'lists.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE lists(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            repeat TEXT,
            dates TEXT,
            items TEXT
          )
        ''');
      },
    );
  }

  // CREATE:
  Future<int> insertList(Map<String, dynamic> list) async {
    final dbClient = await db;
    // Convert dates and items to JSON string for storage
    final data = {
      'name': list['name'],
      'repeat': list['repeat'],
      'dates': list['dates']?.toString(),
      'items': list['items']?.toString(),
    };
    return await dbClient.insert('lists', data);
  }

  // READ:
  Future<List<Map<String, dynamic>>> getLists() async {
    final dbClient = await db;
    return await dbClient.query('lists');
  }

  // UPDATE:
  Future<int> updateList(int id, Map<String, dynamic> newList) async {
    final dbClient = await db;
    final data = {
      'name': newList['name'],
      'repeat': newList['repeat'],
      'dates': newList['dates']?.toString(),
      'items': newList['items']?.toString(),
    };
    return await dbClient.update(
      'lists',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // DELETE:
  Future<int> deleteList(int id) async {
    final dbClient = await db;
    return await dbClient.delete('lists', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final dbClient = await db;
    dbClient.close();
  }
}