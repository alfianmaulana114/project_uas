import 'package:flutter/material.dart';

/// Custom Button Widget
/// Mengikuti konsep Reusability dan Single Responsibility Principle
/// Widget ini dapat digunakan di berbagai tempat dengan konfigurasi yang berbeda
class CustomButton extends StatelessWidget {
  /// Text yang ditampilkan di button
  final String text;

  /// Function yang dipanggil ketika button di-tap
  final VoidCallback? onPressed;

  /// Apakah button ini dalam state loading
  final bool isLoading;

  /// Apakah button ini enabled
  final bool isEnabled;

  /// Warna background button (opsional)
  final Color? backgroundColor;

  /// Warna text button (opsional)
  final Color? textColor;

  /// Icon yang ditampilkan di button (opsional)
  final IconData? icon;

  /// Apakah icon berada di kiri atau kanan text
  final bool isIconLeft;

  /// Width button (opsional, jika null akan menggunakan full width)
  final double? width;

  /// Height button (opsional)
  final double? height;

  /// Border radius button
  final double borderRadius;

  /// Constructor untuk CustomButton
  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.isIconLeft = true,
    this.width,
    this.height = 56,
    this.borderRadius = 12,
  });

  /// Build method untuk membuat widget
  @override
  Widget build(BuildContext context) {
    /// Warna background yang akan digunakan
    final bgColor = backgroundColor ?? Theme.of(context).colorScheme.primary;

    /// Warna text yang akan digunakan
    final txtColor = textColor ?? Theme.of(context).colorScheme.onPrimary;

    /// Apakah button enabled dan tidak loading
    final canPress = isEnabled && !isLoading && onPressed != null;

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: canPress ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: canPress ? bgColor : bgColor.withOpacity(0.5),
          foregroundColor: txtColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          elevation: 0,
          disabledBackgroundColor: bgColor.withOpacity(0.5),
          disabledForegroundColor: txtColor.withOpacity(0.5),
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(txtColor),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// Icon di kiri (jika ada dan isIconLeft = true)
                  if (icon != null && isIconLeft) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                  ],

                  /// Text button
                  Text(
                    text,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: txtColor,
                        ),
                  ),

                  /// Icon di kanan (jika ada dan isIconLeft = false)
                  if (icon != null && !isIconLeft) ...[
                    const SizedBox(width: 8),
                    Icon(icon, size: 20),
                  ],
                ],
              ),
      ),
    );
  }
}

