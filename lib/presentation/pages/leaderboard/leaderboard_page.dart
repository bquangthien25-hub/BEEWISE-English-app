import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/constants/colors.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../domain/entities/league_tier.dart';
import '../../bloc/league/league_bloc.dart';
import '../../bloc/league/league_event.dart';
import '../../bloc/league/league_state.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LeagueBloc>().add(const LeagueLoadRequested());
    });
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(AppStrings.leaderboardTitle),
        scrolledUnderElevation: 0,
      ),
      body: BlocBuilder<LeagueBloc, LeagueState>(
        builder: (context, state) {
          if (state is LeagueLoading || state is LeagueInitial) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (state is LeagueError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.message, textAlign: TextAlign.center, style: tt.bodyMedium),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () {
                        context.read<LeagueBloc>().add(const LeagueLoadRequested());
                      },
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            );
          }
          if (state is LeagueReady) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Material(
                    color: context.beeSurfaceCard,
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.emoji_events_rounded, color: AppColors.primary, size: 36),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hạng: ${state.tier.labelVi}',
                                  style: tt.titleMedium,
                                ),
                                Text(
                                  'XP của bạn: ${state.userXp}',
                                  style: tt.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Top 20 trong hạng (dữ liệu minh họa)',
                    style: tt.bodySmall,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    itemCount: state.entries.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 6),
                    itemBuilder: (context, i) {
                      final e = state.entries[i];
                      final highlight = e.isCurrentUser;
                      return Material(
                        color: highlight
                            ? AppColors.primary.withValues(alpha: 0.14)
                            : context.beeSurfaceCard,
                        borderRadius: BorderRadius.circular(12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: highlight ? AppColors.primary : AppColors.locked,
                            child: Text(
                              '${e.rank}',
                              style: TextStyle(
                                color: highlight ? Colors.white : null,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          title: Text(
                            e.displayName,
                            style: tt.titleMedium?.copyWith(
                              fontSize: 16,
                              fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                          trailing: Text(
                            '${e.xp} XP',
                            style: tt.bodyMedium?.copyWith(
                              color: highlight ? AppColors.primary : null,
                              fontWeight: highlight ? FontWeight.w600 : null,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
