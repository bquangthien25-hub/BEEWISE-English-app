import 'package:equatable/equatable.dart';

import '../../../domain/entities/lesson_entity.dart';

abstract class LessonState extends Equatable {
  const LessonState();

  @override
  List<Object?> get props => [];
}

class LessonInitial extends LessonState {
  const LessonInitial();
}

class LessonLoading extends LessonState {
  const LessonLoading();
}

class LessonLoaded extends LessonState {
  const LessonLoaded(this.lessons);

  final List<LessonEntity> lessons;

  @override
  List<Object?> get props => [lessons];
}

class LessonError extends LessonState {
  const LessonError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
