import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/colors.dart';
import '../../../core/dependency_injection/injection_container.dart';
import '../../../core/error/failure.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/repositories/gamification_repository.dart';
import '../../bloc/auth_bloc.dart';

/// Màn hình cập nhật họ tên (mở từ menu Hồ sơ).
class ProfileEditNamePage extends StatefulWidget {
  const ProfileEditNamePage({super.key});

  @override
  State<ProfileEditNamePage> createState() => _ProfileEditNamePageState();
}

class _ProfileEditNamePageState extends State<ProfileEditNamePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final s = context.read<AuthBloc>().state;
      if (s is AuthAuthenticated) {
        _nameController.text = s.user.name;
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;
    final name = _nameController.text.trim();
    if (name == authState.user.name) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Chưa có thay đổi')));
      return;
    }
    setState(() => _saving = true);
    try {
      final repo = sl<AuthRepository>();
      final gam = sl<GamificationRepository>();
      final updated = await repo.updateDisplayName(authState.user, name);
      await gam.initializeSession(updated);
      if (!mounted) return;
      context.read<AuthBloc>().add(UserProfileRefreshed(updated));
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã cập nhật họ tên')));
      Navigator.of(context).pop();
    } on Failure catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Cập nhật họ tên'),
        scrolledUnderElevation: 0,
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is! AuthAuthenticated) {
            return const Center(child: Text('Chưa đăng nhập'));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Tên hiển thị trên hồ sơ và bảng xếp hạng.',
                    style: tt.bodyMedium?.copyWith(color: context.beeMuted),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Họ và tên',
                      hintText: 'Nhập họ tên của bạn',
                    ),
                    validator: Validators.name,
                    enabled: !_saving,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _saving ? null : _save,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimaryStrong,
                    ),
                    child: _saving
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Lưu'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
