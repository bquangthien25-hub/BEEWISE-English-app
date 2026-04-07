import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/audio/app_sound_effects.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../domain/entities/lesson_exercise_models.dart';
import '../../../domain/entities/question_entity.dart';
import '../../../domain/entities/question_type.dart';
import '../../bloc/lesson_bloc.dart';
import '../../bloc/mission/mission_bloc.dart';
import '../../bloc/mission/mission_event.dart';
import '../../bloc/lesson_quiz/lesson_quiz_bloc.dart';
import '../../bloc/lesson_quiz/lesson_quiz_event.dart';
import '../../bloc/lesson_quiz/lesson_quiz_state.dart';

class LessonQuizPage extends StatelessWidget {
  const LessonQuizPage({super.key, required this.lessonId});

  final String lessonId;

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<LessonQuizBloc, LessonQuizState>(
          listenWhen: (p, c) => c is LessonQuizFinished,
          listener: (context, state) {
            if (state is LessonQuizFinished) {
              context.read<LessonBloc>().add(const LessonLoadRequested());
              context.read<MissionBloc>().add(const MissionRefreshRequested());
            }
          },
        ),
        BlocListener<LessonQuizBloc, LessonQuizState>(
          listenWhen: (p, c) {
            if (p is! LessonQuizPlaying || c is! LessonQuizPlaying) return false;
            return p.feedback == null && c.feedback != null;
          },
          listener: (context, state) {
            final s = state as LessonQuizPlaying;
            if (s.canGoNext) {
              AppSoundEffects.playQuizCorrect();
            } else {
              AppSoundEffects.playQuizIncorrect();
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text(AppStrings.lessonQuiz),
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          scrolledUnderElevation: 0,
        ),
        body: BlocBuilder<LessonQuizBloc, LessonQuizState>(
          builder: (context, state) {
            if (state is LessonQuizLoading || state is LessonQuizInitial) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }
            if (state is LessonQuizLoadFailure) {
              final tt = Theme.of(context).textTheme;
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.message, textAlign: TextAlign.center, style: tt.bodyLarge),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => context.pop(),
                      child: const Text('Quay lại'),
                    ),
                  ],
                ),
              );
            }
            if (state is LessonQuizFinished) {
              return _ResultPanel(
                correct: state.correctCount,
                total: state.totalQuestions,
                xp: state.xpEarned,
                onClose: () => context.pop(),
              );
            }
            if (state is LessonQuizPlaying) {
              return _PlayingBody(state: state);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _PlayingBody extends StatelessWidget {
  const _PlayingBody({required this.state});

  final LessonQuizPlaying state;

  String _typeLabel(QuestionType t) {
    switch (t) {
      case QuestionType.vocabularyImage:
      case QuestionType.vocabularyMatch:
        return 'Từ vựng';
      case QuestionType.grammarOrder:
        return 'Ngữ pháp';
      case QuestionType.readingComprehension:
        return 'Đọc hiểu';
      case QuestionType.writingTranslation:
        return 'Viết';
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final lesson = state.lesson;
    final q = lesson.questions[state.questionIndex];
    final total = lesson.questions.length;
    final idx = state.questionIndex + 1;
    final progress = idx / total;

    /// ReorderableListView inside SingleChildScrollView fights for vertical drags.
    /// Use Column + Expanded for match / grammar reorder questions.
    final useExpandedReorder = q.type == QuestionType.vocabularyMatch ||
        q.type == QuestionType.grammarOrder;

    final header = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: AppColors.locked,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Chip(
              label: Text(
                _typeLabel(q.type),
                style: tt.bodySmall?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              backgroundColor: AppColors.primary.withValues(alpha: 0.18),
              side: BorderSide(color: cs.primary.withValues(alpha: 0.45)),
            ),
            const Spacer(),
            Text(
              '$idx / $total',
              style: tt.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          lesson.title,
          style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(q.instruction, style: tt.bodyLarge),
        const SizedBox(height: 20),
      ],
    );

    final feedback = state.feedback == null
        ? null
        : Material(
            color: state.canGoNext
                ? AppColors.primary.withValues(alpha: 0.12)
                : AppColors.error.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(
                    state.canGoNext ? Icons.check_circle : Icons.info_outline,
                    color: state.canGoNext ? AppColors.primary : AppColors.error,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(state.feedback!, style: tt.bodyLarge)),
                ],
              ),
            ),
          );

    final actions = Row(
      children: [
        Expanded(
          child: FilledButton(
            onPressed: () {
              context.read<LessonQuizBloc>().add(const LessonQuizCheckPressed());
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('KIỂM TRA'),
          ),
        ),
        if (state.canGoNext) ...[
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                context.read<LessonQuizBloc>().add(const LessonQuizContinuePressed());
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary, width: 2),
              ),
              child: const Text('TIẾP TỤC'),
            ),
          ),
        ],
      ],
    );

    if (useExpandedReorder) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: header,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: _QuestionPanel(q: q, state: state, reorderExpanded: true),
            ),
          ),
          if (feedback != null) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: feedback,
            ),
          ],
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            child: actions,
          ),
        ],
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header,
          _QuestionPanel(q: q, state: state, reorderExpanded: false),
          if (feedback != null) ...[
            const SizedBox(height: 16),
            feedback,
          ],
          const SizedBox(height: 24),
          actions,
        ],
      ),
    );
  }
}

