// lib/features/auth/widgets/modern_text_field.dart
import 'package:flutter/material.dart';

class ModernTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int? maxLines;

  const ModernTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
    this.keyboardType,
    this.maxLines,
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
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines ?? 1,
      style: theme.textTheme.bodyLarge?.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      decoration: baseDecoration.copyWith(
        labelText: label,
        suffixIcon: suffixIcon,
        prefixIcon: Icon(
          icon,
          color: decorationTheme.prefixIconColor ?? theme.colorScheme.primary,
          size: 18,
        ),
        filled: decorationTheme.filled ?? baseDecoration.filled ?? true,
        contentPadding: decorationTheme.contentPadding ??
            baseDecoration.contentPadding ??
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
