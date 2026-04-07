import '../../domain/entities/subscription_tier.dart';
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    super.avatar,
    super.streak = 0,
    super.xp = 0,
    super.diamonds = 0,
    super.subscriptionTier = SubscriptionTier.basic,
    super.completedLessonIds = const [],
    super.dailyLessonCompletions = const {},
    super.lastStudyDate,
    super.isAdmin = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      avatar: json['avatar'] as String?,
      streak: (json['streak'] as num?)?.toInt() ?? 0,
      xp: (json['xp'] as num?)?.toInt() ?? 0,
      diamonds: (json['diamonds'] as num?)?.toInt() ?? 0,
      subscriptionTier: _tierFrom(json['subscriptionTier'] as String?),
      completedLessonIds: (json['completedLessonIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      dailyLessonCompletions: _dailyMapFromJson(json['dailyLessonCompletions']),
      lastStudyDate: json['lastStudyDate'] == null
          ? null
          : DateTime.tryParse(json['lastStudyDate'] as String),
      isAdmin: json['isAdmin'] == true,
    );
  }

  static Map<String, List<String>> _dailyMapFromJson(dynamic raw) {
    if (raw == null || raw is! Map) return const {};
    return raw.map(
      (k, v) => MapEntry(
        k as String,
        (v as List<dynamic>).map((e) => e as String).toList(),
      ),
    );
  }

  static SubscriptionTier _tierFrom(String? raw) {
    if (raw == 'premium') return SubscriptionTier.premium;
    return SubscriptionTier.basic;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
        'avatar': avatar,
        'streak': streak,
        'xp': xp,
        'diamonds': diamonds,
        'subscriptionTier': subscriptionTier == SubscriptionTier.premium ? 'premium' : 'basic',
        'completedLessonIds': completedLessonIds,
        'dailyLessonCompletions': dailyLessonCompletions,
        'lastStudyDate': lastStudyDate?.toIso8601String(),
        'isAdmin': isAdmin,
      };

  UserEntity toEntity() => UserEntity(
        id: id,
        email: email,
        name: name,
        avatar: avatar,
        streak: streak,
        xp: xp,
        diamonds: diamonds,
        subscriptionTier: subscriptionTier,
        completedLessonIds: completedLessonIds,
        dailyLessonCompletions: dailyLessonCompletions,
        lastStudyDate: lastStudyDate,
        isAdmin: isAdmin,
      );

  @override
  UserModel copyWith({
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
    return UserModel(
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