class _QuestionPanel extends StatelessWidget {
  const _QuestionPanel({
    required this.q,
    required this.state,
    this.reorderExpanded = false,
  });

  final QuestionEntity q;
  final LessonQuizPlaying state;
  final bool reorderExpanded;

  @override
  Widget build(BuildContext context) {
    switch (q.type) {
      case QuestionType.vocabularyImage:
        final ex = VocabularyImageExercise.fromQuestion(q);
        return _VocabularyImagePanel(ex: ex, selected: state.selectedImage);
      case QuestionType.vocabularyMatch:
        final ex = VocabularyMatchExercise.fromQuestion(q);
        return _VocabularyMatchPanel(
          ex: ex,
          order: state.matchVietnameseOrder,
          reorderExpanded: reorderExpanded,
        );
      case QuestionType.grammarOrder:
        return _GrammarOrderPanel(
          order: state.grammarWordOrder,
          reorderExpanded: reorderExpanded,
        );
      case QuestionType.readingComprehension:
        final ex = ReadingExercise.fromQuestion(q);
        return _ReadingPanel(
          ex: ex,
          selected: state.selectedReading,
        );
      case QuestionType.writingTranslation:
        final ex = WritingExercise.fromQuestion(q);
        return _WritingPanel(
          ex: ex,
          text: state.writingText,
          questionId: q.id,
        );
    }
  }
}

class _VocabularyImagePanel extends StatelessWidget {
  const _VocabularyImagePanel({required this.ex, required this.selected});

  final VocabularyImageExercise ex;
  final int? selected;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Từ gợi ý: "${ex.prompt}"',
          style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: List.generate(ex.optionEmojis.length, (i) {
            final on = selected == i;
            return Material(
              color: on ? AppColors.primary.withValues(alpha: 0.2) : AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              elevation: on ? 2 : 0,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  context.read<LessonQuizBloc>().add(LessonQuizImageSelected(i));
                },
                child: Container(
                  width: 76,
                  height: 76,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: on ? AppColors.primary : AppColors.locked,
                      width: on ? 3 : 1,
                    ),
                  ),
                  child: Text(ex.optionEmojis[i], style: const TextStyle(fontSize: 36)),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _VocabularyMatchPanel extends StatelessWidget {
  const _VocabularyMatchPanel({
    required this.ex,
    required this.order,
    required this.reorderExpanded,
  });

  final VocabularyMatchExercise ex;
  final List<String> order;
  final bool reorderExpanded;

  @override
  Widget build(BuildContext context) {
    final onLight = AppTextStyles.title.copyWith(fontSize: 16, color: AppColors.textPrimary);
    final tt = Theme.of(context).textTheme;
    final englishColumn = Column(
      children: ex.englishTerms
          .map(
            (e) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.locked),
              ),
              alignment: Alignment.centerLeft,
              child: Text(e, style: onLight),
            ),
          )
          .toList(),
    );

