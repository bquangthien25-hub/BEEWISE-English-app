import 'package:equatable/equatable.dart';

import 'subscription_tier.dart';

class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    this.avatar,
    this.streak = 0,
    this.xp = 0,
    this.diamonds = 0,
    this.subscriptionTier = SubscriptionTier.basic,
    this.completedLessonIds = const [],
    this.dailyLessonCompletions = const {},
    this.lastStudyDate,
    this.isAdmin = false,
  });

  final String id;
  final String email;
  final String name;
  final String? avatar;
  final int streak;
  final int xp;
  final int diamonds;
  final SubscriptionTier subscriptionTier;
  final List<String> completedLessonIds;
  /// Khóa `yyyy-MM-dd` → danh sách [lessonId] đã hoàn thành trong ngày đó.
  final Map<String, List<String>> dailyLessonCompletions;
  final DateTime? lastStudyDate;
  final bool isAdmin;

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        avatar,
        streak,
        xp,
        diamonds,
        subscriptionTier,
        completedLessonIds,
        dailyLessonCompletions,
        lastStudyDate,
        isAdmin,
      ];

  UserEntity copyWith({
    String? id,
    String? email,
    String? name,
    String? avatar,
    int? streak,
    int? xp,
    int? diamonds,
    SubscriptionTier? subscriptionTier,
    List<String>? completedLessonIds,
    Map<String, List<String>>? dailyLessonCompletions,
    DateTime? lastStudyDate,
    bool? isAdmin,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      streak: streak ?? this.streak,
      xp: xp ?? this.xp,
      diamonds: diamonds ?? this.diamonds,
      subscriptionTier: subscriptionTier ?? this.subscriptionTier,
      completedLessonIds: completedLessonIds ?? this.completedLessonIds,
      dailyLessonCompletions: dailyLessonCompletions ?? this.dailyLessonCompletions,
      lastStudyDate: lastStudyDate ?? this.lastStudyDate,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }
}
