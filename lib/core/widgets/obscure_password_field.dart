import 'package:flutter/material.dart';

/// Ô nhập mật khẩu với nút hiện / ẩn (dùng cho đăng nhập, đăng ký, hồ sơ).
class ObscurePasswordField extends StatefulWidget {
  const ObscurePasswordField({
    super.key,
    required this.controller,
    required this.label,
    this.validator,
    this.enabled = true,
    this.autofillHints,
    this.textInputAction,
    this.onFieldSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final bool enabled;
  final Iterable<String>? autofillHints;
  final TextInputAction? textInputAction;
  final void Function(String)? onFieldSubmitted;

  @override
  State<ObscurePasswordField> createState() => _ObscurePasswordFieldState();
}

class _ObscurePasswordFieldState extends State<ObscurePasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscure,
      enabled: widget.enabled,
      autofillHints: widget.autofillHints,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onFieldSubmitted,
      decoration: InputDecoration(
        labelText: widget.label,
        suffixIcon: IconButton(
          tooltip: _obscure ? 'Hiện mật khẩu' : 'Ẩn mật khẩu',
          icon: Icon(
            _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          ),
          onPressed: widget.enabled
              ? () => setState(() => _obscure = !_obscure)
              : null,
        ),
      ),
      validator: widget.validator,
    );
  }
}
