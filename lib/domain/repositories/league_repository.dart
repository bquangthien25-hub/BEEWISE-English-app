import '../entities/leaderboard_entry.dart';
import '../entities/league_tier.dart';

abstract class LeagueRepository {
  Future<List<LeaderboardEntry>> getTop20ForTier(LeagueTier tier);

  LeagueTier tierForXp(int xp);
}
