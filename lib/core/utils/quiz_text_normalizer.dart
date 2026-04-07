/// Chuẩn hóa để so sánh câu trả lời tiếng Anh (viết, sắp xếp từ).
abstract final class QuizTextNormalizer {
  static String normalizeSentence(String raw) {
    return raw
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r"[^\w\s']"), '');
  }

  static bool matchesAnyAccepted(String userInput, List<String> accepted) {
    final u = normalizeSentence(userInput);
    if (u.isEmpty) return false;
    for (final a in accepted) {
      if (normalizeSentence(a) == u) return true;
    }
    return false;
  }
}
