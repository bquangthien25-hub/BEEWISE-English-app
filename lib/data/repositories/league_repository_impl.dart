import '../../core/error/exceptions.dart';
import '../../core/error/failure.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/leaderboard_entry.dart';
import '../../domain/entities/league_tier.dart';
import '../../domain/repositories/league_repository.dart';
import '../datasources/league_remote_data_source.dart';
import '../datasources/local_league_data_source.dart';
import '../user_profile_store.dart';

class LeagueRepositoryImpl implements LeagueRepository {
  LeagueRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
    required this.profileStore,
  });

  final LeagueRemoteDataSource remoteDataSource;
  final LocalLeagueDataSource localDataSource;
  final NetworkInfo networkInfo;
  final UserProfileStore profileStore;

  @override
  LeagueTier tierForXp(int xp) => leagueTierFromXp(xp);

  @override
  Future<List<LeaderboardEntry>> getTop20ForTier(LeagueTier tier) async {
    if (!await networkInfo.isConnected) {
      final cached = await localDataSource.getCachedLeague();
      if (cached.isNotEmpty) return cached;
      throw const NetworkFailure();
    }
    try {
      final xp = profileStore.current?.xp ?? 0;
      final remote = await remoteDataSource.fetchTop20(tier, xp);
      await localDataSource.cacheLeague(remote);
      return remote;
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }
}
