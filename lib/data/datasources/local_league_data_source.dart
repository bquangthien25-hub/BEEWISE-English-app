import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../../domain/entities/leaderboard_entry.dart';

class LocalLeagueDataSource {
  LocalLeagueDataSource(this._db);

  final Database _db;
  static const String _table = 'league';

  Future<void> ensureTable() async {
    await _db.execute('''
      CREATE TABLE IF NOT EXISTS $_table (
        id TEXT PRIMARY KEY,
        data TEXT NOT NULL
      );
    ''');
  }

  Future<void> cacheLeague(List<LeaderboardEntry> entries) async {
    final batch = _db.batch();
    // Xóa cache cũ trước khi lưu mới
    batch.delete(_table);
    for (final entry in entries) {
      final map = {
        'rank': entry.rank,
        'displayName': entry.displayName,
        'xp': entry.xp,
        'isCurrentUser': entry.isCurrentUser,
      };
      batch.insert(
        _table,
        {'id': entry.rank.toString() + entry.displayName, 'data': jsonEncode(map)},
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<LeaderboardEntry>> getCachedLeague() async {
    final maps = await _db.query(_table);
    if (maps.isEmpty) return [];

    final result = <LeaderboardEntry>[];
    for (final row in maps) {
      final data = jsonDecode(row['data'] as String) as Map<String, dynamic>;
      result.add(
        LeaderboardEntry(
          rank: data['rank'] as int,
          displayName: data['displayName'] as String,
          xp: data['xp'] as int,
          isCurrentUser: data['isCurrentUser'] as bool,
        ),
      );
    }
    result.sort((a, b) => a.rank.compareTo(b.rank));
    return result;
  }
}
