import 'package:blo_tracker/models/live_entry_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class LocalDatabase {
  static final LocalDatabase instance = LocalDatabase._internal();
  factory LocalDatabase() => instance;

  static Database? _db;
  LocalDatabase._internal();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'blo_tracker.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE live_entries (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            timeSlot TEXT NOT NULL,
            isSubmitted INTEGER NOT NULL,
            isMissed INTEGER NOT NULL,
            imagePath TEXT,
            latitude REAL,
            longitude REAL
          )
        ''');
      },
    );
  }

  /// ⏺ Used in upload screen
  Future<void> insertEntry(LiveEntry entry) async {
    final db = await database;

    // Remove existing entry for same time slot
    await db.delete(
      'live_entries',
      where: 'timeSlot = ?',
      whereArgs: [entry.timeSlot.toIso8601String()],
    );

    await db.insert('live_entries', entry.toMap());
    print("✅ Entry inserted: ${entry.toMap()}");
  }

  /// ⏺ Used if upload fails
  Future<void> deleteEntry(DateTime timeSlot) async {
    final db = await database;
    await db.delete(
      'live_entries',
      where: 'timeSlot = ?',
      whereArgs: [timeSlot.toIso8601String()],
    );
    print("🗑️ Entry deleted for slot: $timeSlot");
  }

  Future<List<LiveEntry>> getEntriesForDate(DateTime date) async {
    final db = await database;

    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    final maps = await db.query(
      'live_entries',
      where: 'timeSlot >= ? AND timeSlot < ?',
      whereArgs: [
        start.toIso8601String(),
        end.toIso8601String(),
      ],
      orderBy: 'timeSlot ASC',
    );

    return maps.map((e) => LiveEntry.fromMap(e)).toList();
  }

  Future<void> clearAllEntries() async {
    final db = await database;
    await db.delete('live_entries');
    print("🧹 Local DB cleared");
  }
}

// import 'package:blo_tracker/models/live_entry_model.dart';
// import 'package:path/path.dart';
// import 'package:sqflite/sqflite.dart';

// class LocalDatabase {
//   static final LocalDatabase instance = LocalDatabase._internal();
//   factory LocalDatabase() => instance;

//   static Database? _db;
//   LocalDatabase._internal();

//   Future<Database> get database async {
//     if (_db != null) return _db!;
//     _db = await _initDB();
//     return _db!;
//   }

//   Future<Database> _initDB() async {
//     final dbPath = await getDatabasesPath();
//     final path = join(dbPath, 'blo_tracker.db');

//     return await openDatabase(
//       path,
//       version: 1,
//       onCreate: (db, version) async {
//         await db.execute('''
//           CREATE TABLE live_entries (
//             id INTEGER PRIMARY KEY AUTOINCREMENT,
//             timeSlot TEXT NOT NULL,
//             isSubmitted INTEGER NOT NULL,
//             isMissed INTEGER NOT NULL,
//             imagePath TEXT,
//             latitude REAL,
//             longitude REAL
//           )
//         ''');
//       },
//     );
//   }

//   Future<void> insertLiveEntry(LiveEntry entry) async {
//     final db = await database;

//     // If already exists, delete first
//     await db.delete(
//       'live_entries',
//       where: 'timeSlot = ?',
//       whereArgs: [entry.timeSlot.toIso8601String()],
//     );

//     await db.insert('live_entries', entry.toMap());
//     print("✅ Entry inserted: ${entry.toMap()}");
//   }

//   Future<List<LiveEntry>> getEntriesForDate(DateTime date) async {
//     final db = await database;

//     final start = DateTime(date.year, date.month, date.day);
//     final end = start.add(const Duration(days: 1));

//     final maps = await db.query(
//       'live_entries',
//       where: 'timeSlot >= ? AND timeSlot < ?',
//       whereArgs: [
//         start.toIso8601String(),
//         end.toIso8601String(),
//       ],
//       orderBy: 'timeSlot ASC',
//     );

//     return maps.map((e) => LiveEntry.fromMap(e)).toList();
//   }

//   Future<void> clearAllEntries() async {
//     final db = await database;
//     await db.delete('live_entries');
//     print("🧹 Local DB cleared");
//   }
// }
