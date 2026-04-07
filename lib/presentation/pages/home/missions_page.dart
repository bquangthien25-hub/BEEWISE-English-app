import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/constants/colors.dart';
import '../../../core/theme/theme_colors.dart';
import '../../bloc/mission/mission_bloc.dart';
import '../../bloc/mission/mission_event.dart';
import '../../bloc/mission/mission_state.dart';

/// Nhiệm vụ — header tím + danh sách (tham chiếu Duolingo).
class MissionsPage extends StatefulWidget {
  const MissionsPage({super.key});

  @override
  State<MissionsPage> createState() => _MissionsPageState();
}

class _MissionsPageState extends State<MissionsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<MissionBloc>().add(const MissionLoadRequested());
    });
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: BlocBuilder<MissionBloc, MissionState>(
        builder: (context, state) {
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 52, 20, 24),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF7C3AED),
                        Color(0xFF5B21B6),
                      ],
                    ),
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.dailyMissions,
                              style: tt.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Hoàn thành nhiệm vụ để nhận XP và kim cương!',
                              style: tt.bodyMedium?.copyWith(
                                color: Colors.white.withValues(alpha: 0.92),
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Text('🐝', style: TextStyle(fontSize: 36)),
                    ],
                  ),
                ),
              ),
              if (state is MissionLoading || state is MissionInitial)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                )
              else if (state is MissionError)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Card(
                      child: ListTile(
                        title: Text(state.message, style: tt.bodyMedium),
                        trailing: TextButton(
                          onPressed: () {
                            context.read<MissionBloc>().add(const MissionLoadRequested());
                          },
                          child: const Text('Tải lại'),
                        ),
                      ),
                    ),
                  ),
                )
              else if (state is MissionReady)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final m = state.missions[index];
                        final pct = m.target == 0 ? 0.0 : (m.progress / m.target).clamp(0.0, 1.0);
                        final done = m.completed && m.claimed;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Material(
                            color: context.beeSurfaceCard,
                            borderRadius: BorderRadius.circular(20),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          m.title,
                                          style: tt.titleMedium?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      if (m.completed && !m.claimed)
                                        FilledButton(
                                          onPressed: () {
                                            context.read<MissionBloc>().add(MissionClaimRequested(m.id));
                                          },
                                          style: FilledButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                            minimumSize: Size.zero,
                                          ),
                                          child: const Text('NHẬN'),
                                        ),
                                      if (m.claimed)
                                        Text(
                                          'Đã nhận',
                                          style: tt.bodySmall?.copyWith(color: AppColors.primary),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: LinearProgressIndicator(
                                      minHeight: 22,
                                      value: pct,
                                      backgroundColor: AppColors.surfaceDark,
                                      color: done
                                          ? AppColors.primary.withValues(alpha: 0.5)
                                          : const Color(0xFFFF9600),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${m.progress}/${m.target} · +${m.rewardXp} XP · +${m.rewardDiamonds} 💎',
                                    style: tt.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: state.missions.length,
                    ),
                  ),
                )
              else
                const SliverToBoxAdapter(child: SizedBox.shrink()),
            ],
          );
        },
      ),
    );
  }
}
