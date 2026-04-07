import 'dart:typed_data';

import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> login(String email, String password);

  Future<UserEntity> register(String name, String email, String password);

  Future<void> sendPasswordResetEmail(String email);

  /// Đổi họ tên (Firebase Auth + Firestore `users`).
  Future<UserEntity> updateDisplayName(UserEntity current, String newName);

  /// Đổi mật khẩu (cần mật khẩu hiện tại — xác thực lại).
  Future<void> updatePassword(
    UserEntity current, {
    required String currentPassword,
    required String newPassword,
  });

  /// Ảnh đại diện (PNG/JPEG bytes). [fileExtension]: `png` | `jpg` | `jpeg`.
  Future<UserEntity> updateProfilePhoto(
    UserEntity current,
    Uint8List imageBytes,
    String fileExtension,
  );
}
