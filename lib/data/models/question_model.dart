import '../../domain/entities/question_entity.dart';
import '../../domain/entities/question_type.dart';

class QuestionModel extends QuestionEntity {
  const QuestionModel({
    required super.id,
    required super.type,
    required super.instruction,
    super.prompt = '',
    super.imageOptionEmojis,
    super.correctImageIndex,
    super.matchEnglish,
    super.matchVietnamese,
    super.wordBank,
    super.correctSentence,
    super.passage,
    super.readingChoices,
    super.readingCorrectIndex,
    super.vietnamesePrompt,
    super.acceptedEnglishAnswers,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] as String,
      type: _parseType(json['type'] as String),
      instruction: json['instruction'] as String? ?? '',
      prompt: json['prompt'] as String? ?? '',
      imageOptionEmojis: (json['imageOptionEmojis'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      correctImageIndex: (json['correctImageIndex'] as num?)?.toInt(),
      matchEnglish: (json['matchEnglish'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      matchVietnamese: (json['matchVietnamese'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      wordBank: (json['wordBank'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      correctSentence: json['correctSentence'] as String?,
      passage: json['passage'] as String?,
      readingChoices: (json['readingChoices'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      readingCorrectIndex: (json['readingCorrectIndex'] as num?)?.toInt(),
      vietnamesePrompt: json['vietnamesePrompt'] as String?,
      acceptedEnglishAnswers: (json['acceptedEnglishAnswers'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );
  }

  static QuestionType _parseType(String raw) {
    return QuestionType.values.firstWhere(
      (e) => e.name == raw,
      orElse: () => QuestionType.readingComprehension,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'instruction': instruction,
        'prompt': prompt,
        'imageOptionEmojis': imageOptionEmojis,
        'correctImageIndex': correctImageIndex,
        'matchEnglish': matchEnglish,
        'matchVietnamese': matchVietnamese,
        'wordBank': wordBank,
        'correctSentence': correctSentence,
        'passage': passage,
        'readingChoices': readingChoices,
        'readingCorrectIndex': readingCorrectIndex,
        'vietnamesePrompt': vietnamesePrompt,
        'acceptedEnglishAnswers': acceptedEnglishAnswers,
      };

  QuestionEntity toEntity() => QuestionEntity(
        id: id,
        type: type,
        instruction: instruction,
        prompt: prompt,
        imageOptionEmojis: imageOptionEmojis,
        correctImageIndex: correctImageIndex,
        matchEnglish: matchEnglish,
        matchVietnamese: matchVietnamese,
        wordBank: wordBank,
        correctSentence: correctSentence,
        passage: passage,
        readingChoices: readingChoices,
        readingCorrectIndex: readingCorrectIndex,
        vietnamesePrompt: vietnamesePrompt,
        acceptedEnglishAnswers: acceptedEnglishAnswers,
      );
}
