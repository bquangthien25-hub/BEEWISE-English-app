import 'dart:async';
import 'dart:typed_data';

import '../../core/error/exceptions.dart';
import '../../domain/entities/subscription_tier.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);

  Future<UserModel> register(String name, String email, String password);

  Future<void> sendPasswordResetEmail(String email);

  Future<UserModel> updateDisplayName(String email, String newName);

  Future<void> updatePassword(
    String email, {
    required String currentPassword,
    required String newPassword,
  });

  Future<UserModel> updateProfilePhoto(Uint8List imageBytes, String fileExtension);
}

class _StoredUser {
  _StoredUser({
    required this.id,
    required this.email,
    required this.password,
    required this.name,
    this.streak = 0,
    this.xp = 0,
    this.diamonds = 0,
    this.subscriptionTier = SubscriptionTier.basic,
  });

  final String id;
  final String email;
  String password;
  String name;
  final String? avatar = null;
  final int streak;
  final int xp;
  final int diamonds;
  final SubscriptionTier subscriptionTier;
  final List<String> completedLessonIds = const [];
}

/// In-memory auth (no real API). Replace with REST later.
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl() {
    _users['demo@beewise.com'] = _StoredUser(
      id: 'user_1',
      email: 'demo@beewise.com',
      password: 'password123',
      name: 'Bee Learner',
      streak: 7,
      xp: 1200,
      diamonds: 100,
      subscriptionTier: SubscriptionTier.premium,
    );
  }

  final Map<String, _StoredUser> _users = {};
  int _nextUserSeq = 2;

  UserModel _toModel(_StoredUser s) {
    return UserModel(
      id: s.id,
      email: s.email,
      name: s.name,
      avatar: s.avatar,
      streak: s.streak,
      xp: s.xp,
      diamonds: s.diamonds,
      subscriptionTier: s.subscriptionTier,
      completedLessonIds: s.completedLessonIds,
    );
  }

  @override
  Future<UserModel> login(String email, String password) async {
    await Future<void>.delayed(const Duration(seconds: 2));

    final key = email.trim().toLowerCase();
    final stored = _users[key];
    // If user not found, create a new account automatically (minimal profile).
    if (stored == null) {
      final id = 'user_${_nextUserSeq++}';
      final localName = key.split('@').first;
      _users[key] = _StoredUser(
        id: id,
        email: key,
        password: password,
        name: localName.isNotEmpty ? localName : 'User',
        streak: 0,
        xp: 0,
        diamonds: 0,
        subscriptionTier: SubscriptionTier.basic,
      );
      return _toModel(_users[key]!);
    }

    if (stored.password != password) {
      throw AuthException('Email hoặc mật khẩu không đúng');
    }

    return _toModel(stored);
  }

  @override
  Future<UserModel> register(String name, String email, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 1500));

    final key = email.trim().toLowerCase();
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw AuthException('Vui lòng nhập tên');
    }
    // If user already exists, return existing user (treat as login).
    if (_users.containsKey(key)) {
      return _toModel(_users[key]!);
    }

    final id = 'user_${_nextUserSeq++}';
    _users[key] = _StoredUser(
      id: id,
      email: key,
      password: password,
      name: trimmedName,
      streak: 0,
      xp: 0,
      diamonds: 0,
      subscriptionTier: SubscriptionTier.basic,
    );

    return _toModel(_users[key]!);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await Future<void>.delayed(const Duration(seconds: 1));
    final key = email.trim().toLowerCase();
    if (!_users.containsKey(key)) {
      throw AuthException('Email không tồn tại trong hệ thống (mock)');
    }
  }

  @override
  Future<UserModel> updateDisplayName(String email, String newName) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final key = email.trim().toLowerCase();
    final trimmed = newName.trim();
    if (trimmed.isEmpty) {
      throw AuthException('Tên không được để trống');
    }
    if (trimmed.length < 2) {
      throw AuthException('Tên tối thiểu 2 ký tự');
    }
    final stored = _users[key];
    if (stored == null) {
      throw AuthException('Không tìm thấy người dùng');
    }
    stored.name = trimmed;
    return _toModel(stored);
  }

  @override
  Future<void> updatePassword(
    String email, {
    required String currentPassword,
    required String newPassword,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final key = email.trim().toLowerCase();
    final stored = _users[key];
    if (stored == null) {
      throw AuthException('Không tìm thấy người dùng');
    }
    if (stored.password != currentPassword) {
      throw AuthException('Mật khẩu hiện tại không đúng');
    }
    if (newPassword.length < 6) {
      throw AuthException('Mật khẩu mới tối thiểu 6 ký tự');
    }
    if (newPassword == currentPassword) {
      throw AuthException('Mật khẩu mới phải khác mật khẩu hiện tại');
    }
    stored.password = newPassword;
  }

  @override
  Future<UserModel> updateProfilePhoto(Uint8List imageBytes, String fileExtension) async {
    throw const AuthException('Đổi ảnh đại diện cần đăng nhập Firebase');
  }
}
