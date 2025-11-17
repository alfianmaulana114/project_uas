import 'package:flutter/material.dart';
import '../../domain/entities/achievement.dart';

class AchievementUnlockDialog extends StatelessWidget {
  final List<Achievement> achievements;
  const AchievementUnlockDialog({super.key, required this.achievements});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Achievement Unlocked!'),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: achievements
              .map((a) => ListTile(
                    leading: const Icon(Icons.emoji_events, color: Colors.amber),
                    title: Text(a.name),
                    subtitle: Text('+${a.pointsReward} poin'),
                  ))
              .toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        )
      ],
    );
  }
}