    final list = ReorderableListView(
      physics: const NeverScrollableScrollPhysics(),
      buildDefaultDragHandles: false,
      onReorder: (oldIndex, newIndex) {
        if (newIndex > oldIndex) newIndex -= 1;
        final next = List<String>.from(order);
        final item = next.removeAt(oldIndex);
        next.insert(newIndex, item);
        context.read<LessonQuizBloc>().add(LessonQuizMatchReordered(next));
      },
      children: [
        for (var i = 0; i < order.length; i++)
          ReorderableDragStartListener(
            key: ValueKey('match_${order[i]}_$i'),
            index: i,
            child: Card(
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                title: Text(order[i], style: tt.bodyLarge),
                trailing: const Icon(Icons.drag_handle_rounded),
              ),
            ),
          ),
      ],
    );

    final row = reorderExpanded
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: englishColumn),
              const SizedBox(width: 12),
              Expanded(child: list),
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: englishColumn),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: (64 * order.length).toDouble().clamp(120, 400),
                  child: list,
                ),
              ),
            ],
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Kéo thả để sắp xếp cột phải khớp với từng từ tiếng Anh bên trái.',
          style: tt.bodySmall,
        ),
        const SizedBox(height: 12),
        if (reorderExpanded)
          Expanded(child: row)
        else
          row,
      ],
    );
  }
}

class _GrammarOrderPanel extends StatelessWidget {
  const _GrammarOrderPanel({
    required this.order,
    required this.reorderExpanded,
  });

  final List<String> order;
  final bool reorderExpanded;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final list = ReorderableListView(
      physics: const NeverScrollableScrollPhysics(),
      buildDefaultDragHandles: false,
      onReorder: (oldIndex, newIndex) {
        if (newIndex > oldIndex) newIndex -= 1;
        final next = List<String>.from(order);
        final item = next.removeAt(oldIndex);
        next.insert(newIndex, item);
        context.read<LessonQuizBloc>().add(LessonQuizGrammarReordered(next));
      },
      children: [
        for (var i = 0; i < order.length; i++)
          ReorderableDragStartListener(
            key: ValueKey('grammar_${order[i]}_$i'),
            index: i,
            child: Card(
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                title: Text(order[i], style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                trailing: const Icon(Icons.swap_vert_rounded),
              ),
            ),
          ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Sắp xếp các từ thành một câu đúng.', style: tt.bodySmall),
        const SizedBox(height: 12),
        if (reorderExpanded)
          Expanded(child: list)
        else
          SizedBox(
            height: (64 * order.length).toDouble().clamp(120, 400),
            child: list,
          ),
      ],
    );
  }
}

class _ReadingPanel extends StatelessWidget {
  const _ReadingPanel({required this.ex, required this.selected});

  final ReadingExercise ex;
  final int? selected;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final passageStyle = AppTextStyles.body.copyWith(color: AppColors.textPrimary);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.locked),
          ),
          child: Text(ex.passage, style: passageStyle),
        ),
        const SizedBox(height: 16),
        Text(ex.question, style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        ...List.generate(ex.choices.length, (i) {
          final on = selected == i;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Material(
              color: on ? AppColors.primary.withValues(alpha: 0.22) : AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  context.read<LessonQuizBloc>().add(LessonQuizReadingSelected(i));
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: on ? AppColors.primaryDark : AppColors.locked, width: on ? 2 : 1),
                  ),
                  child: Text(
                    ex.choices[i],
                    style: passageStyle.copyWith(
                      color: on ? const Color(0xFF78350F) : AppColors.textPrimary,
                      fontWeight: on ? FontWeight.w800 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _WritingPanel extends StatefulWidget {
  const _WritingPanel({required this.ex, required this.text, required this.questionId});

  final WritingExercise ex;
  final String text;
  final String questionId;

  @override
  State<_WritingPanel> createState() => _WritingPanelState();
}

class _WritingPanelState extends State<_WritingPanel> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.text);
  }

  @override
  void didUpdateWidget(covariant _WritingPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.questionId != widget.questionId) {
      _controller.text = widget.text;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
          ),
          child: Text(
            widget.ex.vietnamesePrompt,
            style: tt.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _controller,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Nhập bản dịch tiếng Anh...',
          ),
          onChanged: (v) {
            context.read<LessonQuizBloc>().add(LessonQuizWritingChanged(v));
          },
        ),
      ],
    );
  }
}

class _ResultPanel extends StatelessWidget {
  const _ResultPanel({
    required this.correct,
    required this.total,
    required this.xp,
    required this.onClose,
  });

  final int correct;
  final int total;
  final int xp;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.emoji_events_rounded, size: 72, color: AppColors.primary),
          const SizedBox(height: 16),
          Text('Hoàn thành bài học!', style: tt.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          Text(
            '$correct / $total câu đúng',
            style: tt.titleLarge,
          ),
          const SizedBox(height: 8),
          Text('+ $xp XP', style: tt.titleLarge?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w800)),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: onClose,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size(double.infinity, 52),
            ),
            child: const Text('VỀ LỘ TRÌNH'),
          ),
        ],
      ),
    );
  }
}
