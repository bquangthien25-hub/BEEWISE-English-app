import 'dart:math' show Random;

import '../../domain/entities/lesson_topic.dart';
import '../../domain/entities/question_type.dart';
import '../../domain/entities/skill_track.dart';
import '../models/lesson_model.dart';
import '../models/question_model.dart';

/// Bốn emoji gợi ý + chỉ số đúng (0–3), phù hợp nghĩa với từ [noun].
class _VocabImagePair {
  const _VocabImagePair({required this.emojis, required this.correctIndex});

  final List<String> emojis;
  final int correctIndex;
}

_VocabImagePair _vocabImageForNoun(String noun) {
  switch (noun.toLowerCase()) {
    // Du lịch
    case 'ticket':
      return const _VocabImagePair(
        emojis: ['🎫', '🎯', '🎪', '🎬'],
        correctIndex: 0,
      );
    case 'hotel':
      return const _VocabImagePair(
        emojis: ['🏨', '🏠', '⛺', '🛖'],
        correctIndex: 0,
      );
    case 'passport':
      return const _VocabImagePair(
        emojis: ['🛂', '📕', '🗺️', '🌍'],
        correctIndex: 0,
      );
    case 'airport':
      return const _VocabImagePair(
        emojis: ['🛫', '🚗', '🚂', '⛵'],
        correctIndex: 0,
      );
    case 'luggage':
      return const _VocabImagePair(
        emojis: ['🧳', '👝', '🎒', '☂️'],
        correctIndex: 0,
      );
    // Ẩm thực
    case 'menu':
      return const _VocabImagePair(
        emojis: ['📋', '🍕', '🍽️', '🥤'],
        correctIndex: 0,
      );
    case 'order':
      return const _VocabImagePair(
        emojis: ['🧾', '📞', '🍽️', '🚫'],
        correctIndex: 0,
      );
    case 'delicious':
      return const _VocabImagePair(
        emojis: ['😋', '😖', '🌶️', '🍽️'],
        correctIndex: 0,
      );
    case 'recipe':
      return const _VocabImagePair(
        emojis: ['📖', '📰', '📄', '🗞️'],
        correctIndex: 0,
      );
    case 'kitchen':
      return const _VocabImagePair(
        emojis: ['🍳', '🛏️', '🚿', '🛋️'],
        correctIndex: 0,
      );
    // Công việc
    case 'meeting':
      return const _VocabImagePair(
        emojis: ['🤝', '📵', '🎮', '🛌'],
        correctIndex: 0,
      );
    case 'deadline':
      return const _VocabImagePair(
        emojis: ['⏰', '📅', '🎉', '♾️'],
        correctIndex: 0,
      );
    case 'email':
      return const _VocabImagePair(
        emojis: ['✉️', '📮', '📟', '📠'],
        correctIndex: 0,
      );
    case 'team':
      return const _VocabImagePair(
        emojis: ['👥', '🧍', '🐕', '📦'],
        correctIndex: 0,
      );
    case 'project':
      return const _VocabImagePair(
        emojis: ['📊', '📁', '🎲', '🧸'],
        correctIndex: 0,
      );
    // Công nghệ
    case 'computer':
      return const _VocabImagePair(
        emojis: ['💻', '🖨️', '📻', '📺'],
        correctIndex: 0,
      );
    case 'software':
      return const _VocabImagePair(
        emojis: ['💾', '🧱', '🪵', '🪨'],
        correctIndex: 0,
      );
    case 'password':
      return const _VocabImagePair(
        emojis: ['🔐', '🔓', '🗝️', '❌'],
        correctIndex: 0,
      );
    case 'screen':
      return const _VocabImagePair(
        emojis: ['🖥️', '📟', '📠', '☎️'],
        correctIndex: 0,
      );
    case 'update':
      return const _VocabImagePair(
        emojis: ['🔄', '⏸️', '⏹️', '⏏️'],
        correctIndex: 0,
      );
    // Sức khỏe
    case 'doctor':
      return const _VocabImagePair(
        emojis: ['🩺', '💉', '🧪', '🧸'],
        correctIndex: 0,
      );
    case 'exercise':
      return const _VocabImagePair(
        emojis: ['🏃', '🛋️', '🍕', '📺'],
        correctIndex: 0,
      );
    case 'sleep':
      return const _VocabImagePair(
        emojis: ['😴', '🏃', '☕', '📣'],
        correctIndex: 0,
      );
    case 'water':
      return const _VocabImagePair(
        emojis: ['💧', '☕', '🍷', '🧃'],
        correctIndex: 0,
      );
    case 'medicine':
      return const _VocabImagePair(
        emojis: ['💊', '🍬', '🍫', '🧁'],
        correctIndex: 0,
      );
    // Giáo dục
    case 'teacher':
      return const _VocabImagePair(
        emojis: ['👩‍🏫', '🧑‍🍳', '🧑‍🚀', '🧑‍🌾'],
        correctIndex: 0,
      );
    case 'homework':
      return const _VocabImagePair(
        emojis: ['📝', '🎮', '📺', '🍿'],
        correctIndex: 0,
      );
    case 'exam':
      return const _VocabImagePair(
        emojis: ['📝', '🎉', '🎁', '🎈'],
        correctIndex: 0,
      );
    case 'classroom':
      return const _VocabImagePair(
        emojis: ['🏫', '🏥', '🏭', '🏰'],
        correctIndex: 0,
      );
    case 'student':
      return const _VocabImagePair(
        emojis: ['🎓', '👔', '🧑‍💼', '🧑‍🔧'],
        correctIndex: 0,
      );
    // Thể thao
    case 'game':
      return const _VocabImagePair(
        emojis: ['⚽', '🎻', '🎹', '🎨'],
        correctIndex: 0,
      );
    case 'coach':
      return const _VocabImagePair(
        emojis: ['🎽', '🧑‍🍳', '🧑‍💻', '🧑‍🎤'],
        correctIndex: 0,
      );
    case 'ball':
      return const _VocabImagePair(
        emojis: ['⚽', '🎈', '🎀', '📀'],
        correctIndex: 0,
      );
    case 'training':
      return const _VocabImagePair(
        emojis: ['🏋️', '🛌', '🍰', '📚'],
        correctIndex: 0,
      );
    // Thiên nhiên
    case 'forest':
      return const _VocabImagePair(
        emojis: ['🌲', '🏢', '🚗', '📱'],
        correctIndex: 0,
      );
    case 'river':
      return const _VocabImagePair(
        emojis: ['🌊', '🏜️', '🌵', '🦀'],
        correctIndex: 0,
      );
    case 'mountain':
      return const _VocabImagePair(
        emojis: ['⛰️', '🌊', '🏝️', '🎢'],
        correctIndex: 0,
      );
    case 'rain':
      return const _VocabImagePair(
        emojis: ['🌧️', '☀️', '🌈', '❄️'],
        correctIndex: 0,
      );
    case 'animal':
      return const _VocabImagePair(
        emojis: ['🐾', '🪨', '🌵', '🧱'],
        correctIndex: 0,
      );
    // Mua sắm
    case 'price':
      return const _VocabImagePair(
        emojis: ['💲', '🎁', '🎀', '📎'],
        correctIndex: 0,
      );
    case 'discount':
      return const _VocabImagePair(
        emojis: ['🏷️', '📈', '📉', '🧾'],
        correctIndex: 0,
      );
    case 'cart':
      return const _VocabImagePair(
        emojis: ['🛒', '🛏️', '🪑', '🚪'],
        correctIndex: 0,
      );
    case 'store':
      return const _VocabImagePair(
        emojis: ['🏬', '🏠', '🏥', '🏭'],
        correctIndex: 0,
      );
    case 'receipt':
      return const _VocabImagePair(
        emojis: ['🧾', '📜', '📰', '🗞️'],
        correctIndex: 0,
      );
    // Giải trí
    case 'movie':
      return const _VocabImagePair(
        emojis: ['🎬', '🎪', '🎭', '🎯'],
        correctIndex: 0,
      );
    case 'music':
      return const _VocabImagePair(
        emojis: ['🎵', '🔇', '📵', '📻'],
        correctIndex: 0,
      );
    case 'concert':
      return const _VocabImagePair(
        emojis: ['🎤', '📻', '📟', '📠'],
        correctIndex: 0,
      );
    case 'stage':
      return const _VocabImagePair(
        emojis: ['🎭', '🎪', '🎯', '🎰'],
        correctIndex: 0,
      );
    default:
      return const _VocabImagePair(
        emojis: ['❓', '❔', '⁉️', '‼️'],
        correctIndex: 0,
      );
  }
}

