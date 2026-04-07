import '../repositories/auth_repository.dart';

class ForgotPasswordUseCase {
  ForgotPasswordUseCase(this.repository);

  final AuthRepository repository;

  Future<void> call(String email) async {
    return await repository.sendPasswordResetEmail(email);
  }
}
