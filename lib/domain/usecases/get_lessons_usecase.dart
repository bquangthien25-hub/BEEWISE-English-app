import '../entities/lesson_entity.dart';
import '../repositories/lesson_repository.dart';

class GetLessonsUseCase {
  GetLessonsUseCase(this._repository);

  final LessonRepository _repository;

  Future<List<LessonEntity>> call() => _repository.getLessons();
}
