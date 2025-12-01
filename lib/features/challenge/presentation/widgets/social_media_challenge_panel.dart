import 'package:flutter/material.dart';

/// Model sederhana untuk mewakili status aplikasi sosial media.
class SocialAppUsage {
  final String name;
  final int minutesPerDay;
  final IconData icon;
  final bool isBlocked;

  const SocialAppUsage({
    required this.name,
    required this.minutesPerDay,
    required this.icon,
    required this.isBlocked,
  });

  SocialAppUsage copyWith({bool? isBlocked}) {
    return SocialAppUsage(
      name: name,
      minutesPerDay: minutesPerDay,
      icon: icon,
      isBlocked: isBlocked ?? this.isBlocked,
    );
  }
}

/// Panel visual status aplikasi sosial media
/// meniru tampilan pada desain contoh (blokir vs aktif).
class SocialMediaChallengePanel extends StatefulWidget {
  final List<SocialAppUsage> initialApps;

  const SocialMediaChallengePanel({
    super.key,
    required this.initialApps,
  });

  @override
  State<SocialMediaChallengePanel> createState() => _SocialMediaChallengePanelState();
}

class _SocialMediaChallengePanelState extends State<SocialMediaChallengePanel> {
  late List<SocialAppUsage> _apps;

  @override
  void initState() {
    super.initState();
    _apps = List.of(widget.initialApps);
  }

  @override
  void didUpdateWidget(covariant SocialMediaChallengePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialApps != widget.initialApps) {
      _apps = List.of(widget.initialApps);
    }
  }

  void _toggle(SocialAppUsage app) {
    final index = _apps.indexWhere((a) => a.name == app.name);
    if (index == -1) return;
    final updated = app.copyWith(isBlocked: !app.isBlocked);
    setState(() {
      _apps[index] = updated;
    });
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          updated.isBlocked ? '${app.name} diblokir.' : '${app.name} dibuka.',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final blocked = _apps.where((a) => a.isBlocked).toList();
    final active = _apps.where((a) => !a.isBlocked).toList();

    Widget buildSection({
      required String title,
      required List<SocialAppUsage> items,
      required Color badgeColor,
      required Color background,
      required bool blockedSection,
    }) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: badgeColor, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(
                '$title (${items.length})',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: background.withOpacity(0.4)),
            ),
            child: Column(
              children: items.map((app) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.white,
                            child: Icon(app.icon, color: blockedSection ? Colors.redAccent : Colors.blueGrey),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(app.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                          FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: blockedSection ? Colors.green : Colors.redAccent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                            ),
                            onPressed: () => _toggle(app),
                            child: Text(blockedSection ? 'Buka' : 'Blokir'),
                          ),
                        ],
                      ),
                    ),
                    if (app != items.last)
                      Divider(height: 1, thickness: 1, color: background.withOpacity(0.5)),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSection(
          title: 'Diblokir',
          items: blocked,
          badgeColor: Colors.redAccent,
          background: Colors.red.shade50,
          blockedSection: true,
        ),
        const SizedBox(height: 16),
        buildSection(
          title: 'Aktif',
          items: active,
          badgeColor: Colors.green,
          background: Colors.green.shade50,
          blockedSection: false,
        ),
      ],
    );
  }
}


