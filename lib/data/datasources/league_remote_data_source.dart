import 'dart:math';

import '../../domain/entities/leaderboard_entry.dart';
import '../../domain/entities/league_tier.dart';

abstract class LeagueRemoteDataSource {
  Future<List<LeaderboardEntry>> fetchTop20(LeagueTier tier, int currentUserXp);
}

class LeagueRemoteDataSourceImpl implements LeagueRemoteDataSource {
  final _rnd = Random(42);

  static const _names = [
    'An', 'Bình', 'Chi', 'Dũng', 'Hà', 'Hùng', 'Lan', 'Linh', 'Minh', 'Nam',
    'Ngọc', 'Phúc', 'Quang', 'Tâm', 'Thảo', 'Trang', 'Tuấn', 'Uyên', 'Vân', 'Yến',
  ];

  @override
  Future<List<LeaderboardEntry>> fetchTop20(LeagueTier tier, int currentUserXp) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));

    final base = tier.minXp;
    final raw = <LeaderboardEntry>[];

    for (var i = 0; i < 20; i++) {
      final isMe = i == 7;
      final xp = isMe
          ? currentUserXp
          : base + _rnd.nextInt(450) + (20 - i) * 38;
      raw.add(
        LeaderboardEntry(
          rank: 0,
          displayName: isMe ? 'Bạn' : _names[i % _names.length],
          xp: xp,
          isCurrentUser: isMe,
        ),
      );
    }

    raw.sort((a, b) => b.xp.compareTo(a.xp));

    return List<LeaderboardEntry>.generate(20, (i) {
      final e = raw[i];
      return LeaderboardEntry(
        rank: i + 1,
        displayName: e.displayName,
        xp: e.xp,
        isCurrentUser: e.isCurrentUser,
      );
    });
  }
}
