import 'package:equatable/equatable.dart';

abstract class LessonQuizEvent extends Equatable {
  const LessonQuizEvent();

  @override
  List<Object?> get props => [];
}

class LessonQuizLoadRequested extends LessonQuizEvent {
  const LessonQuizLoadRequested(this.lessonId);

  final String lessonId;

  @override
  List<Object?> get props => [lessonId];
}

class LessonQuizImageSelected extends LessonQuizEvent {
  const LessonQuizImageSelected(this.index);

  final int index;
}

class LessonQuizMatchReordered extends LessonQuizEvent {
  const LessonQuizMatchReordered(this.order);

  final List<String> order;

  @override
  List<Object?> get props => [order];
}

class LessonQuizGrammarReordered extends LessonQuizEvent {
  const LessonQuizGrammarReordered(this.order);

  final List<String> order;

  @override
  List<Object?> get props => [order];
}

class LessonQuizReadingSelected extends LessonQuizEvent {
  const LessonQuizReadingSelected(this.index);

  final int index;
}

class LessonQuizWritingChanged extends LessonQuizEvent {
  const LessonQuizWritingChanged(this.text);

  final String text;
}

class LessonQuizCheckPressed extends LessonQuizEvent {
  const LessonQuizCheckPressed();
}

class LessonQuizContinuePressed extends LessonQuizEvent {
  const LessonQuizContinuePressed();
}
