import 'package:flutter/material.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class PointsDisplay extends StatelessWidget {
  const PointsDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    final points = context.watch<AuthProvider>().currentUser?.totalPoints ?? 0;
    return Chip(
      label: Text('Total Poin: $points'),
      avatar: const Icon(Icons.stars, color: Colors.amber),
    );
  }
}