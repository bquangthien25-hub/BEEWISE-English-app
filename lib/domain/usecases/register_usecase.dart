import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  RegisterUseCase(this._repository);

  final AuthRepository _repository;

  Future<UserEntity> call(String name, String email, String password) {
    return _repository.register(name, email, password);
  }
}
