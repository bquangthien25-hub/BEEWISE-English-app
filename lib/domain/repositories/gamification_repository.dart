import '../entities/daily_mission.dart';
import '../entities/user_entity.dart';

abstract class GamificationRepository {
  Future<void> initializeSession(UserEntity user);

  Future<UserEntity?> getCurrentProfile();

  Future<List<DailyMission>> getDailyMissions();

  Future<UserEntity> onLessonCompleted({
    required String lessonId,
    required int xpEarned,
  });

  Future<UserEntity> claimMissionReward(String missionId);

  /// Trả về true một lần khi streak vừa tăng (hoạt động streak celebration).
  bool consumeStreakCelebration();

  void clearSession();

  /// Mua gói trong cửa hàng (mock). [planKey]: `super` | `family`.
  Future<UserEntity> purchaseShopPlan(String planKey);
}
