import 'package:equatable/equatable.dart';

class DailyMission extends Equatable {
  const DailyMission({
    required this.id,
    required this.title,
    required this.progress,
    required this.target,
    required this.rewardDiamonds,
    required this.rewardXp,
    required this.completed,
    required this.claimed,
  });

  final String id;
  final String title;
  final int progress;
  final int target;
  final int rewardDiamonds;
  final int rewardXp;
  final bool completed;
  final bool claimed;

  DailyMission copyWith({
    String? id,
    String? title,
    int? progress,
    int? target,
    int? rewardDiamonds,
    int? rewardXp,
    bool? completed,
    bool? claimed,
  }) {
    return DailyMission(
      id: id ?? this.id,
      title: title ?? this.title,
      progress: progress ?? this.progress,
      target: target ?? this.target,
      rewardDiamonds: rewardDiamonds ?? this.rewardDiamonds,
      rewardXp: rewardXp ?? this.rewardXp,
      completed: completed ?? this.completed,
      claimed: claimed ?? this.claimed,
    );
  }

  @override
  List<Object?> get props =>
      [id, title, progress, target, rewardDiamonds, rewardXp, completed, claimed];
}
