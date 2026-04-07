import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/components/error_message.dart';
import '../../../core/components/loading_widget.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/skill_track_icons.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/utils/daily_lesson_plan.dart';
import '../../../core/utils/support_chat_unread.dart';
import '../../../domain/entities/lesson_entity.dart';
import '../../../domain/entities/skill_track.dart';
import '../../bloc/auth_bloc.dart';
import '../../bloc/lesson_bloc.dart';

class LearningPathPage extends StatefulWidget {
  const LearningPathPage({super.key});

  @override
  State<LearningPathPage> createState() => _LearningPathPageState();
}

class _LearningPathPageState extends State<LearningPathPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bloc = context.read<LessonBloc>();
      if (bloc.state is LessonInitial) {
        bloc.add(const LessonLoadRequested());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: BlocBuilder<LessonBloc, LessonState>(
        builder: (context, state) {
          if (state is LessonLoading || state is LessonInitial) {
            return const LoadingWidget(message: 'Đang tải lộ trình...');
          }
          if (state is LessonError) {
            return ErrorMessage(
              message: state.message,
              onRetry: () {
                context.read<LessonBloc>().add(const LessonLoadRequested());
              },
            );
          }
          if (state is LessonLoaded) {
            final firstUnlockedIdx = state.lessons.indexWhere((l) => l.isUnlocked);
            final startLessonId =
                firstUnlockedIdx >= 0 ? state.lessons[firstUnlockedIdx].id : null;

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, authState) {
                      if (authState is! AuthAuthenticated) {
                        return const SizedBox.shrink();
                      }
                      final u = authState.user;
                      return Container(
                        color: context.beeSectionBg,
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                        child: Row(
                          children: [
                            _TopStat(icon: Icons.bolt_rounded, value: '${u.xp}', color: AppColors.primary),
                            const SizedBox(width: 16),
                            _TopStat(icon: Icons.local_fire_department_rounded, value: '${u.streak}', color: AppColors.streak),
                            const SizedBox(width: 16),
                            _TopStat(icon: Icons.diamond_outlined, value: '${u.diamonds}', color: AppColors.gem),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Material(
                      borderRadius: BorderRadius.circular(18),
                      color: AppColors.bannerYellow,
                      elevation: 0,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () => _showDailyLessonSheet(context, state.lessons),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _todayLabel(),
                                style: tt.bodyMedium?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.95),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Bài mới mỗi ngày',
                                      style: tt.titleLarge?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 16,
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Chạm để xem gợi ý hôm nay & lịch sử theo ngày',
                                style: tt.bodySmall?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, authState) {
                        if (authState is! AuthAuthenticated) {
                          return const SizedBox.shrink();
                        }
                        final uid = authState.user.id;
                        return StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('support_chats')
                              .doc(uid)
                              .snapshots(),
                          builder: (context, snap) {
                            final data = snap.data?.data() as Map<String, dynamic>?;
                            final unread = supportUnreadCount(data, 'unreadForUser');
                            return Material(
                              borderRadius: BorderRadius.circular(18),
                              color: context.beeSurfaceCard,
                              elevation: 0,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(18),
                                onTap: () => context.push('/support-chat'),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  child: Row(
                                    children: [
                                      Badge(
                                        isLabelVisible: unread > 0,
                                        label: Text(unread > 99 ? '99+' : '$unread'),
                                        child: CircleAvatar(
                                          backgroundColor: AppColors.primary.withValues(alpha: 0.22),
                                          radius: 26,
                                          child: const Icon(
                                            Icons.smart_toy_rounded,
                                            color: AppColors.primaryDark,
                                            size: 28,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              AppStrings.supportChatCardTitle,
                                              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              AppStrings.supportChatCardSubtitle,
                                              style: tt.bodySmall?.copyWith(color: context.beeMuted),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(
                                        Icons.chat_bubble_outline_rounded,
                                        color: AppColors.primaryDark,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                    child: Column(
                      children: [
                        const Text('🐝', style: TextStyle(fontSize: 44)),
                        const SizedBox(height: 6),
                        Text(
                          'Chọn kỹ năng',
                          style: tt.titleLarge?.copyWith(
                            color: context.beeOnSurface,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '10 bài tổng; mỗi bài có đủ 4 kỹ năng. Cùng số ô trên các hàng = cùng một bài học.',
                          textAlign: TextAlign.center,
                          style: tt.bodyMedium?.copyWith(
                            color: context.beeMuted,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final track = SkillTrack.values[i];
                      final trackLessons =
                          state.lessons.where((l) => l.skillTrack == track).toList();
                      return _SkillTrackSection(
                        track: track,
                        lessons: trackLessons,
                        startLessonId: startLessonId,
                      );
                    },
                    childCount: SkillTrack.values.length,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Future<void> _showDailyLessonSheet(BuildContext context, List<LessonEntity> lessons) async {
    final h = MediaQuery.sizeOf(context).height;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return _DailyLessonBottomSheet(
          lessons: lessons,
          sheetHeight: h * 0.78,
        );
      },
    );
  }

  String _todayLabel() {
    final d = DateTime.now();
    const months = [
      'THÁNG 1', 'THÁNG 2', 'THÁNG 3', 'THÁNG 4', 'THÁNG 5', 'THÁNG 6',
      'THÁNG 7', 'THÁNG 8', 'THÁNG 9', 'THÁNG 10', 'THÁNG 11', 'THÁNG 12',
    ];
    return '${d.day} ${months[d.month - 1]}';
  }
}

class _DailyLessonBottomSheet extends StatefulWidget {
  const _DailyLessonBottomSheet({
    required this.lessons,
    required this.sheetHeight,
  });

  final List<LessonEntity> lessons;
  final double sheetHeight;

  @override
  State<_DailyLessonBottomSheet> createState() => _DailyLessonBottomSheetState();
}

class _DailyLessonBottomSheetState extends State<_DailyLessonBottomSheet> {
  String? _detailDayKey;

  LessonEntity? _lessonFor(String id) {
    try {
      return widget.lessons.firstWhere((l) => l.id == id);
    } catch (_) {
      return null;
    }
  }

  Widget _dragHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.locked,
          borderRadius: BorderRadius.circular(99),
        ),
      ),
    );
  }

  Widget _lessonRow(
    BuildContext context,
    TextTheme tt,
    LessonEntity l, {
    required bool showPlay,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      leading: CircleAvatar(
        backgroundColor: AppColors.primary.withValues(alpha: 0.2),
        child: Icon(
          skillTrackIcon(l.skillTrack),
          color: AppColors.primary,
          size: 22,
        ),
      ),
      title: Text(
        l.title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
        l.skillTrack.labelVi,
        style: tt.bodySmall?.copyWith(color: context.beeMuted),
      ),
      trailing: Icon(
        showPlay ? Icons.play_circle_filled_rounded : Icons.check_circle_rounded,
        color: AppColors.primary,
        size: showPlay ? 28 : 24,
      ),
      onTap: () {
        Navigator.of(context).pop();
        if (l.isUnlocked) {
          context.push('/lesson/${l.id}');
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return SizedBox(
      height: widget.sheetHeight,
      child: _detailDayKey == null
          ? _buildRoot(context, tt)
          : _buildDayDetail(context, tt, _detailDayKey!),
    );
  }

  Widget _buildRoot(BuildContext context, TextTheme tt) {
    final today = DateTime.now();
    final todayKey = calendarDayKey(today);
    final suggestions = dailySuggestedLessonIds(widget.lessons, today);

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final map = authState is AuthAuthenticated
            ? authState.user.dailyLessonCompletions
            : const <String, List<String>>{};
        final studyDays = sortedStudyDayKeys(map);

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
          children: [
            _dragHandle(),
            Text(
              'Bài học mỗi ngày',
              style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              'Mỗi ngày hệ thống tạo một danh sách gợi ý khác (mai sẽ khác hôm nay). '
              'Dưới đây là các ngày bạn đã có bài hoàn thành — chạm một ngày để xem kỹ năng đã học.',
              style: tt.bodySmall?.copyWith(color: context.beeMuted, height: 1.35),
            ),
            const SizedBox(height: 18),
            Text(
              'Gợi ý hôm nay (${formatDayLabelVi(todayKey)})',
              style: tt.titleSmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            if (suggestions.isEmpty)
              Text(
                'Chưa có bài mở khóa.',
                style: tt.bodyMedium?.copyWith(color: context.beeMuted),
              )
            else
              ...suggestions.map((id) {
                final l = _lessonFor(id);
                if (l == null) return const SizedBox.shrink();
                return _lessonRow(context, tt, l, showPlay: true);
              }),
            const SizedBox(height: 22),
            const Divider(height: 1),
            const SizedBox(height: 14),
            Text(
              'Ngày đã học',
              style: tt.titleSmall?.copyWith(
                color: AppColors.gem,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            if (studyDays.isEmpty)
              Text(
                'Chưa có ngày nào được ghi nhận. Hoàn thành bài trên lộ trình để lưu lịch sử.',
                style: tt.bodyMedium?.copyWith(color: context.beeMuted),
              )
            else
              ...studyDays.map((dayKey) {
                final n = map[dayKey]?.length ?? 0;
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
                  leading: CircleAvatar(
                    backgroundColor: AppColors.bannerYellow.withValues(alpha: 0.25),
                    child: Icon(Icons.calendar_month_rounded, color: AppColors.bannerYellow),
                  ),
                  title: Text(
                    formatDayLabelVi(dayKey),
                    style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    '$n bài đã hoàn thành',
                    style: tt.bodySmall?.copyWith(color: context.beeMuted),
                  ),
                  trailing: Icon(Icons.chevron_right_rounded, color: context.beeMuted),
                  onTap: () => setState(() => _detailDayKey = dayKey),
                );
              }),
          ],
        );
      },
    );
  }

  Widget _buildDayDetail(BuildContext context, TextTheme tt, String dayKey) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final ids = authState is AuthAuthenticated
            ? (authState.user.dailyLessonCompletions[dayKey] ?? const <String>[])
            : const <String>[];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 12, 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    color: context.beeOnSurface,
                    onPressed: () => setState(() => _detailDayKey = null),
                  ),
                  Expanded(
                    child: Text(
                      'Ngày ${formatDayLabelVi(dayKey)}',
                      style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Các kỹ năng / bài đã học trong ngày',
                style: tt.bodySmall?.copyWith(color: context.beeMuted),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ids.isEmpty
                  ? Center(
                      child: Text(
                        'Không có dữ liệu cho ngày này.',
                        style: tt.bodyMedium?.copyWith(color: context.beeMuted),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                      itemCount: ids.length,
                      itemBuilder: (context, i) {
                        final id = ids[i];
                        final l = _lessonFor(id);
                        if (l == null) {
                          return ListTile(
                            leading: const CircleAvatar(child: Icon(Icons.school_rounded)),
                            title: Text(id, style: tt.bodyMedium),
                          );
                        }
                        return _lessonRow(context, tt, l, showPlay: false);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _SkillTrackSection extends StatelessWidget {
  const _SkillTrackSection({
    required this.track,
    required this.lessons,
    required this.startLessonId,
  });

  final SkillTrack track;
  final List<LessonEntity> lessons;
  final String? startLessonId;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 20, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(skillTrackIcon(track), color: AppColors.primary, size: 30),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      track.labelVi.toUpperCase(),
                      style: tt.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      track.hintVi,
                      style: tt.bodyMedium?.copyWith(color: context.beeMuted),
                    ),
                  ],
                ),
              ),
              Text(
                '${lessons.length} bài',
                style: tt.labelLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 268,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(bottom: 8),
              itemCount: lessons.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final lesson = lessons[index];
                final showStart = startLessonId != null && lesson.id == startLessonId;

                return SizedBox(
                  width: 168,
                  child: _SkillLessonCard(
                    lesson: lesson,
                    lessonNumber: index + 1,
                    showStartBubble: showStart,
                    onTap: () {
                      if (!lesson.isUnlocked) return;
                      context.push('/lesson/${lesson.id}');
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SkillLessonCard extends StatelessWidget {
  const _SkillLessonCard({
    required this.lesson,
    required this.lessonNumber,
    required this.showStartBubble,
    required this.onTap,
  });

  final LessonEntity lesson;
  final int lessonNumber;
  final bool showStartBubble;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final unlocked = lesson.isUnlocked;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showStartBubble)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  'BẮT ĐẦU',
                  style: tt.labelLarge?.copyWith(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: unlocked ? onTap : null,
            child: Ink(
              height: 86,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: unlocked
                    ? LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primaryLight,
                          AppColors.primary,
                          AppColors.primaryDark,
                        ],
                      )
                    : null,
                color: unlocked ? null : AppColors.locked,
                boxShadow: unlocked
                    ? [
                        BoxShadow(
                          color: AppColors.primaryDark.withValues(alpha: 0.5),
                          offset: const Offset(0, 4),
                          blurRadius: 0,
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    unlocked ? Icons.play_arrow_rounded : Icons.lock_rounded,
                    color: unlocked ? AppColors.onPrimaryStrong : context.beeSecondaryLabel,
                    size: 30,
                  ),
                  Text(
                    '$lessonNumber',
                    style: tt.labelLarge?.copyWith(
                      color: unlocked ? AppColors.onPrimaryStrong : context.beeSecondaryLabel,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          lesson.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: tt.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          lesson.topicLabel,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: tt.bodySmall?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          unlocked
              ? '+${lesson.xpReward} XP · ${lesson.questions.length} câu'
              : 'Làm bài trước trong lộ trình để mở',
          maxLines: 2,
          style: tt.bodySmall?.copyWith(
            color: context.beeMuted,
            fontSize: 12,
            height: 1.25,
          ),
        ),
      ],
    );
  }
}

class _TopStat extends StatelessWidget {
  const _TopStat({required this.icon, required this.value, required this.color});

  final IconData icon;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 22, color: color),
        const SizedBox(width: 6),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w800,
              ),
        ),
      ],
    );
  }
}