/// Xáo trộn thứ tự emoji nhưng giữ đúng chỉ số đáp án (seed cố định theo [lessonId]).
(List<String> emojis, int correctIndex) _shuffledVocabImages(
  _VocabImagePair pair,
  String lessonId,
) {
  final list = List<String>.from(pair.emojis);
  final correctEmoji = list[pair.correctIndex];
  final rng = Random('${lessonId}_vimg'.hashCode);
  list.shuffle(rng);
  final idx = list.indexOf(correctEmoji);
  return (list, idx);
}

/// Đúng **10 bài** (10 chủ đề), mỗi bài có **4 kỹ năng** → 10 × 4 = 40 [LessonModel].
/// Cùng số bài (1…10) trên mọi hàng kỹ năng; tiêu dạng `Bài n: <chủ đề>`.
/// Mỗi bài 5 câu gốc; [LessonRepositoryImpl] lọc câu theo kỹ năng khi hiển thị.
List<LessonModel> buildLessonCatalog() {
  final topics = <(LessonTopicId, String, _TopicBundle)>[
    (
      LessonTopicId.travel,
      LessonTopicId.travel.labelVi,
      _TopicBundle(
        nouns: ['ticket', 'hotel', 'passport', 'airport', 'luggage'],
        verbs: ['book', 'fly', 'visit', 'pack'],
        lesson1: _LessonBlock(
          sampleSentence: 'i need a ticket to paris',
          passage:
              'Many travelers book hotels early to save money. A valid passport is required at the airport security gate. '
              'Remember to label your luggage clearly so it is easy to find at baggage claim.',
          mcq: 'What is required at the airport security gate?',
          choices: [
            'Only a ticket',
            'A valid passport',
            'A hotel key',
            'A map only',
          ],
          mcqIndex: 1,
          viWrite: 'Tôi cần đặt vé máy bay.',
          enWrite: ['i need to book a flight', 'i need to book flight'],
        ),
      ),
    ),
    (
      LessonTopicId.food,
      LessonTopicId.food.labelVi,
      _TopicBundle(
        nouns: ['menu', 'order', 'delicious', 'recipe', 'kitchen'],
        verbs: ['cook', 'taste', 'serve', 'eat'],
        lesson1: _LessonBlock(
          sampleSentence: 'the soup tastes delicious today',
          passage:
              'Chefs follow recipes carefully in a busy kitchen. Customers read the menu before they order drinks or main courses. '
              'Fresh ingredients often make the dish taste more delicious than frozen food.',
          mcq: 'What do customers read before ordering?',
          choices: ['The receipt only', 'The menu', 'A novel', 'A map'],
          mcqIndex: 1,
          viWrite: 'Món ăn rất ngon.',
          enWrite: ['the food is delicious', 'the food is very delicious'],
        ),
      ),
    ),
    (
      LessonTopicId.work,
      LessonTopicId.work.labelVi,
      _TopicBundle(
        nouns: ['meeting', 'deadline', 'email', 'team', 'project'],
        verbs: ['send', 'plan', 'finish', 'join'],
        lesson1: _LessonBlock(
          sampleSentence: 'we have a meeting at nine am',
          passage:
              'Teams plan projects and share updates by email instead of long phone calls. Deadlines help everyone finish work on time and avoid last-minute stress. '
              'If you join a video call, mute your microphone when you are not speaking.',
          mcq: 'How do teams share updates in the passage?',
          choices: ['Only by phone', 'By email', 'By mail only', 'Never'],
          mcqIndex: 1,
          viWrite: 'Tôi có một cuộc họp.',
          enWrite: ['i have a meeting', 'i have meeting'],
        ),
      ),
    ),
    (
      LessonTopicId.technology,
      LessonTopicId.technology.labelVi,
      _TopicBundle(
        nouns: ['computer', 'software', 'password', 'screen', 'update'],
        verbs: ['install', 'click', 'save', 'download'],
        lesson1: _LessonBlock(
          sampleSentence: 'please save your password safely',
          passage:
              'Software updates can fix bugs and improve security on your computer. Users should choose a strong password for each account and avoid using the same one everywhere. '
              'If the screen freezes, wait a minute before you click restart.',
          mcq: 'What can software updates fix?',
          choices: ['Hardware only', 'Bugs', 'Weather', 'Food'],
          mcqIndex: 1,
          viWrite: 'Hãy tải xuống bản cập nhật.',
          enWrite: ['please download the update', 'download the update'],
        ),
      ),
    ),
    (
      LessonTopicId.health,
      LessonTopicId.health.labelVi,
      _TopicBundle(
        nouns: ['doctor', 'exercise', 'sleep', 'water', 'medicine'],
        verbs: ['rest', 'drink', 'walk', 'feel'],
        lesson1: _LessonBlock(
          sampleSentence: 'drink water every day for health',
          passage:
              'Doctors say sleep and exercise matter for long-term health. Drink enough water during the day and rest when you feel tired after work. '
              'If you need medicine, follow the instructions on the label carefully.',
          mcq: 'What should you drink enough of?',
          choices: ['Coffee only', 'Water', 'Soda only', 'Juice only'],
          mcqIndex: 1,
          viWrite: 'Tôi đi bộ mỗi ngày.',
          enWrite: ['i walk every day', 'i go walking every day'],
        ),
      ),
    ),
    (
      LessonTopicId.education,
      LessonTopicId.education.labelVi,
      _TopicBundle(
        nouns: ['teacher', 'homework', 'exam', 'classroom', 'student'],
        verbs: ['study', 'read', 'learn', 'ask'],
        lesson1: _LessonBlock(
          sampleSentence: 'students ask questions in the classroom',
          passage:
              'Teachers give homework before exams so students can revise key ideas. Students read books and learn new words every week to build confidence. '
              'In a quiet classroom, it is easier to focus on difficult grammar rules.',
          mcq: 'Who gives homework?',
          choices: ['Parents only', 'Teachers', 'Drivers', 'Chefs'],
          mcqIndex: 1,
          viWrite: 'Tôi làm bài tập về nhà.',
          enWrite: ['i do my homework', 'i do homework'],
        ),
      ),
    ),
    (
      LessonTopicId.sports,
      LessonTopicId.sports.labelVi,
      _TopicBundle(
        nouns: ['team', 'game', 'coach', 'ball', 'training'],
        verbs: ['run', 'win', 'practice', 'score'],
        lesson1: _LessonBlock(
          sampleSentence: 'our team trains before every game',
          passage:
              'Athletes practice with a coach who corrects mistakes and builds teamwork. They run during training and try to score in each game with a calm mind. '
              'Remember to warm up before you touch the ball to avoid injury.',
          mcq: 'Who helps athletes during practice?',
          choices: ['A chef', 'A coach', 'A pilot', 'A farmer'],
          mcqIndex: 1,
          viWrite: 'Chúng tôi thắng trận đấu.',
          enWrite: ['we win the game', 'we won the game'],
        ),
      ),
    ),
    (
      LessonTopicId.nature,
      LessonTopicId.nature.labelVi,
      _TopicBundle(
        nouns: ['forest', 'river', 'mountain', 'rain', 'animal'],
        verbs: ['grow', 'flow', 'rain', 'protect'],
        lesson1: _LessonBlock(
          sampleSentence: 'the river flows through the forest',
          passage:
              'Rain helps plants grow near the river and keeps the soil soft. Many animals live in the forest and on the mountain, but some species are endangered. '
              'We should protect wild places for future generations.',
          mcq: 'Where do many animals live?',
          choices: [
            'In the office',
            'In the forest',
            'Under the desk',
            'In a car',
          ],
          mcqIndex: 1,
          viWrite: 'Trời đang mưa.',
          enWrite: ['it is raining', 'it is rain'],
        ),
      ),
    ),
    (
      LessonTopicId.shopping,
      LessonTopicId.shopping.labelVi,
      _TopicBundle(
        nouns: ['price', 'discount', 'cart', 'store', 'receipt'],
        verbs: ['buy', 'pay', 'compare', 'save'],
        lesson1: _LessonBlock(
          sampleSentence: 'i compare prices before i buy',
          passage:
              'Shoppers use a cart in the store and move items carefully from shelves. A receipt shows the price after any discount and helps if you need to return a product. '
              'If you pay by card, keep the receipt until the transaction appears on your bank app.',
          mcq: 'What shows the price after a discount?',
          choices: ['A map', 'A receipt', 'A ticket', 'A photo'],
          mcqIndex: 1,
          viWrite: 'Cái này giảm giá không?',
          enWrite: ['is this on discount', 'is there a discount'],
        ),
      ),
    ),
    (
      LessonTopicId.entertainment,
      LessonTopicId.entertainment.labelVi,
      _TopicBundle(
        nouns: ['movie', 'music', 'concert', 'ticket', 'stage'],
        verbs: ['watch', 'listen', 'sing', 'enjoy'],
        lesson1: _LessonBlock(
          sampleSentence: 'we watch a movie on friday night',
          passage:
              'Fans listen to music at a concert and sing along with the chorus. Many people buy a ticket to watch shows on stage and arrive early for good seats. '
              'Turn off your phone ringtone so others can enjoy the performance.',
          mcq: 'Where do fans listen to music?',
          choices: ['In a bank', 'At a concert', 'In a kitchen', 'On a bus'],
          mcqIndex: 1,
          viWrite: 'Tôi thích xem phim.',
          enWrite: ['i like watching movies', 'i like to watch movies'],
        ),
      ),
    ),
  ];

  final out = <LessonModel>[];
  var lessonNum = 0;

  for (final row in topics) {
    lessonNum++;
    final topicId = row.$1.id;
    final topicLabel = row.$2;
    final w = row.$3;

    final title = 'Bài $lessonNum: $topicLabel';
    final block = w.lesson1;
    final nounForImage = w.nouns[0];

    for (final track in SkillTrack.values) {
      final id = '${topicId}_b${lessonNum}_${track.name}';
      final vocabImg = _vocabImageForNoun(nounForImage);
      final (imageEmojis, correctImageIdx) = _shuffledVocabImages(vocabImg, id);

      final q1 = QuestionModel(
        id: '${id}_q1',
        type: QuestionType.vocabularyImage,
        instruction: 'Chọn biểu tượng gợi ý đúng nhất cho chủ đề bài:',
        prompt: nounForImage,
        imageOptionEmojis: imageEmojis,
        correctImageIndex: correctImageIdx,
      );

      final q2 = QuestionModel(
        id: '${id}_q2',
        type: QuestionType.vocabularyMatch,
        instruction:
            'Kéo thả để sắp xếp cột tiếng Việt khớp với từ tiếng Anh bên trái (thứ tự từ trên xuống).',
        matchEnglish: [w.nouns[0], w.nouns[1], w.verbs[0]],
        matchVietnamese: [
          _roughVi(w.nouns[0]),
          _roughVi(w.nouns[1]),
          _roughViVerb(w.verbs[0]),
        ],
      );

      final bank = List<String>.from(block.sampleSentence.split(' '))
        ..shuffle();
      final q3 = QuestionModel(
        id: '${id}_q3',
        type: QuestionType.grammarOrder,
        instruction: 'Sắp xếp các từ thành câu đúng:',
        wordBank: bank,
        correctSentence: block.sampleSentence,
      );

      final q4 = QuestionModel(
        id: '${id}_q4',
        type: QuestionType.readingComprehension,
        instruction: 'Đọc đoạn và chọn đáp án đúng:',
        passage: block.passage,
        prompt: block.mcq,
        readingChoices: block.choices,
        readingCorrectIndex: block.mcqIndex,
      );

      final q5 = QuestionModel(
        id: '${id}_q5',
        type: QuestionType.writingTranslation,
        instruction: 'Dịch sang tiếng Anh:',
        vietnamesePrompt: block.viWrite,
        acceptedEnglishAnswers: block.enWrite,
      );

      out.add(
        LessonModel(
          id: id,
          title: title,
          isUnlocked: false,
          topicId: topicId,
          topicLabel: topicLabel,
          skillTrack: track,
          xpReward: 25,
          estimatedMinutes: 8,
          questions: [q1, q2, q3, q4, q5],
        ),
      );
    }
  }

  return out;
}

