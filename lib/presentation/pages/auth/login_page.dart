import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/audio/app_sound_effects.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/utils/input_converter.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/obscure_password_field.dart';
import '../../bloc/auth_bloc.dart';
import '../../components/custom_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    final email = InputConverter.trimLowerEmail(_emailController.text);
    final password = _passwordController.text;

    context.read<AuthBloc>().add(
          LoginWithEmailRequested(email: email, password: password),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: MultiBlocListener(
          listeners: [
            BlocListener<AuthBloc, AuthState>(
              listenWhen: (p, c) => p is AuthLoading && c is AuthAuthenticated,
              listener: (_, _) {
                AppSoundEffects.playLoginSuccess();
              },
            ),
            BlocListener<AuthBloc, AuthState>(
              listenWhen: (p, c) => p is AuthLoading && c is AuthError,
              listener: (_, _) {
                AppSoundEffects.playLoginFailure();
              },
            ),
          ],
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),
                    Text(
                      AppStrings.appName,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppStrings.loginTitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 32),
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
                      autofillHints: const [AutofillHints.password],
                      validator: Validators.password,
                      enabled: !loading,
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      label: AppStrings.loginButton,
                      isLoading: loading,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: loading ? null : () => context.push('/forgot-password'),
                          child: const Text('Quên mật khẩu?'),
                        ),
                        TextButton(
                          onPressed: loading ? null : () => context.push('/register'),
                          child: const Text('Chưa có tài khoản? Đăng ký'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Demo: demo@beewise.com / password123',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        ),
      ),
    );
  }
}
