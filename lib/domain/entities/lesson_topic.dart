/// 10 chủ đề học (mock catalog).
enum LessonTopicId {
  travel,
  food,
  work,
  technology,
  health,
  education,
  sports,
  nature,
  shopping,
  entertainment,
}

extension LessonTopicIdX on LessonTopicId {
  String get labelVi {
    switch (this) {
      case LessonTopicId.travel:
        return 'Du lịch';
      case LessonTopicId.food:
        return 'Ẩm thực';
      case LessonTopicId.work:
        return 'Công việc';
      case LessonTopicId.technology:
        return 'Công nghệ';
      case LessonTopicId.health:
        return 'Sức khỏe';
      case LessonTopicId.education:
        return 'Giáo dục';
      case LessonTopicId.sports:
        return 'Thể thao';
      case LessonTopicId.nature:
        return 'Thiên nhiên';
      case LessonTopicId.shopping:
        return 'Mua sắm';
      case LessonTopicId.entertainment:
        return 'Giải trí';
    }
  }

  String get id => name;
}
