import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../models/lesson_model.dart';

class LocalLessonDataSource {
  LocalLessonDataSource(this._db);

  final Database _db;
  static const String _table = 'lessons';

  Future<void> ensureTable() async {
    await _db.execute('''
      CREATE TABLE IF NOT EXISTS $_table (
        id TEXT PRIMARY KEY,
        data TEXT NOT NULL
      );
    ''');
  }

  Future<void> cacheLessons(List<LessonModel> lessons) async {
    final batch = _db.batch();
    for (final lesson in lessons) {
      final jsonStr = jsonEncode(lesson.toJson());
      batch.insert(
        _table,
        {'id': lesson.id, 'data': jsonStr},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<LessonModel>> getCachedLessons() async {
    final maps = await _db.query(_table);
    if (maps.isEmpty) return [];

    return maps.map((row) {
      final data = jsonDecode(row['data'] as String) as Map<String, dynamic>;
      return LessonModel.fromJson(data..['id'] = row['id']);
    }).toList();
  }
}
