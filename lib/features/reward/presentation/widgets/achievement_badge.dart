import 'package:flutter/material.dart';
import '../../domain/entities/achievement.dart';

class AchievementBadge extends StatelessWidget {
  final Achievement achievement;
  final bool earned;
  const AchievementBadge({super.key, required this.achievement, required this.earned});

  @override
  Widget build(BuildContext context) {
    final color = earned ? Theme.of(context).colorScheme.primary : Colors.grey;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          radius: 28,
          child: Icon(Icons.emoji_events, color: color),
        ),
        const SizedBox(height: 6),
        Text(
          achievement.name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: earned ? null : Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}