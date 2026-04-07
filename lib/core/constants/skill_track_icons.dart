import 'package:flutter/material.dart';

import '../../domain/entities/skill_track.dart';

IconData skillTrackIcon(SkillTrack t) {
  switch (t) {
    case SkillTrack.vocabulary:
      return Icons.translate_rounded;
    case SkillTrack.grammar:
      return Icons.rule_folder_rounded;
    case SkillTrack.listening:
      return Icons.headphones_rounded;
    case SkillTrack.reading:
      return Icons.menu_book_rounded;
  }
}
