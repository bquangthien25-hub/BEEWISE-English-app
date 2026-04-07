import 'dart:async';

import '../models/lesson_model.dart';
import 'lesson_course_mock.dart';

abstract class LessonRemoteDataSource {
  Future<List<LessonModel>> fetchLessons();

  Future<LessonModel?> getLessonById(String id);
}

class LessonRemoteDataSourceImpl implements LessonRemoteDataSource {
  LessonRemoteDataSourceImpl() : _catalog = buildLessonCatalog();

  final List<LessonModel> _catalog;

  @override
  Future<List<LessonModel>> fetchLessons() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return List<LessonModel>.from(_catalog);
  }

  @override
  Future<LessonModel?> getLessonById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    try {
      return _catalog.firstWhere((l) => l.id == id);
    } catch (_) {
      return null;
    }
  }

  List<LessonModel> get rawCatalog => List<LessonModel>.unmodifiable(_catalog);
}
