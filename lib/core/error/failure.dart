import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure([this.message = '']);

  final String message;

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Lỗi máy chủ']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Không có kết nối mạng']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Đăng nhập thất bại']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Lỗi bộ nhớ cục bộ']);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Dữ liệu không hợp lệ']);
}
