import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repositories/theme_repository.dart';
import 'theme_event.dart';
import 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc({required ThemeRepository themeRepository})
      : _themeRepository = themeRepository,
        super(const ThemeInitial()) {
    on<ThemeLoadRequested>(_onLoad);
    on<ThemeModeChanged>(_onModeChanged);
  }

  final ThemeRepository _themeRepository;

  Future<void> _onLoad(
    ThemeLoadRequested event,
    Emitter<ThemeState> emit,
  ) async {
    final mode = await _themeRepository.loadThemeMode();
    emit(ThemeReady(mode));
  }

  Future<void> _onModeChanged(
    ThemeModeChanged event,
    Emitter<ThemeState> emit,
  ) async {
    await _themeRepository.saveThemeMode(event.mode);
    emit(ThemeReady(event.mode));
  }
}
