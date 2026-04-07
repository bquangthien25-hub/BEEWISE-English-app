import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/utils/input_converter.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/obscure_password_field.dart';
import '../../bloc/auth_bloc.dart';
import '../../components/custom_button.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _submit() {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    final name = _nameController.text.trim();
    final email = InputConverter.trimLowerEmail(_emailController.text);
    final password = _passwordController.text;

    context.read<AuthBloc>().add(
          RegisterWithEmailRequested(
            name: name,
            email: email,
            password: password,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(AppStrings.registerTitle),
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            final loading = state is AuthLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      AppStrings.appName,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.headline.copyWith(color: AppColors.primary),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(labelText: 'Họ tên'),
                      validator: Validators.name,
                      enabled: !loading,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      decoration: const InputDecoration(
                        labelText: AppStrings.emailHint,
                      ),
                      validator: Validators.email,
                      enabled: !loading,
                    ),
                    const SizedBox(height: 16),
                    ObscurePasswordField(
                      controller: _passwordController,
                      label: AppStrings.passwordHint,
                      autofillHints: const [AutofillHints.newPassword],
                      validator: Validators.password,
                      enabled: !loading,
                    ),
                    const SizedBox(height: 16),
                    ObscurePasswordField(
                      controller: _confirmController,
                      label: 'Xác nhận mật khẩu',
                      autofillHints: const [AutofillHints.newPassword],
                      validator: (v) => Validators.confirmPassword(v, _passwordController.text),
                      enabled: !loading,
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      label: 'Đăng ký',
                      isLoading: loading,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: loading ? null : () => context.pop(),
                      child: const Text('Đã có tài khoản? Đăng nhập'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
