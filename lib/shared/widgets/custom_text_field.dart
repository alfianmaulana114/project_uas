import 'package:flutter/material.dart';

/// Custom Text Field Widget
/// Mengikuti konsep Reusability dan Single Responsibility Principle
/// Widget ini dapat digunakan di berbagai tempat dengan konfigurasi yang berbeda
class CustomTextField extends StatelessWidget {
  /// Controller untuk text field
  final TextEditingController? controller;

  /// Label untuk text field
  final String? label;

  /// Hint text untuk text field
  final String? hint;

  /// Icon untuk text field
  final IconData? icon;

  /// Apakah text field ini adalah password field
  final bool isPassword;

  /// Apakah text field ini harus diisi (required)
  final bool isRequired;

  /// Validator function untuk validasi input
  final String? Function(String?)? validator;

  /// Keyboard type untuk text field
  final TextInputType keyboardType;

  /// Max lines untuk text field
  final int maxLines;

  /// Prefix icon untuk text field
  final Widget? prefixIcon;

  /// Suffix icon untuk text field
  final Widget? suffixIcon;

  /// Function yang dipanggil ketika text berubah
  final void Function(String)? onChanged;

  /// Function yang dipanggil ketika text field di-submit
  final void Function(String)? onSubmitted;

  /// Focus node untuk text field
  final FocusNode? focusNode;

  /// Apakah text field ini enabled
  final bool enabled;

  /// Constructor untuk CustomTextField
  const CustomTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.icon,
    this.isPassword = false,
    this.isRequired = false,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.enabled = true,
  });

  /// Build method untuk membuat widget
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Label text (jika ada)
        if (label != null) ...[
          Row(
            children: [
              Text(
                label!,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
              if (isRequired)
                Text(
                  ' *',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                ),
            ],
          ),
          const SizedBox(height: 8),
        ],

        /// Text field
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator ??
              (isRequired
                  ? (value) {
                      if (value == null || value.isEmpty) {
                        return '$label tidak boleh kosong';
                      }
                      return null;
                    }
                  : null),
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          focusNode: focusNode,
          enabled: enabled,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon ??
                (icon != null
                    ? Icon(
                        icon,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : null),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }
}

