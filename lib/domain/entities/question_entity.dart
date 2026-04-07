import 'package:equatable/equatable.dart';

import 'question_type.dart';

class QuestionEntity extends Equatable {
  const QuestionEntity({
    required this.id,
    required this.type,
    required this.instruction,
    this.prompt = '',
    this.imageOptionEmojis,
    this.correctImageIndex,
    this.matchEnglish,
    this.matchVietnamese,
    this.wordBank,
    this.correctSentence,
    this.passage,
    this.readingChoices,
    this.readingCorrectIndex,
    this.vietnamesePrompt,
    this.acceptedEnglishAnswers,
  });

  final String id;
  final QuestionType type;
  /// Hướng dẫn ngắn (tiêu đề bài).
  final String instruction;
  final String prompt;

  /// vocabularyImage: chọn 1 trong các emoji / nhãn.
  final List<String>? imageOptionEmojis;
  final int? correctImageIndex;

  /// vocabularyMatch: cùng độ dài, ghép theo chỉ số.
  final List<String>? matchEnglish;
  final List<String>? matchVietnamese;

  /// grammarOrder: xáo trộn wordBank, đáp án = correctSentence (chuẩn hóa khi so).
  final List<String>? wordBank;
  final String? correctSentence;

  /// readingComprehension
  final String? passage;
  final List<String>? readingChoices;
  final int? readingCorrectIndex;

  /// writingTranslation
  final String? vietnamesePrompt;
  final List<String>? acceptedEnglishAnswers;

  @override
  List<Object?> get props => [
        id,
        type,
        instruction,
        prompt,
        imageOptionEmojis,
        correctImageIndex,
        matchEnglish,
        matchVietnamese,
        wordBank,
        correctSentence,
        passage,
        readingChoices,
        readingCorrectIndex,
        vietnamesePrompt,
        acceptedEnglishAnswers,
      ];
}
