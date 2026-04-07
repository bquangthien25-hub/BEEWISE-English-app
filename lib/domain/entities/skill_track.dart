/// Lộ trình kỹ năng (kiểu Duolingo — tách Từ vựng / Ngữ pháp / Nghe / Đọc).
enum SkillTrack {
  vocabulary,
  grammar,
  listening,
  reading,
}

extension SkillTrackX on SkillTrack {
  String get labelVi {
    switch (this) {
      case SkillTrack.vocabulary:
        return 'Từ vựng';
      case SkillTrack.grammar:
        return 'Ngữ pháp';
      case SkillTrack.listening:
        return 'Nghe';
      case SkillTrack.reading:
        return 'Đọc';
    }
  }

  String get hintVi {
    switch (this) {
      case SkillTrack.vocabulary:
        return 'Ôn từ và ghép nghĩa';
      case SkillTrack.grammar:
        return 'Sắp xếp câu & cấu trúc';
      case SkillTrack.listening:
        return 'Ngữ cảnh (audio sắp có)';
      case SkillTrack.reading:
        return 'Đọc hiểu & suy luận';
    }
  }

}

SkillTrack? parseSkillTrack(String? raw) {
  if (raw == null) return null;
  for (final v in SkillTrack.values) {
    if (v.name == raw) return v;
  }
  return null;
}
