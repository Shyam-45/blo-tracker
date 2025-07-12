import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:blo_tracker/models/user_model.dart';

class UserDatabaseService {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'user_profile.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE user (
            userId TEXT PRIMARY KEY,
            name TEXT,
            designation TEXT,
            officerType TEXT,
            mobile TEXT,
            boothNumber TEXT,
            boothName TEXT
          )
        ''');
      },
    );
  }

  static Future<void> insertUser(UserModel user) async {
    final db = await database;
    await db.insert(
      'user',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<UserModel?> getUser() async {
    final db = await database;
    final maps = await db.query('user');
    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }
    return null;
  }

  static Future<void> deleteUser() async {
    final db = await database;
    await db.delete('user');
  }
}

// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
// import 'package:blo_tracker/models/user_model.dart';

// class UserDatabaseService {
//   static Database? _db;

//   static Future<Database> get database async {
//     if (_db != null) return _db!;
//     _db = await _initDB();
//     return _db!;
//   }

//   static Future<Database> _initDB() async {
//     final path = join(await getDatabasesPath(), 'user_profile.db');
//     return openDatabase(
//       path,
//       version: 1,
//       onCreate: (db, version) {
//         return db.execute('''
//           CREATE TABLE user (
//             userId TEXT PRIMARY KEY,
//             name TEXT,
//             designation TEXT,
//             officerType TEXT,
//             mobile TEXT,
//             boothNumber TEXT,
//             boothName TEXT
//           )
//         ''');
//       },
//     );
//   }

//   static Future<void> insertUser(UserModel user) async {
//     final db = await database;
//     await db.insert(
//       'user',
//       user.toMap(),
//       conflictAlgorithm: ConflictAlgorithm.replace,
//     );
//   }

//   static Future<UserModel?> getUser() async {
//     final db = await database;
//     final maps = await db.query('user');

//     if (maps.isNotEmpty) {
//       return UserModel.fromMap(maps.first);
//     }
//     return null;
//   }

//   static Future<void> deleteUser() async {
//     final db = await database;
//     await db.delete('user');
//   }
// }

// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
// import 'package:blo_tracker/models/user_model.dart';

// class UserDatabaseService {
//   static Database? _db;

//   static Future<Database> get database async {
//     if (_db != null) return _db!;
//     _db = await _initDB();
//     return _db!;
//   }

//   static Future<Database> _initDB() async {
//     final path = join(await getDatabasesPath(), 'user_profile.db');
//     return openDatabase(
//       path,
//       version: 1,
//       onCreate: (db, version) {
//         return db.execute('''
//           CREATE TABLE user(
//             email TEXT PRIMARY KEY,
//             name TEXT,
//             phone TEXT
//           )
//         ''');
//       },
//     );
//   }

//   static Future<void> insertUser(UserModel user) async {
//     final db = await database;
//     await db.insert(
//       'user',
//       user.toMap(),
//       conflictAlgorithm: ConflictAlgorithm.replace,
//     );
//   }

//   static Future<UserModel?> getUser() async {
//     final db = await database;
//     final maps = await db.query('user');

//     if (maps.isNotEmpty) {
//       return UserModel.fromMap(maps.first);
//     }
//     return null;
//   }

//   static Future<void> deleteUser() async {
//     final db = await database;
//     await db.delete('user');
//   }
// }
