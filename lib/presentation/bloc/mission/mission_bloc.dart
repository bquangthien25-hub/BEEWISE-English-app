import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/failure.dart';
import '../../../domain/repositories/gamification_repository.dart';
import '../auth/auth_bloc.dart';
import '../auth/auth_event.dart';
import 'mission_event.dart';
import 'mission_state.dart';

class MissionBloc extends Bloc<MissionEvent, MissionState> {
  MissionBloc({
    required GamificationRepository gamificationRepository,
    required AuthBloc authBloc,
  })  : _gamificationRepository = gamificationRepository,
        _authBloc = authBloc,
        super(const MissionInitial()) {
    on<MissionLoadRequested>(_onLoad);
    on<MissionClaimRequested>(_onClaim);
    on<MissionRefreshRequested>(_onRefresh);
  }

  final GamificationRepository _gamificationRepository;
  final AuthBloc _authBloc;

  Future<void> _onLoad(
    MissionLoadRequested event,
    Emitter<MissionState> emit,
  ) async {
    emit(const MissionLoading());
    await _loadMissions(emit);
  }

  Future<void> _onRefresh(
    MissionRefreshRequested event,
    Emitter<MissionState> emit,
  ) async {
    await _loadMissions(emit);
  }

  Future<void> _loadMissions(Emitter<MissionState> emit) async {
    try {
      final missions = await _gamificationRepository.getDailyMissions();
      final user = await _gamificationRepository.getCurrentProfile();
      if (user == null) {
        emit(const MissionError('Chưa đăng nhập'));
        return;
      }
      emit(MissionReady(missions: missions, user: user));
    } on Failure catch (e) {
      emit(MissionError(e.message));
    } catch (e) {
      emit(MissionError(e.toString()));
    }
  }

  Future<void> _onClaim(
    MissionClaimRequested event,
    Emitter<MissionState> emit,
  ) async {
    try {
      final user = await _gamificationRepository.claimMissionReward(event.missionId);
      _authBloc.add(UserProfileRefreshed(user));
      final missions = await _gamificationRepository.getDailyMissions();
      emit(MissionReady(missions: missions, user: user));
    } on Failure catch (e) {
      emit(MissionError(e.message));
    } catch (e) {
      emit(MissionError(e.toString()));
    }
  }
}
