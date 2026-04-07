import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/failure.dart';
import '../../../domain/entities/league_tier.dart';
import '../../../domain/repositories/league_repository.dart';
import '../../../data/user_profile_store.dart';
import 'league_event.dart';
import 'league_state.dart';

class LeagueBloc extends Bloc<LeagueEvent, LeagueState> {
  LeagueBloc({
    required LeagueRepository leagueRepository,
    required UserProfileStore profileStore,
  })  : _leagueRepository = leagueRepository,
        _profileStore = profileStore,
        super(const LeagueInitial()) {
    on<LeagueLoadRequested>(_onLoad);
  }

  final LeagueRepository _leagueRepository;
  final UserProfileStore _profileStore;

  Future<void> _onLoad(
    LeagueLoadRequested event,
    Emitter<LeagueState> emit,
  ) async {
    emit(const LeagueLoading());
    try {
      final u = _profileStore.current;
      if (u == null) {
        emit(const LeagueError('Chưa đăng nhập'));
        return;
      }
      final tier = leagueTierFromXp(u.xp);
      final entries = await _leagueRepository.getTop20ForTier(tier);
      emit(LeagueReady(tier: tier, entries: entries, userXp: u.xp));
    } on Failure catch (e) {
      emit(LeagueError(e.message));
    } catch (e) {
      emit(LeagueError(e.toString()));
    }
  }
}
