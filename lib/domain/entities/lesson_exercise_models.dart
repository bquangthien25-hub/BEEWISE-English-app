import 'question_entity.dart';
import 'question_type.dart';

/// Mô hình từ vựng — chọn biểu tượng (emoji) đúng.
class VocabularyImageExercise {
  const VocabularyImageExercise({
    required this.prompt,
    required this.optionEmojis,
    required this.correctIndex,
  });

  final String prompt;
  final List<String> optionEmojis;
  final int correctIndex;

  factory VocabularyImageExercise.fromQuestion(QuestionEntity q) {
    if (q.type != QuestionType.vocabularyImage) {
      throw ArgumentError('Không phải vocabularyImage');
    }
    final emojis = q.imageOptionEmojis ?? const [];
    final idx = q.correctImageIndex ?? 0;
    return VocabularyImageExercise(
      prompt: q.prompt,
      optionEmojis: emojis,
      correctIndex: idx.clamp(0, emojis.isEmpty ? 0 : emojis.length - 1),
    );
  }
}

/// Mô hình từ vựng — nối / sắp xếp cột tiếng Việt khớp với tiếng Anh (cùng chỉ số).
class VocabularyMatchExercise {
  const VocabularyMatchExercise({
    required this.englishTerms,
    required this.correctVietnameseOrder,
  });

  final List<String> englishTerms;
  /// Thứ tự đúng của tiếng Việt (song song với [englishTerms]).
  final List<String> correctVietnameseOrder;

  factory VocabularyMatchExercise.fromQuestion(QuestionEntity q) {
    if (q.type != QuestionType.vocabularyMatch) {
      throw ArgumentError('Không phải vocabularyMatch');
    }
    final en = q.matchEnglish ?? const [];
    final vi = q.matchVietnamese ?? const [];
    return VocabularyMatchExercise(
      englishTerms: List<String>.from(en),
      correctVietnameseOrder: List<String>.from(vi),
    );
  }
}

/// Ngữ pháp — sắp xếp từ thành câu.
class GrammarOrderExercise {
  const GrammarOrderExercise({
    required this.shuffledWords,
    required this.correctSentence,
  });

  final List<String> shuffledWords;
  final String correctSentence;

  factory GrammarOrderExercise.fromQuestion(QuestionEntity q) {
    if (q.type != QuestionType.grammarOrder) {
      throw ArgumentError('Không phải grammarOrder');
    }
    return GrammarOrderExercise(
      shuffledWords: List<String>.from(q.wordBank ?? const []),
      correctSentence: q.correctSentence ?? '',
    );
  }
}

/// Đọc hiểu — đoạn văn + trắc nghiệm.
class ReadingExercise {
  const ReadingExercise({
    required this.passage,
    required this.question,
    required this.choices,
    required this.correctIndex,
  });

  final String passage;
  final String question;
  final List<String> choices;
  final int correctIndex;

  factory ReadingExercise.fromQuestion(QuestionEntity q) {
    if (q.type != QuestionType.readingComprehension) {
      throw ArgumentError('Không phải readingComprehension');
    }
    final choices = q.readingChoices ?? const [];
    final idx = q.readingCorrectIndex ?? 0;
    return ReadingExercise(
      passage: q.passage ?? '',
      question: q.prompt,
      choices: List<String>.from(choices),
      correctIndex: idx.clamp(0, choices.isEmpty ? 0 : choices.length - 1),
    );
  }
}

/// Viết — dịch Việt → Anh.
class WritingExercise {
  const WritingExercise({
    required this.vietnamesePrompt,
    required this.acceptedEnglishAnswers,
  });

  final String vietnamesePrompt;
  final List<String> acceptedEnglishAnswers;

  factory WritingExercise.fromQuestion(QuestionEntity q) {
    if (q.type != QuestionType.writingTranslation) {
      throw ArgumentError('Không phải writingTranslation');
    }
    return WritingExercise(
      vietnamesePrompt: q.vietnamesePrompt ?? '',
      acceptedEnglishAnswers: List<String>.from(q.acceptedEnglishAnswers ?? const []),
    );
  }
}
