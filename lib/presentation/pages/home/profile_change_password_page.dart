import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/colors.dart';
import '../../../core/dependency_injection/injection_container.dart';
import '../../../core/error/failure.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/obscure_password_field.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../bloc/auth_bloc.dart';

/// Màn hình đổi mật khẩu (mở từ menu Hồ sơ).
class ProfileChangePasswordPage extends StatefulWidget {
  const ProfileChangePasswordPage({super.key});

  @override
  State<ProfileChangePasswordPage> createState() =>
      _ProfileChangePasswordPageState();
}

class _ProfileChangePasswordPageState extends State<ProfileChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    setState(() => _saving = true);
    try {
      final repo = sl<AuthRepository>();
      await repo.updatePassword(
        authState.user,
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      );
      if (!mounted) return;
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã đổi mật khẩu')));
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
        title: const Text('Đổi mật khẩu'),
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
                    'Nhập mật khẩu hiện tại và mật khẩu mới (tối thiểu 6 ký tự).',
                    style: tt.bodyMedium?.copyWith(color: context.beeMuted),
                  ),
                  const SizedBox(height: 20),
                  ObscurePasswordField(
                    controller: _currentPasswordController,
                    label: 'Mật khẩu hiện tại',
                    autofillHints: const [AutofillHints.password],
                    validator: Validators.password,
                    enabled: !_saving,
                  ),
                  const SizedBox(height: 12),
                  ObscurePasswordField(
                    controller: _newPasswordController,
                    label: 'Mật khẩu mới',
                    autofillHints: const [AutofillHints.newPassword],
                    validator: Validators.password,
                    enabled: !_saving,
                  ),
                  const SizedBox(height: 12),
                  ObscurePasswordField(
                    controller: _confirmPasswordController,
                    label: 'Xác nhận mật khẩu mới',
                    autofillHints: const [AutofillHints.newPassword],
                    validator: (v) => Validators.confirmPassword(
                      v,
                      _newPasswordController.text,
                    ),
                    enabled: !_saving,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _saving ? null : _submit,
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
                        : const Text('Xác nhận đổi mật khẩu'),
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
