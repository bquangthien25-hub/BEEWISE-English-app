import 'package:equatable/equatable.dart';

import 'question_entity.dart';
import 'skill_track.dart';

class LessonEntity extends Equatable {
  const LessonEntity({
    required this.id,
    required this.title,
    required this.isUnlocked,
    required this.questions,
    required this.topicId,
    required this.topicLabel,
    required this.skillTrack,
    this.xpReward = 20,
    this.estimatedMinutes = 5,
  });

  final String id;
  final String title;
  final bool isUnlocked;
  final List<QuestionEntity> questions;
  final String topicId;
  final String topicLabel;
  final SkillTrack skillTrack;
  final int xpReward;
  final int estimatedMinutes;

  @override
  List<Object?> get props => [
        id,
        title,
        isUnlocked,
        questions,
        topicId,
        topicLabel,
        skillTrack,
        xpReward,
        estimatedMinutes,
      ];

  LessonEntity copyWith({
    String? id,
    String? title,
    bool? isUnlocked,
    List<QuestionEntity>? questions,
    String? topicId,
    String? topicLabel,
    SkillTrack? skillTrack,
    int? xpReward,
    int? estimatedMinutes,
  }) {
    return LessonEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      questions: questions ?? this.questions,
      topicId: topicId ?? this.topicId,
      topicLabel: topicLabel ?? this.topicLabel,
      skillTrack: skillTrack ?? this.skillTrack,
      xpReward: xpReward ?? this.xpReward,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
    );
  }
}
