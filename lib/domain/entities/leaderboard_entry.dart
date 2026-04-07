import 'package:equatable/equatable.dart';

class LeaderboardEntry extends Equatable {
  const LeaderboardEntry({
    required this.rank,
    required this.displayName,
    required this.xp,
    required this.isCurrentUser,
  });

  final int rank;
  final String displayName;
  final int xp;
  final bool isCurrentUser;

  @override
  List<Object?> get props => [rank, displayName, xp, isCurrentUser];
}
