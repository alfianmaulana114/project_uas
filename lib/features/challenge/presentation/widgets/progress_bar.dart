import 'package:flutter/material.dart';

/// Progress Bar Widget
/// Widget untuk menampilkan progress bar dengan value 0.0 sampai 1.0
/// Mengikuti konsep Single Responsibility Principle
class ProgressBar extends StatelessWidget {
  /// Value progress (0.0 sampai 1.0)
  final double value;

  /// Label progress (opsional, menampilkan persentase)
  final bool showLabel;

  /// Constructor untuk ProgressBar
  /// [value] adalah nilai progress (akan di-clamp ke 0.0-1.0)
  /// [showLabel] apakah menampilkan label persentase
  const ProgressBar({
    super.key,
    required this.value,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    final clampedValue = value.clamp(0.0, 1.0);
    final percentage = (clampedValue * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                '$percentage%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 4),
        ],
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            minHeight: 10,
            value: clampedValue,
            backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}


