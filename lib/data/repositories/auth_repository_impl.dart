import 'dart:typed_data';

import '../../core/error/exceptions.dart';
import '../../core/error/failure.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  final AuthRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  Future<void> _ensureNetwork() async {
    if (!await networkInfo.isConnected) {
      throw const NetworkFailure();
    }
  }

  @override
  Future<UserEntity> login(String email, String password) async {
    await _ensureNetwork();

    try {
      final model = await remoteDataSource.login(email, password);
      return model.toEntity();
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<UserEntity> register(String name, String email, String password) async {
    await _ensureNetwork();

    try {
      final model = await remoteDataSource.register(name, email, password);
      return model.toEntity();
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _ensureNetwork();

    try {
      await remoteDataSource.sendPasswordResetEmail(email);
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<UserEntity> updateDisplayName(UserEntity current, String newName) async {
    await _ensureNetwork();
    try {
      final model = await remoteDataSource.updateDisplayName(current.email, newName);
      return model.toEntity();
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<void> updatePassword(
    UserEntity current, {
    required String currentPassword,
    required String newPassword,
  }) async {
    await _ensureNetwork();
    try {
      await remoteDataSource.updatePassword(
        current.email,
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<UserEntity> updateProfilePhoto(
    UserEntity current,
    Uint8List imageBytes,
    String fileExtension,
  ) async {
    await _ensureNetwork();
    final ext = fileExtension.toLowerCase().replaceAll('.', '');
    if (ext != 'png' && ext != 'jpg' && ext != 'jpeg') {
      throw const AuthFailure('Chỉ chấp nhận ảnh PNG hoặc JPG');
    }
    if (imageBytes.length > 5 * 1024 * 1024) {
      throw const AuthFailure('Ảnh tối đa 5 MB');
    }
    try {
      final normalized = ext == 'jpeg' ? 'jpg' : ext;
      final model = await remoteDataSource.updateProfilePhoto(imageBytes, normalized);
      return model.toEntity();
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }
}
