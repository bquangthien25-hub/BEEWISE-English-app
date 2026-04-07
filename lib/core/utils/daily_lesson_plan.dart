import '../../domain/entities/lesson_entity.dart';
import '../../domain/entities/skill_track.dart';

/// Khóa ngày ổn định (đồng bộ với [UserEntity.dailyLessonCompletions]).
String calendarDayKey(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

DateTime? parseCalendarDayKey(String key) {
  final p = key.split('-');
  if (p.length != 3) return null;
  final y = int.tryParse(p[0]);
  final m = int.tryParse(p[1]);
  final d = int.tryParse(p[2]);
  if (y == null || m == null || d == null) return null;
  return DateTime(y, m, d);
}

/// Hiển thị: `15/3/2025`.
String formatDayLabelVi(String dayKey) {
  final dt = parseCalendarDayKey(dayKey);
  if (dt == null) return dayKey;
  return '${dt.day}/${dt.month}/${dt.year}';
}

/// Các ngày có ít nhất một bài; mới nhất trước.
List<String> sortedStudyDayKeys(Map<String, List<String>> map) {
  final keys = map.entries.where((e) => e.value.isNotEmpty).map((e) => e.key).toList();
  keys.sort((a, b) {
    final da = parseCalendarDayKey(a);
    final db = parseCalendarDayKey(b);
    if (da == null || db == null) return 0;
    return db.compareTo(da);
  });
  return keys;
}

/// Mỗi ngày gợi ý một bài mỗi [SkillTrack] (ổn định theo ngày + chỉ số track).
List<String> dailySuggestedLessonIds(List<LessonEntity> lessons, DateTime day) {
  final result = <String>[];
  for (var i = 0; i < SkillTrack.values.length; i++) {
    final track = SkillTrack.values[i];
    final pool = lessons.where((l) => l.skillTrack == track && l.isUnlocked).toList();
    if (pool.isEmpty) continue;
    final dayOfYear = day.difference(DateTime(day.year, 1, 1)).inDays;
    final salt = day.year * 10000 + day.month * 100 + day.day + dayOfYear * 3 + i * 17;
    final idx = salt.abs() % pool.length;
    result.add(pool[idx].id);
  }
  return result;
}
