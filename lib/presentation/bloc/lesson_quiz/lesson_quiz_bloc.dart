import 'dart:math';

import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/quiz_text_normalizer.dart';
import '../../../domain/entities/lesson_entity.dart';
import '../../../domain/entities/question_entity.dart';
import '../../../domain/entities/question_type.dart';
import '../../../domain/repositories/gamification_repository.dart';
import '../../../domain/usecases/get_lesson_by_id_usecase.dart';
import '../auth/auth_bloc.dart';
import '../auth/auth_event.dart';
import 'lesson_quiz_event.dart';
import 'lesson_quiz_state.dart';

class LessonQuizBloc extends Bloc<LessonQuizEvent, LessonQuizState> {
  LessonQuizBloc({
    required GetLessonByIdUseCase getLessonById,
    required GamificationRepository gamificationRepository,
    required AuthBloc authBloc,
  })  : _getLessonById = getLessonById,
        _gamificationRepository = gamificationRepository,
        _authBloc = authBloc,
        super(const LessonQuizInitial()) {
    on<LessonQuizLoadRequested>(_onLoad);
    on<LessonQuizImageSelected>(_onImage);
    on<LessonQuizMatchReordered>(_onMatchReorder);
    on<LessonQuizGrammarReordered>(_onGrammarReorder);
    on<LessonQuizReadingSelected>(_onReading);
    on<LessonQuizWritingChanged>(_onWriting);
    on<LessonQuizCheckPressed>(_onCheck);
    on<LessonQuizContinuePressed>(_onContinue);
  }

  final GetLessonByIdUseCase _getLessonById;
  final GamificationRepository _gamificationRepository;
  final AuthBloc _authBloc;

  Future<void> _onLoad(
    LessonQuizLoadRequested event,
    Emitter<LessonQuizState> emit,
  ) async {
    emit(const LessonQuizLoading());
    final lesson = await _getLessonById(event.lessonId);
    if (lesson == null) {
      emit(const LessonQuizLoadFailure('Không tìm thấy bài học.'));
      return;
    }
    if (!lesson.isUnlocked) {
      emit(const LessonQuizLoadFailure('Bài học chưa mở khóa.'));
      return;
    }
    if (lesson.questions.isEmpty) {
      emit(const LessonQuizLoadFailure('Bài học chưa có câu hỏi.'));
      return;
    }
    emit(_buildPlaying(lesson, 0, 0));
  }

  LessonQuizPlaying _buildPlaying(
    LessonEntity lesson,
    int questionIndex,
    int correctCount,
  ) {
    final q = lesson.questions[questionIndex];
    var matchOrder = <String>[];
    var grammarOrder = <String>[];

    if (q.type == QuestionType.vocabularyMatch) {
      final vi = List<String>.from(q.matchVietnamese ?? const <String>[]);
      vi.shuffle(Random());
      matchOrder = vi;
    }
    if (q.type == QuestionType.grammarOrder) {
      grammarOrder = List<String>.from(q.wordBank ?? const <String>[]);
    }

    return LessonQuizPlaying(
      lesson: lesson,
      questionIndex: questionIndex,
      correctCount: correctCount,
      matchVietnameseOrder: matchOrder,
      grammarWordOrder: grammarOrder,
    );
  }

  void _onImage(LessonQuizImageSelected event, Emitter<LessonQuizState> emit) {
    final s = state;
    if (s is! LessonQuizPlaying) return;
    emit(s.copyWith(selectedImage: event.index, clearFeedback: true));
  }

  void _onMatchReorder(LessonQuizMatchReordered event, Emitter<LessonQuizState> emit) {
    final s = state;
    if (s is! LessonQuizPlaying) return;
    emit(s.copyWith(matchVietnameseOrder: event.order, clearFeedback: true));
  }

  void _onGrammarReorder(LessonQuizGrammarReordered event, Emitter<LessonQuizState> emit) {
    final s = state;
    if (s is! LessonQuizPlaying) return;
    emit(s.copyWith(grammarWordOrder: event.order, clearFeedback: true));
  }

  void _onReading(LessonQuizReadingSelected event, Emitter<LessonQuizState> emit) {
    final s = state;
    if (s is! LessonQuizPlaying) return;
    emit(s.copyWith(selectedReading: event.index, clearFeedback: true));
  }

  void _onWriting(LessonQuizWritingChanged event, Emitter<LessonQuizState> emit) {
    final s = state;
    if (s is! LessonQuizPlaying) return;
    emit(s.copyWith(writingText: event.text, clearFeedback: true));
  }

  Future<void> _onCheck(
    LessonQuizCheckPressed event,
    Emitter<LessonQuizState> emit,
  ) async {
    final s = state;
    if (s is! LessonQuizPlaying) return;

    final q = s.lesson.questions[s.questionIndex];
    final ok = _evaluateAnswer(q, s);

    if (ok) {
      emit(
        s.copyWith(
          correctCount: s.correctCount + 1,
          feedback: 'Chính xác!',
          canGoNext: true,
        ),
      );
    } else {
      emit(
        s.copyWith(
          feedback: 'Chưa đúng — hãy thử lại!',
          canGoNext: false,
        ),
      );
    }
  }

  Future<void> _onContinue(
    LessonQuizContinuePressed event,
    Emitter<LessonQuizState> emit,
  ) async {
    final s = state;
    if (s is! LessonQuizPlaying || !s.canGoNext) return;

    final last = s.questionIndex >= s.lesson.questions.length - 1;
    if (last) {
      final user = await _gamificationRepository.onLessonCompleted(
        lessonId: s.lesson.id,
        xpEarned: s.lesson.xpReward,
      );
      _authBloc.add(UserProfileRefreshed(user));
      emit(
        LessonQuizFinished(
          lesson: s.lesson,
          correctCount: s.correctCount,
          totalQuestions: s.lesson.questions.length,
          xpEarned: s.lesson.xpReward,
        ),
      );
      return;
    }

    emit(_buildPlaying(s.lesson, s.questionIndex + 1, s.correctCount));
  }

  bool _evaluateAnswer(QuestionEntity q, LessonQuizPlaying s) {
    switch (q.type) {
      case QuestionType.vocabularyImage:
        return s.selectedImage != null && s.selectedImage == q.correctImageIndex;
      case QuestionType.vocabularyMatch:
        return listEquals(s.matchVietnameseOrder, q.matchVietnamese);
      case QuestionType.grammarOrder:
        final built = QuizTextNormalizer.normalizeSentence(s.grammarWordOrder.join(' '));
        final target = QuizTextNormalizer.normalizeSentence(q.correctSentence ?? '');
        return built == target && built.isNotEmpty;
      case QuestionType.readingComprehension:
        return s.selectedReading != null && s.selectedReading == q.readingCorrectIndex;
      case QuestionType.writingTranslation:
        return QuizTextNormalizer.matchesAnyAccepted(
          s.writingText,
          q.acceptedEnglishAnswers ?? const [],
        );
    }
  }
}