class _TopicBundle {
  const _TopicBundle({
    required this.nouns,
    required this.verbs,
    required this.lesson1,
  });

  final List<String> nouns;
  final List<String> verbs;
  final _LessonBlock lesson1;
}

class _LessonBlock {
  const _LessonBlock({
    required this.sampleSentence,
    required this.passage,
    required this.mcq,
    required this.choices,
    required this.mcqIndex,
    required this.viWrite,
    required this.enWrite,
  });

  final String sampleSentence;
  final String passage;
  final String mcq;
  final List<String> choices;
  final int mcqIndex;
  final String viWrite;
  final List<String> enWrite;
}

String _roughVi(String en) {
  const map = {
    'ticket': 'vé',
    'hotel': 'khách sạn',
    'passport': 'hộ chiếu',
    'menu': 'thực đơn',
    'meeting': 'cuộc họp',
    'computer': 'máy tính',
    'doctor': 'bác sĩ',
    'teacher': 'giáo viên',
    'team': 'đội',
    'forest': 'rừng',
    'price': 'giá',
    'movie': 'phim',
    'airport': 'sân bay',
    'luggage': 'hành lý',
    'order': 'gọi món',
    'delicious': 'ngon',
    'recipe': 'công thức',
    'kitchen': 'bếp',
    'deadline': 'hạn chót',
    'email': 'email',
    'project': 'dự án',
    'software': 'phần mềm',
    'password': 'mật khẩu',
    'screen': 'màn hình',
    'update': 'cập nhật',
    'exercise': 'tập thể dục',
    'sleep': 'ngủ',
    'water': 'nước',
    'medicine': 'thuốc',
    'homework': 'bài tập',
    'exam': 'kỳ thi',
    'classroom': 'lớp học',
    'student': 'học sinh',
    'game': 'trận đấu',
    'coach': 'huấn luyện viên',
    'ball': 'quả bóng',
    'training': 'tập luyện',
    'river': 'dòng sông',
    'mountain': 'ngọn núi',
    'rain': 'mưa',
    'animal': 'động vật',
    'discount': 'giảm giá',
    'cart': 'xe đẩy',
    'store': 'cửa hàng',
    'receipt': 'hóa đơn',
    'music': 'âm nhạc',
    'concert': 'buổi hòa nhạc',
    'stage': 'sân khấu',
  };
  return map[en] ?? en;
}

