import 'package:flutter/material.dart';
import 'package:thieu_nhi_app/theme/app_colors.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final int? maxLines;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final decorationTheme = theme.inputDecorationTheme;
    final baseDecoration =
        const InputDecoration().applyDefaults(decorationTheme);

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: obscureText ? 1 : maxLines,
      style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
      decoration: baseDecoration.copyWith(
        labelText: label,
        prefixIcon: Icon(icon,
            color:
                decorationTheme.prefixIconColor ?? theme.colorScheme.primary),
        suffixIcon: suffixIcon,
        filled: decorationTheme.filled ?? baseDecoration.filled ?? true,
        contentPadding: decorationTheme.contentPadding ??
            baseDecoration.contentPadding ??
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
