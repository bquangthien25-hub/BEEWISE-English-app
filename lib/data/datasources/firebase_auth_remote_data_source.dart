import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_storage/firebase_storage.dart';

import '../../core/error/exceptions.dart';
import '../models/user_model.dart';
import 'auth_remote_data_source.dart';

class FirebaseAuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  FirebaseAuthRemoteDataSourceImpl({fb.FirebaseAuth? auth}) : _auth = auth ?? fb.FirebaseAuth.instance;

  final fb.FirebaseAuth _auth;

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
      final user = cred.user;
      if (user == null) throw const AuthException('Đã xảy ra lỗi khi đăng nhập');

      // Thử lấy dữ liệu cũ từ Firestore
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists && doc.data() != null) {
          return UserModel.fromJson(doc.data()!..['id'] = doc.id);
        }
      } catch (_) {
        // Fallback below
      }

      return UserModel(
        id: user.uid,
        email: user.email ?? email,
        name: user.displayName ?? '',
        avatar: user.photoURL,
      );
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Lỗi xác thực');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> register(String name, String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      final user = cred.user;
      if (user == null) throw const AuthException('Không thể tạo tài khoản');

      await user.updateDisplayName(name);

      final model = UserModel(
        id: user.uid,
        email: email,
        name: name,
      );

      // Create new document for the user on Firestore.
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(model.toJson());

      return model;
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Lỗi đăng ký');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Lỗi khi gửi email đặt lại mật khẩu');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> updateDisplayName(String email, String newName) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw const AuthException('Chưa đăng nhập');
      if (user.email?.toLowerCase() != email.trim().toLowerCase()) {
        throw const AuthException('Phiên đăng nhập không khớp');
      }
      final trimmed = newName.trim();
      if (trimmed.isEmpty) throw const AuthException('Tên không được để trống');
      if (trimmed.length < 2) throw const AuthException('Tên tối thiểu 2 ký tự');

      await user.updateDisplayName(trimmed);
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
            {'name': trimmed},
            SetOptions(merge: true),
          );

      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromJson(doc.data()!..['id'] = doc.id);
      }
      return UserModel(
        id: user.uid,
        email: user.email ?? email,
        name: trimmed,
      );
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Không thể cập nhật tên');
    } catch (e) {
      if (e is AuthException) rethrow;
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> updatePassword(
    String email, {
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw const AuthException('Chưa đăng nhập');
      final em = user.email;
      if (em == null) throw const AuthException('Tài khoản không có email đăng nhập');
      if (em.toLowerCase() != email.trim().toLowerCase()) {
        throw const AuthException('Phiên đăng nhập không khớp');
      }
      if (newPassword.length < 6) {
        throw const AuthException('Mật khẩu mới tối thiểu 6 ký tự');
      }
      if (newPassword == currentPassword) {
        throw const AuthException('Mật khẩu mới phải khác mật khẩu hiện tại');
      }

      final cred = fb.EmailAuthProvider.credential(email: em, password: currentPassword);
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPassword);
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Không thể đổi mật khẩu');
    } catch (e) {
      if (e is AuthException) rethrow;
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> updateProfilePhoto(Uint8List imageBytes, String fileExtension) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw const AuthException('Chưa đăng nhập');

      final ext = fileExtension.toLowerCase().replaceAll('.', '');
      if (ext != 'png' && ext != 'jpg') {
        throw const AuthException('Chỉ chấp nhận ảnh PNG hoặc JPG');
      }
      if (imageBytes.length > 5 * 1024 * 1024) {
        throw const AuthException('Ảnh tối đa 5 MB');
      }

      final contentType = ext == 'png' ? 'image/png' : 'image/jpeg';
      final ref = FirebaseStorage.instance
          .ref()
          .child('users')
          .child(user.uid)
          .child('avatar.$ext');

      await ref.putData(
        imageBytes,
        SettableMetadata(contentType: contentType),
      );
      final url = await ref.getDownloadURL();
      await user.updatePhotoURL(url);

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
            {'avatar': url},
            SetOptions(merge: true),
          );

      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromJson(doc.data()!..['id'] = doc.id);
      }
      return UserModel(
        id: user.uid,
        email: user.email ?? '',
        name: user.displayName ?? '',
        avatar: url,
      );
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Không thể cập nhật ảnh');
    } on FirebaseException catch (e) {
      throw AuthException(e.message ?? 'Lỗi tải ảnh lên');
    } catch (e) {
      if (e is AuthException) rethrow;
      throw ServerException(e.toString());
    }
  }
}
