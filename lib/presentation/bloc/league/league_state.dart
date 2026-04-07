import 'package:equatable/equatable.dart';

import '../../../domain/entities/leaderboard_entry.dart';
import '../../../domain/entities/league_tier.dart';

abstract class LeagueState extends Equatable {
  const LeagueState();

  @override
  List<Object?> get props => [];
}

class LeagueInitial extends LeagueState {
  const LeagueInitial();
}

class LeagueLoading extends LeagueState {
  const LeagueLoading();
}

class LeagueReady extends LeagueState {
  const LeagueReady({
    required this.tier,
    required this.entries,
    required this.userXp,
  });

  final LeagueTier tier;
  final List<LeaderboardEntry> entries;
  final int userXp;

  @override
  List<Object?> get props => [tier, entries, userXp];
}

class LeagueError extends LeagueState {
  const LeagueError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
