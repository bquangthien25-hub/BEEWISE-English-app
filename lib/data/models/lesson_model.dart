import '../../domain/entities/lesson_entity.dart';
import '../../domain/entities/question_entity.dart';
import '../../domain/entities/skill_track.dart';
import 'question_model.dart';

class LessonModel extends LessonEntity {
  const LessonModel({
    required super.id,
    required super.title,
    required super.isUnlocked,
    required super.questions,
    required super.topicId,
    required super.topicLabel,
    required super.skillTrack,
    super.xpReward = 20,
    super.estimatedMinutes = 5,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    final rawQuestions = json['questions'] as List<dynamic>? ?? const [];
    final track = parseSkillTrack(json['skillTrack'] as String?) ?? SkillTrack.vocabulary;
    return LessonModel(
      id: json['id'] as String,
      title: json['title'] as String,
      isUnlocked: json['isUnlocked'] as bool? ?? false,
      topicId: json['topicId'] as String? ?? 'general',
      topicLabel: json['topicLabel'] as String? ?? '',
      skillTrack: track,
      xpReward: (json['xpReward'] as num?)?.toInt() ?? 20,
      estimatedMinutes: (json['estimatedMinutes'] as num?)?.toInt() ?? 5,
      questions: rawQuestions
          .map((e) => QuestionModel.fromJson(e as Map<String, dynamic>).toEntity())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'isUnlocked': isUnlocked,
        'topicId': topicId,
        'topicLabel': topicLabel,
        'skillTrack': skillTrack.name,
        'xpReward': xpReward,
        'estimatedMinutes': estimatedMinutes,
        'questions': questions
            .map((q) => QuestionModel(
                  id: q.id,
                  type: q.type,
                  instruction: q.instruction,
                  prompt: q.prompt,
                  imageOptionEmojis: q.imageOptionEmojis,
                  correctImageIndex: q.correctImageIndex,
                  matchEnglish: q.matchEnglish,
                  matchVietnamese: q.matchVietnamese,
                  wordBank: q.wordBank,
                  correctSentence: q.correctSentence,
                  passage: q.passage,
                  readingChoices: q.readingChoices,
                  readingCorrectIndex: q.readingCorrectIndex,
                  vietnamesePrompt: q.vietnamesePrompt,
                  acceptedEnglishAnswers: q.acceptedEnglishAnswers,
                ).toJson())
            .toList(),
      };

  LessonEntity toEntity() => LessonEntity(
        id: id,
        title: title,
        isUnlocked: isUnlocked,
        questions: List<QuestionEntity>.from(questions),
        topicId: topicId,
        topicLabel: topicLabel,
        skillTrack: skillTrack,
        xpReward: xpReward,
        estimatedMinutes: estimatedMinutes,
      );

  @override
  LessonModel copyWith({
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
    return LessonModel(
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
