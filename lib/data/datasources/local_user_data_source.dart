import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../models/user_model.dart';

class LocalUserDataSource {
  LocalUserDataSource(this._db);

  final Database _db;

  static const String _table = 'users';

  Future<void> ensureTable() async {
    await _db.execute('''
      CREATE TABLE IF NOT EXISTS $_table (
        id TEXT PRIMARY KEY,
        data TEXT NOT NULL
      );
    ''');
  }

  Future<UserModel?> getUser(String uid) async {
    final maps = await _db.query(_table, where: 'id = ?', whereArgs: [uid]);
    if (maps.isEmpty) return null;
    final row = maps.first;
    final data = jsonDecode(row['data'] as String) as Map<String, dynamic>;
    return UserModel.fromJson(data..['id'] = row['id']);
  }

  Future<void> saveUser(UserModel user) async {
    final json = jsonEncode(user.toJson());
    await _db.insert(
      _table,
      {'id': user.id, 'data': json},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
