import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/failure.dart';
import '../../../domain/repositories/gamification_repository.dart';
import '../../../domain/usecases/login_usecase.dart';
import '../../../domain/usecases/register_usecase.dart';
import '../../../domain/usecases/forgot_password_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required ForgotPasswordUseCase forgotPasswordUseCase,
    required GamificationRepository gamificationRepository,
  })  : _loginUseCase = loginUseCase,
        _registerUseCase = registerUseCase,
        _forgotPasswordUseCase = forgotPasswordUseCase,
        _gamificationRepository = gamificationRepository,
        super(const AuthInitial()) {
    on<LoginWithEmailRequested>(_onLogin);
    on<RegisterWithEmailRequested>(_onRegister);
    on<ForgotPasswordRequested>(_onForgotPassword);
    on<LogoutRequested>(_onLogout);
    on<UserProfileRefreshed>(_onProfileRefreshed);
  }

  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final ForgotPasswordUseCase _forgotPasswordUseCase;
  final GamificationRepository _gamificationRepository;

  Future<void> _onLogin(
    LoginWithEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _loginUseCase(event.email, event.password);
      await _gamificationRepository.initializeSession(user);
      emit(AuthAuthenticated(user));
    } on Failure catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onRegister(
    RegisterWithEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _registerUseCase(event.name, event.email, event.password);
      await _gamificationRepository.initializeSession(user);
      emit(AuthAuthenticated(user));
    } on Failure catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onForgotPassword(
    ForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _forgotPasswordUseCase(event.email);
      emit(const AuthPasswordResetSent());
    } on Failure catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogout(LogoutRequested event, Emitter<AuthState> emit) async {
    _gamificationRepository.clearSession();
    emit(const AuthInitial());
  }

  void _onProfileRefreshed(UserProfileRefreshed event, Emitter<AuthState> emit) {
    emit(AuthAuthenticated(event.user));
  }
}