String _roughViVerb(String en) {
  const map = {
    'book': 'đặt',
    'cook': 'nấu',
    'send': 'gửi',
    'install': 'cài',
    'drink': 'uống',
    'study': 'học',
    'run': 'chạy',
    'grow': 'mọc',
    'buy': 'mua',
    'watch': 'xem',
    'fly': 'bay',
    'visit': 'thăm',
    'pack': 'đóng gói',
    'taste': 'nếm',
    'serve': 'phục vụ',
    'eat': 'ăn',
    'plan': 'lên kế hoạch',
    'finish': 'hoàn thành',
    'join': 'tham gia',
    'click': 'nhấp',
    'save': 'lưu',
    'download': 'tải',
    'rest': 'nghỉ',
    'walk': 'đi bộ',
    'feel': 'cảm thấy',
    'read': 'đọc',
    'learn': 'học',
    'ask': 'hỏi',
    'win': 'thắng',
    'practice': 'luyện tập',
    'score': 'ghi bàn',
    'flow': 'chảy',
    'rain': 'mưa',
    'protect': 'bảo vệ',
    'pay': 'thanh toán',
    'compare': 'so sánh',
    'listen': 'nghe',
    'sing': 'hát',
    'enjoy': 'thưởng thức',
  };
  return map[en] ?? en;
}
