import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/constants/colors.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/utils/support_chat_unread.dart';
import '../../../domain/entities/league_tier.dart';
import '../../../domain/entities/subscription_tier.dart';
import '../../bloc/auth_bloc.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/theme/theme_event.dart';
import '../../bloc/theme/theme_state.dart';
import 'profile_change_password_page.dart';
import 'profile_edit_avatar_page.dart';
import 'profile_edit_name_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is! AuthAuthenticated) {
            return const Center(child: Text('Chưa đăng nhập'));
          }

          final user = state.user;
          final tier = leagueTierFromXp(user.xp);

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 48, 20, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    _ProfileHeaderAvatar(
                      name: user.name,
                      avatarUrl: user.avatar,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: tt.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.email,
                            style: tt.bodySmall?.copyWith(
                              color: context.beeMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Material(
                  color: context.beeSurfaceCard,
                  borderRadius: BorderRadius.circular(20),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 16, 18, 4),
                        child: Text(
                          'Tài khoản',
                          style: tt.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.badge_outlined,
                          color: AppColors.primary,
                        ),
                        title: const Text('Cập nhật họ tên'),
                        subtitle: Text(
                          'Đổi tên hiển thị trên hồ sơ',
                          style: tt.bodySmall?.copyWith(
                            color: context.beeMuted,
                          ),
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () {
                          Navigator.of(context).push<void>(
                            MaterialPageRoute<void>(
                              builder: (_) => const ProfileEditNamePage(),
                            ),
                          );
                        },
                      ),
                      Divider(
                        height: 1,
                        color: Theme.of(
                          context,
                        ).dividerColor.withValues(alpha: 0.35),
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.lock_outline_rounded,
                          color: AppColors.primary,
                        ),
                        title: const Text('Đổi mật khẩu'),
                        subtitle: Text(
                          'Đổi mật khẩu đăng nhập',
                          style: tt.bodySmall?.copyWith(
                            color: context.beeMuted,
                          ),
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () {
                          Navigator.of(context).push<void>(
                            MaterialPageRoute<void>(
                              builder: (_) => const ProfileChangePasswordPage(),
                            ),
                          );
                        },
                      ),
                      Divider(
                        height: 1,
                        color: Theme.of(
                          context,
                        ).dividerColor.withValues(alpha: 0.35),
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.photo_camera_outlined,
                          color: AppColors.primary,
                        ),
                        title: const Text('Ảnh đại diện'),
                        subtitle: Text(
                          'PNG hoặc JPG, tối đa 5 MB',
                          style: tt.bodySmall?.copyWith(
                            color: context.beeMuted,
                          ),
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () {
                          Navigator.of(context).push<void>(
                            MaterialPageRoute<void>(
                              builder: (_) => const ProfileEditAvatarPage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('support_chats')
                      .doc(user.id)
                      .snapshots(),
                  builder: (context, snap) {
                    final data = snap.data?.data() as Map<String, dynamic>?;
                    final unread = supportUnreadCount(data, 'unreadForUser');
                    return Material(
                      color: context.beeSurfaceCard,
                      borderRadius: BorderRadius.circular(20),
                      clipBehavior: Clip.antiAlias,
                      child: ListTile(
                        leading: Badge(
                          isLabelVisible: unread > 0,
                          label: Text(unread > 99 ? '99+' : '$unread'),
                          child: CircleAvatar(
                            backgroundColor: AppColors.primary.withValues(alpha: 0.22),
                            child: const Icon(
                              Icons.chat_bubble_outline_rounded,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ),
                        title: const Text('Tin nhắn hỗ trợ'),
                        subtitle: Text(
                          'Chat với đội ngũ BeeWise',
                          style: tt.bodySmall?.copyWith(color: context.beeMuted),
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => context.push('/support-chat'),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                Material(
                  color: context.beeSurfaceCard,
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Thống kê',
                          style: tt.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _StatRow(
                          icon: Icons.bolt_rounded,
                          label: 'XP',
                          value: '${user.xp}',
                          color: AppColors.primary,
                        ),
                        _StatRow(
                          icon: Icons.diamond_outlined,
                          label: 'Kim cương',
                          value: '${user.diamonds}',
                          color: AppColors.gem,
                        ),
                        _StatRow(
                          icon: Icons.local_fire_department_rounded,
                          label: 'Streak',
                          value: '${user.streak} ngày',
                          color: AppColors.streak,
                        ),
                        _StatRow(
                          icon: Icons.military_tech_rounded,
                          label: 'Hạng giải đấu',
                          value: tier.labelVi,
                          color: AppColors.primaryLight,
                        ),
                        _StatRow(
                          icon: Icons.workspace_premium_rounded,
                          label: 'Gói đăng ký',
                          value: user.subscriptionTier.labelVi,
                          color: AppColors.streak,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  tileColor: context.beeSurfaceCard,
                  leading: const Icon(
                    Icons.leaderboard_rounded,
                    color: AppColors.primary,
                  ),
                  title: const Text(AppStrings.leaderboardTitle),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.go('/league'),
                ),
                const SizedBox(height: 12),
                if (user.isAdmin) ...[
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    tileColor: AppColors.primary.withValues(alpha: 0.2),
                    leading: const Icon(
                      Icons.security_rounded,
                      color: AppColors.primaryDark,
                    ),
                    title: Text(
                      'Khu vực Quản Trị',
                      style: tt.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.primaryDark,
                    ),
                    onTap: () => context.push('/admin'),
                  ),
                  const SizedBox(height: 12),
                ],
                BlocBuilder<ThemeBloc, ThemeState>(
                  builder: (context, themeState) {
                    final mode = themeState is ThemeReady
                        ? themeState.mode
                        : ThemeMode.dark;
                    final isLight = mode == ThemeMode.light;
                    return ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      tileColor: context.beeSurfaceCard,
                      leading: Icon(
                        isLight
                            ? Icons.light_mode_outlined
                            : Icons.dark_mode_outlined,
                      ),
                      title: const Text('Chế độ sáng'),
                      subtitle: Text(
                        isLight ? 'Đang bật' : 'Đang tắt',
                        style: tt.bodySmall?.copyWith(color: context.beeMuted),
                      ),
                      trailing: Switch(
                        value: isLight,
                        activeThumbColor: AppColors.primary,
                        onChanged: (v) {
                          context.read<ThemeBloc>().add(
                            ThemeModeChanged(
                              v ? ThemeMode.light : ThemeMode.dark,
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 28),
                OutlinedButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(const LogoutRequested());
                    context.go('/login');
                  },
                  child: const Text('Đăng xuất'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProfileHeaderAvatar extends StatelessWidget {
  const _ProfileHeaderAvatar({
    required this.name,
    this.avatarUrl,
  });

  final String name;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final url = avatarUrl;
    if (url != null && url.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          url,
          width: 72,
          height: 72,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _gradientPlaceholder(context, tt, initial),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return SizedBox(
              width: 72,
              height: 72,
              child: Center(
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              ),
            );
          },
        ),
      );
    }
    return _gradientPlaceholder(context, tt, initial);
  }

  Widget _gradientPlaceholder(BuildContext context, TextTheme tt, String initial) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [AppColors.gem, AppColors.accentPurple],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.gem.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: tt.headlineMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: tt.bodyMedium)),
          Text(
            value,
            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
