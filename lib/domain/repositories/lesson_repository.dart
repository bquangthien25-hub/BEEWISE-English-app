import '../entities/lesson_entity.dart';

abstract class LessonRepository {
  Future<List<LessonEntity>> getLessons();

  Future<LessonEntity?> getLessonById(String id);

  /// Bài luyện từ vựng / đọc (lọc theo chủ đề hoặc loại câu hỏi).
  Future<List<LessonEntity>> getPracticeLessons({
    required bool vocabularyOnly,
    required bool readingOnly,
  });
}
