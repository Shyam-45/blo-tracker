import 'package:blo_tracker/models/live_entry_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class LocalDb {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'live_entries.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE entries (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            timeSlot TEXT,
            isSubmitted INTEGER,
            isMissed INTEGER,
            imagePath TEXT,
            latitude REAL,
            longitude REAL
          )
        ''');
      },
    );
  }

  static Future<void> insertEntry(LiveEntry entry) async {
    final db = await database;
    await db.insert(
      'entries',
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<LiveEntry>> getEntriesForToday() async {
    final db = await database;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final start = today.toIso8601String();
    final end = today.add(const Duration(days: 1)).toIso8601String();

    final result = await db.query(
      'entries',
      where: 'timeSlot >= ? AND timeSlot < ?',
      whereArgs: [start, end],
    );

    return result.map((e) => LiveEntry.fromMap(e)).toList();
  }

  static Future<void> clearAll() async {
    final db = await database;
    await db.delete('entries');
  }
}
