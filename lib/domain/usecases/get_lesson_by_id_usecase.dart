import '../entities/lesson_entity.dart';
import '../repositories/lesson_repository.dart';

class GetLessonByIdUseCase {
  GetLessonByIdUseCase(this._repository);

  final LessonRepository _repository;

  Future<LessonEntity?> call(String id) => _repository.getLessonById(id);
}
