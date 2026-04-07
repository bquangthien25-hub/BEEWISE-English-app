import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/failure.dart';
import '../../../domain/usecases/get_lessons_usecase.dart';
import 'lesson_event.dart';
import 'lesson_state.dart';

class LessonBloc extends Bloc<LessonEvent, LessonState> {
  LessonBloc({required GetLessonsUseCase getLessonsUseCase})
      : _getLessonsUseCase = getLessonsUseCase,
        super(const LessonInitial()) {
    on<LessonLoadRequested>(_onLoad);
  }

  final GetLessonsUseCase _getLessonsUseCase;

  Future<void> _onLoad(
    LessonLoadRequested event,
    Emitter<LessonState> emit,
  ) async {
    emit(const LessonLoading());
    try {
      final lessons = await _getLessonsUseCase();
      emit(LessonLoaded(lessons));
    } on Failure catch (e) {
      emit(LessonError(e.message));
    } catch (e) {
      emit(LessonError(e.toString()));
    }
  }
}
