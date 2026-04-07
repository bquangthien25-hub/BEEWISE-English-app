import 'dart:async';

import '../../core/error/failure.dart';
import '../../domain/entities/subscription_tier.dart';
import '../../domain/entities/daily_mission.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/gamification_repository.dart';
import '../models/user_model.dart';
import '../user_profile_store.dart';
import '../datasources/local_user_data_source.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GamificationRepositoryImpl implements GamificationRepository {
  GamificationRepositoryImpl(this._store, [this._local]);

  final UserProfileStore _store;
  final LocalUserDataSource? _local;

  int _xpToday = 0;
  DateTime? _trackingDay;
  bool _pendingStreakBurst = false;
  final Set<String> _claimedMissionIds = {};
  final Set<String> _lessonsTodayIds = {};

  DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  bool _sameDay(DateTime a, DateTime b) => _dayOnly(a) == _dayOnly(b);

  bool _isYesterday(DateTime today, DateTime last) {
    final y = today.subtract(const Duration(days: 1));
    return _sameDay(y, last);
  }

  String _dayKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  void _ensureDay() {
    final now = DateTime.now();
    if (_trackingDay == null || !_sameDay(_trackingDay!, now)) {
      _xpToday = 0;
      _lessonsTodayIds.clear();
      _claimedMissionIds.clear();
      _trackingDay = now;
    }
  }

  @override
  Future<void> initializeSession(UserEntity user) async {
    _store.setUser(user);
    _ensureDay();
    _pendingStreakBurst = false;
  }

  Future<void> _persist(UserModel u) async {
    try {
      if (_local != null) {
        await _local.saveUser(u);
      }
    } catch (_) {
      // ignore local persistence errors
    }
    
    // Đồng bộ lên Cloud Firestore
    try {
       await FirebaseFirestore.instance.collection('users').doc(u.id).set(u.toJson());
    } catch (_) {
       // ignore firestore sync errors if offline
    }
  }

  @override
  Future<UserEntity?> getCurrentProfile() async => _store.current;

  List<DailyMission> _buildMissions(UserEntity u) {
    _ensureDay();

    final lessonProgress = _lessonsTodayIds.length.clamp(0, 1);
    final xpProgress = _xpToday.clamp(0, 50);

    /// Duy trì streak: đã có streak ≥ 1 và đã học ít nhất 1 bài hôm nay.
    final streakMaintained =
        u.streak >= 1 && _lessonsTodayIds.isNotEmpty;

    return [
      DailyMission(
        id: 'm1',
        title: 'Hoàn thành 1 bài học',
        progress: lessonProgress,
        target: 1,
        rewardDiamonds: 5,
        rewardXp: 3,
        completed: lessonProgress >= 1,
        claimed: _claimedMissionIds.contains('m1'),
      ),
      DailyMission(
        id: 'm2',
        title: 'Đạt 50 XP hôm nay',
        progress: xpProgress,
        target: 50,
        rewardDiamonds: 10,
        rewardXp: 5,
        completed: _xpToday >= 50,
        claimed: _claimedMissionIds.contains('m2'),
      ),
      DailyMission(
        id: 'm3',
        title: 'Duy trì Streak (học hôm nay)',
        progress: streakMaintained ? 1 : 0,
        target: 1,
        rewardDiamonds: 8,
        rewardXp: 5,
        completed: streakMaintained,
        claimed: _claimedMissionIds.contains('m3'),
      ),
    ];
  }

  @override
  Future<List<DailyMission>> getDailyMissions() async {
    final u = _store.current;
    if (u == null) throw const AuthFailure('Chưa đăng nhập');
    return _buildMissions(u);
  }

  @override
  Future<UserEntity> onLessonCompleted({
    required String lessonId,
    required int xpEarned,
  }) async {
    final u = _store.current;
    if (u == null) throw const AuthFailure('Chưa đăng nhập');

    _ensureDay();
    _lessonsTodayIds.add(lessonId);
    _xpToday += xpEarned;

    final completed = List<String>.from(u.completedLessonIds);
    if (!completed.contains(lessonId)) {
      completed.add(lessonId);
    }

    final today = DateTime.now();
    final dayKey = _dayKey(today);
    final daily = Map<String, List<String>>.from(u.dailyLessonCompletions);
    final todayParts = List<String>.from(daily[dayKey] ?? []);
    if (!todayParts.contains(lessonId)) {
      todayParts.add(lessonId);
    }
    daily[dayKey] = todayParts;
    final last = u.lastStudyDate;
    var streak = u.streak;

    if (last == null) {
      streak = 1;
      _pendingStreakBurst = true;
    } else if (_sameDay(last, today)) {
      // cùng ngày
    } else if (_isYesterday(today, last)) {
      streak += 1;
      _pendingStreakBurst = true;
    } else {
      streak = 1;
      _pendingStreakBurst = true;
    }

    final newXp = u.xp + xpEarned;
    final updated = UserModel(
      id: u.id,
      email: u.email,
      name: u.name,
      avatar: u.avatar,
      streak: streak,
      xp: newXp,
      diamonds: u.diamonds,
      subscriptionTier: u.subscriptionTier,
      completedLessonIds: completed,
      dailyLessonCompletions: daily,
      lastStudyDate: today,
    );

    _store.updateUser(updated);
    unawaited(_persist(updated));
    return updated.toEntity();
  }

  @override
  Future<UserEntity> claimMissionReward(String missionId) async {
    final u = _store.current;
    if (u == null) throw const AuthFailure('Chưa đăng nhập');

    final missions = _buildMissions(u);
    DailyMission? found;
    for (final m in missions) {
      if (m.id == missionId) {
        found = m;
        break;
      }
    }
    if (found == null) throw const AuthFailure('Nhiệm vụ không tồn tại');
    if (!found.completed) throw const AuthFailure('Chưa hoàn thành nhiệm vụ');
    if (_claimedMissionIds.contains(missionId)) {
      throw const AuthFailure('Đã nhận thưởng');
    }

    _claimedMissionIds.add(missionId);
    final updated = UserModel(
      id: u.id,
      email: u.email,
      name: u.name,
      avatar: u.avatar,
      streak: u.streak,
      xp: u.xp + found.rewardXp,
      diamonds: u.diamonds + found.rewardDiamonds,
      subscriptionTier: u.subscriptionTier,
      completedLessonIds: u.completedLessonIds,
      dailyLessonCompletions: u.dailyLessonCompletions,
      lastStudyDate: u.lastStudyDate,
    );
    _store.updateUser(updated);
    unawaited(_persist(updated));
    return updated.toEntity();
  }

  @override
  bool consumeStreakCelebration() {
    final v = _pendingStreakBurst;
    _pendingStreakBurst = false;
    return v;
  }

  @override
  void clearSession() {
    _store.clear();
    _xpToday = 0;
    _trackingDay = null;
    _pendingStreakBurst = false;
    _claimedMissionIds.clear();
    _lessonsTodayIds.clear();
  }

  /// Super: dùng thử 0 kim cương. Family: 100 kim cương (demo). Cùng nâng [SubscriptionTier.premium].
  @override
  Future<UserEntity> purchaseShopPlan(String planKey) async {
    final u = _store.current;
    if (u == null) throw const AuthFailure('Chưa đăng nhập');

    if (u.subscriptionTier == SubscriptionTier.premium) {
      throw const ValidationFailure('Bạn đã kích hoạt gói Premium.');
    }

    const familyDiamondCost = 100;
    final isFamily = planKey == 'family';

    if (isFamily && u.diamonds < familyDiamondCost) {
      throw ValidationFailure(
        'Cần $familyDiamondCost kim cương để mua gói gia đình (bạn đang có ${u.diamonds}).',
      );
    }

    final newDiamonds = isFamily ? u.diamonds - familyDiamondCost : u.diamonds;

    final updated = UserModel(
      id: u.id,
      email: u.email,
      name: u.name,
      avatar: u.avatar,
      streak: u.streak,
      xp: u.xp,
      diamonds: newDiamonds,
      subscriptionTier: SubscriptionTier.premium,
      completedLessonIds: u.completedLessonIds,
      dailyLessonCompletions: u.dailyLessonCompletions,
      lastStudyDate: u.lastStudyDate,
    );
    _store.updateUser(updated);
    return updated.toEntity();
  }
}
