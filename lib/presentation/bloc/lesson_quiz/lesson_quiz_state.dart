import 'package:equatable/equatable.dart';

import '../../../domain/entities/lesson_entity.dart';

abstract class LessonQuizState extends Equatable {
  const LessonQuizState();

  @override
  List<Object?> get props => [];
}

class LessonQuizInitial extends LessonQuizState {
  const LessonQuizInitial();
}

class LessonQuizLoading extends LessonQuizState {
  const LessonQuizLoading();
}

class LessonQuizLoadFailure extends LessonQuizState {
  const LessonQuizLoadFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class LessonQuizPlaying extends LessonQuizState {
  const LessonQuizPlaying({
    required this.lesson,
    required this.questionIndex,
    required this.correctCount,
    required this.matchVietnameseOrder,
    required this.grammarWordOrder,
    this.selectedImage,
    this.selectedReading,
    this.writingText = '',
    this.feedback,
    this.canGoNext = false,
  });

  final LessonEntity lesson;
  final int questionIndex;
  final int correctCount;

  /// Thứ tự tiếng Việt hiện tại (kéo thả).
  final List<String> matchVietnameseOrder;

  /// Thứ từ hiện tại (kéo thả ngữ pháp).
  final List<String> grammarWordOrder;

  final int? selectedImage;
  final int? selectedReading;
  final String writingText;

  final String? feedback;
  final bool canGoNext;

  LessonQuizPlaying copyWith({
    LessonEntity? lesson,
    int? questionIndex,
    int? correctCount,
    List<String>? matchVietnameseOrder,
    List<String>? grammarWordOrder,
    int? selectedImage,
    int? selectedReading,
    String? writingText,
    String? feedback,
    bool? canGoNext,
    bool clearFeedback = false,
    bool clearSelection = false,
  }) {
    return LessonQuizPlaying(
      lesson: lesson ?? this.lesson,
      questionIndex: questionIndex ?? this.questionIndex,
      correctCount: correctCount ?? this.correctCount,
      matchVietnameseOrder: matchVietnameseOrder ?? this.matchVietnameseOrder,
      grammarWordOrder: grammarWordOrder ?? this.grammarWordOrder,
      selectedImage: clearSelection ? null : (selectedImage ?? this.selectedImage),
      selectedReading: clearSelection ? null : (selectedReading ?? this.selectedReading),
      writingText: writingText ?? this.writingText,
      feedback: clearFeedback ? null : (feedback ?? this.feedback),
      canGoNext: clearFeedback ? false : (canGoNext ?? this.canGoNext),
    );
  }

  @override
  List<Object?> get props => [
        lesson,
        questionIndex,
        correctCount,
        matchVietnameseOrder,
        grammarWordOrder,
        selectedImage,
        selectedReading,
        writingText,
        feedback,
        canGoNext,
      ];
}

class LessonQuizFinished extends LessonQuizState {
  const LessonQuizFinished({
    required this.lesson,
    required this.correctCount,
    required this.totalQuestions,
    required this.xpEarned,
  });

  final LessonEntity lesson;
  final int correctCount;
  final int totalQuestions;
  final int xpEarned;

  @override
  List<Object?> get props => [lesson, correctCount, totalQuestions, xpEarned];
}
