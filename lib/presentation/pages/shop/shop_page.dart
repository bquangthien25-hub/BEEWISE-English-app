import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/constants/colors.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/dependency_injection/injection_container.dart';
import '../../../core/error/failure.dart';
import '../../../domain/entities/subscription_tier.dart';
import '../../../domain/repositories/gamification_repository.dart';
import '../../bloc/auth_bloc.dart';

/// Cửa hàng gói đăng ký — mua mock qua [GamificationRepository], cập nhật hồ sơ.
class ShopPage extends StatelessWidget {
  const ShopPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          final isPremium = authState is AuthAuthenticated &&
              authState.user.subscriptionTier == SubscriptionTier.premium;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  AppStrings.shopTitle,
                  style: tt.headlineLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  AppStrings.shopSubtitle,
                  style: tt.bodyMedium?.copyWith(
                    color: context.beeMuted,
                    letterSpacing: 0.5,
                  ),
                ),
                if (authState is AuthAuthenticated) ...[
                  const SizedBox(height: 16),
                  Material(
                    color: context.beeSurfaceCard,
                    borderRadius: BorderRadius.circular(16),
                    child: ListTile(
                      leading: Icon(
                        isPremium ? Icons.workspace_premium_rounded : Icons.person_outline_rounded,
                        color: isPremium ? AppColors.streak : context.beeMuted,
                      ),
                      title: Text(
                        isPremium ? 'Gói hiện tại: Premium' : 'Gói hiện tại: Basic',
                        style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(
                        isPremium
                            ? 'Bạn đã mở khóa đầy đủ quyền lợi Super (demo).'
                            : 'Nâng cấp để bỏ giới hạn và không quảng cáo (demo).',
                        style: tt.bodySmall?.copyWith(color: context.beeMuted),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                _PlanCard(
                  planKey: 'super',
                  purchaseDisabled: isPremium,
                  badge: AppStrings.shopRecommended,
                  title: 'Super',
                  priceLine: 'Dùng thử miễn phí · 0 kim cương',
                  gradient: const [Color(0xFF7C3AED), Color(0xFFFFB300)],
                  benefits: const [
                    'Năng lượng vô tận',
                    'Không quảng cáo',
                    'Bài học không giới hạn',
                  ],
                  cta: 'KÍCH HOẠT SUPER',
                ),
                const SizedBox(height: 16),
                _PlanCard(
                  planKey: 'family',
                  purchaseDisabled: isPremium,
                  title: 'Gói Super gia đình',
                  subtitle: 'Tối đa 6 tài khoản',
                  priceLine: '100 kim cương (demo)',
                  benefits: const [
                    'Tất cả quyền lợi Super',
                    'Theo dõi tiến độ gia đình',
                  ],
                  cta: 'MUA GÓI GIA ĐÌNH',
                ),
                const SizedBox(height: 20),
                Text(
                  'Thanh toán thật sẽ được tích hợp sau; hiện mua gói cập nhật trạng thái Premium trên máy bạn.',
                  style: tt.bodySmall?.copyWith(color: context.beeSecondaryLabel),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.planKey,
    required this.title,
    required this.benefits,
    required this.cta,
    this.purchaseDisabled = false,
    this.badge,
    this.subtitle,
    this.gradient,
    this.priceLine,
  });

  final String planKey;
  final bool purchaseDisabled;
  final String title;
  final String? subtitle;
  final List<String> benefits;
  final String cta;
  final String? badge;
  final List<Color>? gradient;
  final String? priceLine;

  Future<void> _confirmAndBuy(BuildContext context) async {
    if (purchaseDisabled) return;
    final tt = Theme.of(context).textTheme;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(ctx).cardTheme.color,
        title: Text(
          planKey == 'super' ? 'Kích hoạt Super' : 'Mua gói gia đình',
          style: tt.titleLarge,
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              if (subtitle != null) Text(subtitle!, style: tt.bodyMedium),
              if (priceLine != null) ...[
                const SizedBox(height: 8),
                Text(
                  priceLine!,
                  style: tt.bodyMedium?.copyWith(color: AppColors.gem, fontWeight: FontWeight.w700),
                ),
              ],
              const SizedBox(height: 12),
              const Text('Quyền lợi:', style: TextStyle(fontWeight: FontWeight.w600)),
              ...benefits.map((b) => Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.check_circle_rounded, color: AppColors.gem, size: 20),
                        const SizedBox(width: 8),
                        Expanded(child: Text(b)),
                      ],
                    ),
                  )),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;

    try {
      final user = await sl<GamificationRepository>().purchaseShopPlan(planKey);
      if (!context.mounted) return;
      context.read<AuthBloc>().add(UserProfileRefreshed(user));
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: Theme.of(ctx).cardTheme.color,
          title: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 28),
              SizedBox(width: 10),
              Expanded(child: Text('Thành công')),
            ],
          ),
          content: Text(
            planKey == 'super'
                ? 'Bạn đã kích hoạt gói Super (Premium). Thử làm bài và xem hồ sơ để kiểm tra.'
                : 'Bạn đã mua gói gia đình (Premium). Kim cương đã được trừ theo bảng giá demo.',
            style: tt.bodyMedium,
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Đã hiểu'),
            ),
          ],
        ),
      );
    } on Failure catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Material(
      color: context.beeSurfaceCard,
      borderRadius: BorderRadius.circular(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (badge != null && gradient != null)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                gradient: LinearGradient(colors: gradient!),
              ),
              child: Text(
                badge!,
                textAlign: TextAlign.center,
                style: tt.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(subtitle!, style: tt.bodyMedium?.copyWith(color: context.beeMuted)),
                ],
                if (priceLine != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    priceLine!,
                    style: tt.bodyMedium?.copyWith(
                      color: AppColors.gem,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                ...benefits.map(
                  (b) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.check_circle_rounded, color: AppColors.gem, size: 22),
                        const SizedBox(width: 10),
                        Expanded(child: Text(b, style: tt.bodyMedium)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: purchaseDisabled ? null : () => _confirmAndBuy(context),
                  child: Text(
                    purchaseDisabled ? 'ĐÃ KÍCH HOẠT PREMIUM' : cta,
                    style: tt.labelLarge?.copyWith(
                      color: purchaseDisabled ? context.beeSecondaryLabel : AppColors.gem,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
