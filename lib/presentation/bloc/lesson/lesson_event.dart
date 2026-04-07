import 'package:equatable/equatable.dart';

abstract class LessonEvent extends Equatable {
  const LessonEvent();

  @override
  List<Object?> get props => [];
}

class LessonLoadRequested extends LessonEvent {
  const LessonLoadRequested();
}
