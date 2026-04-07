import '../domain/entities/user_entity.dart';

/// Phiên người dùng hiện tại (in-memory), đồng bộ với [GamificationRepository].
class UserProfileStore {
  UserEntity? current;

  void setUser(UserEntity user) => current = user;

  void updateUser(UserEntity user) => current = user;

  void clear() => current = null;
}
