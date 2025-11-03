import 'package:flutter/material.dart';

class ProgressBar extends StatelessWidget {
  final double value; // 0..1
  const ProgressBar({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: LinearProgressIndicator(
        minHeight: 10,
        value: value.clamp(0.0, 1.0),
      ),
    );
  }
}


