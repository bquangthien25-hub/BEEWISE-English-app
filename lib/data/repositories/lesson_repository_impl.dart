import '../../core/error/exceptions.dart';
import '../../core/error/failure.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/lesson_entity.dart';
import '../../domain/entities/question_entity.dart';
import '../../domain/entities/question_type.dart';
import '../../domain/entities/skill_track.dart';
import '../../domain/repositories/lesson_repository.dart';
import '../datasources/lesson_remote_data_source.dart';
import '../datasources/local_lesson_data_source.dart';
import '../models/lesson_model.dart';
import '../user_profile_store.dart';

class LessonRepositoryImpl implements LessonRepository {
  LessonRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
    required this.profileStore,
  });

  final LessonRemoteDataSource remoteDataSource;
  final LocalLessonDataSource localDataSource;
  final NetworkInfo networkInfo;
  final UserProfileStore profileStore;

  Future<List<LessonModel>> _fetchOrGetCached() async {
    if (await networkInfo.isConnected) {
      try {
        final models = await remoteDataSource.fetchLessons();
        await localDataSource.cacheLessons(models);
        return models;
      } catch (_) {
        final cached = await localDataSource.getCachedLessons();
        if (cached.isNotEmpty) return cached;
        rethrow;
      }
    } else {
      final cached = await localDataSource.getCachedLessons();
      if (cached.isNotEmpty) return cached;
      throw const NetworkFailure();
    }
  }



  /// Mỗi bài trong catalog có đủ loại câu; chỉ giữ câu đúng [SkillTrack] để không lẫn (vd. Từ vựng không có Đọc).
  static List<QuestionEntity> _questionsForSkillTrack(
    SkillTrack track,
    List<QuestionEntity> all,
  ) {
    bool isVocab(QuestionEntity q) =>
        q.type == QuestionType.vocabularyImage || q.type == QuestionType.vocabularyMatch;
    bool isGrammar(QuestionEntity q) => q.type == QuestionType.grammarOrder;
    bool isReading(QuestionEntity q) => q.type == QuestionType.readingComprehension;

    switch (track) {
      case SkillTrack.vocabulary:
        return all.where(isVocab).toList();
      case SkillTrack.grammar:
        return all.where(isGrammar).toList();
      case SkillTrack.reading:
        return all.where(isReading).toList();
      case SkillTrack.listening:
        // Chưa có audio: ghép ghép từ + sắp câu làm bài “nghe / nhận diện”.
        return all.where((q) => isVocab(q) || isGrammar(q)).toList();
    }
  }

  LessonModel _withSkillQuestions(LessonModel m) {
    final qs = _questionsForSkillTrack(m.skillTrack, m.questions);
    if (qs.isEmpty) return m;
    return m.copyWith(questions: qs);
  }

  List<LessonModel> _applyUnlock(List<LessonModel> models) {
    final ids = models.map((e) => e.id).toList();
    final completed = profileStore.current?.completedLessonIds ?? const <String>[];
    return models.asMap().entries.map((e) {
      final i = e.key;
      final m = e.value;
      final unlocked = i == 0 || (i > 0 && completed.contains(ids[i - 1]));
      return m.copyWith(isUnlocked: unlocked);
    }).toList();
  }

  @override
  Future<List<LessonEntity>> getLessons() async {
    try {
      final models = await _fetchOrGetCached();
      final scoped = models.map(_withSkillQuestions).toList();
      return _applyUnlock(scoped).map((m) => m.toEntity()).toList();
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<LessonEntity?> getLessonById(String id) async {
    try {
      final all = await _fetchOrGetCached();
      final scoped = all.map(_withSkillQuestions).toList();
      final adjusted = _applyUnlock(scoped);
      return adjusted.firstWhere((l) => l.id == id).toEntity();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<LessonEntity>> getPracticeLessons({
    required bool vocabularyOnly,
    required bool readingOnly,
  }) async {
    try {
      final all = await _fetchOrGetCached();
      if (vocabularyOnly && readingOnly) {
        return const [];
      }
      final out = <LessonEntity>[];

      for (final l in all) {
        if (vocabularyOnly) {
          final qs = l.questions
              .where(
                (q) =>
                    q.type == QuestionType.vocabularyImage ||
                    q.type == QuestionType.vocabularyMatch,
              )
              .toList();
          if (qs.isEmpty) continue;
          out.add(
            l
                .copyWith(
                  id: 'practice_vocab_${l.id}',
                  title: '${l.title} · Ôn từ vựng',
                  questions: qs,
                  isUnlocked: true,
                  skillTrack: SkillTrack.vocabulary,
                )
                .toEntity(),
          );
        } else if (readingOnly) {
          final qs =
              l.questions.where((q) => q.type == QuestionType.readingComprehension).toList();
          if (qs.isEmpty) continue;
          out.add(
            l
                .copyWith(
                  id: 'practice_read_${l.id}',
                  title: '${l.title} · Luyện đọc',
                  questions: qs,
                  isUnlocked: true,
                  skillTrack: SkillTrack.reading,
                )
                .toEntity(),
          );
        }
      }
      return out;
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }
}
