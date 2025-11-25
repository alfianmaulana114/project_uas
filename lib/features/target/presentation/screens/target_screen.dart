import 'package:flutter/material.dart';

class TargetScreen extends StatefulWidget {
  const TargetScreen({super.key});

  @override
  State<TargetScreen> createState() => _TargetScreenState();
}

class _TargetScreenState extends State<TargetScreen> {
  final List<_QuickTarget> _quickTargets = const [
    _QuickTarget(minutes: 30, label: '30 min', description: 'Sangat Ketat', icon: '🔥'),
    _QuickTarget(minutes: 60, label: '1 jam', description: 'Ketat', icon: '💪'),
    _QuickTarget(minutes: 90, label: '1.5 jam', description: 'Sedang', icon: '🧘'),
    _QuickTarget(minutes: 120, label: '2 jam', description: 'Santai', icon: '😊'),
  ];

  int _selectedTargetMinutes = 60;
  double _customTarget = 120;
  bool _morningSchedule = true;
  bool _workSchedule = false;
  bool _nightSchedule = true;
  bool _limitReminder = true;
  bool _motivationReminder = true;
  bool _weeklySummary = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Social Detox')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('TARGET HARIAN',
                    style: theme.textTheme.labelLarge?.copyWith(
                      letterSpacing: 1.4,
                      color: theme.colorScheme.primary,
                    )),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFC4C02), Color(0xFFFF8F4B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Target Saat Ini', style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '$_selectedTargetMinutes',
                            style: theme.textTheme.displaySmall
                                ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 6),
                          const Padding(
                            padding: EdgeInsets.only(bottom: 6),
                            child: Text('menit per hari', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text('Pilih Target Cepat',
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                const SizedBox(height: 16),
                LayoutBuilder(builder: (context, constraints) {
                  final width = (constraints.maxWidth - 16) / 2;
                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: _quickTargets.asMap().entries.map((entry) {
                    final target = entry.value;
                    final isSelected = _selectedTargetMinutes == target.minutes;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedTargetMinutes = target.minutes),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: width,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: isSelected
                                ? theme.colorScheme.primary.withOpacity(0.08)
                                : const Color(0xFFF7F4F0),
                            border: Border.all(
                              color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(target.icon, style: const TextStyle(fontSize: 20)),
                              const SizedBox(height: 10),
                              Text(target.label,
                                  style: theme.textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(target.description,
                                  style: theme.textTheme.bodySmall
                                      ?.copyWith(color: Colors.grey.shade700)),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Custom: ${_customTarget.round()} menit',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                    TextButton(
                      onPressed: () => setState(() => _selectedTargetMinutes = _customTarget.round()),
                      child: const Text('Set ke Target'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 6,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                    overlayShape: SliderComponentShape.noOverlay,
                  ),
                  child: Slider(
                    min: 15,
                    max: 180,
                    divisions: 11,
                    value: _customTarget,
                    onChanged: (value) => setState(() => _customTarget = value),
                    activeColor: theme.colorScheme.primary,
                    inactiveColor: Colors.grey.shade300,
                    label: '${_customTarget.round()} menit',
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('15'),
                    Text('180'),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Simpan Target'),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _ScheduleCard(
            morningEnabled: _morningSchedule,
            workEnabled: _workSchedule,
            nightEnabled: _nightSchedule,
            onChanged: (morning, work, night) {
              setState(() {
                _morningSchedule = morning;
                _workSchedule = work;
                _nightSchedule = night;
              });
            },
          ),
          const SizedBox(height: 16),
          _ReminderCard(
            limitReminder: _limitReminder,
            motivationReminder: _motivationReminder,
            weeklySummary: _weeklySummary,
            onChanged: (limit, motivation, summary) {
              setState(() {
                _limitReminder = limit;
                _motivationReminder = motivation;
                _weeklySummary = summary;
              });
            },
          ),
          const SizedBox(height: 16),
          _TipsCard(),
        ],
      ),
    );
  }
}

class _QuickTarget {
  final int minutes;
  final String label;
  final String description;
  final String icon;

  const _QuickTarget({
    required this.minutes,
    required this.label,
    required this.description,
    required this.icon,
  });
}

class _ScheduleCard extends StatelessWidget {
  final bool morningEnabled;
  final bool workEnabled;
  final bool nightEnabled;
  final void Function(bool morning, bool work, bool night) onChanged;

  const _ScheduleCard({
    required this.morningEnabled,
    required this.workEnabled,
    required this.nightEnabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_month, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                const Text('Jadwal Detox', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            _ScheduleTile(
              title: 'Pagi (06:00 - 09:00)',
              subtitle: 'Mulai hari tanpa distraksi',
              value: morningEnabled,
              onChanged: (value) => onChanged(value, workEnabled, nightEnabled),
            ),
            _ScheduleTile(
              title: 'Jam Kerja (09:00 - 17:00)',
              subtitle: 'Fokus produktivitas',
              value: workEnabled,
              onChanged: (value) => onChanged(morningEnabled, value, nightEnabled),
            ),
            _ScheduleTile(
              title: 'Malam (21:00 - 06:00)',
              subtitle: 'Tidur berkualitas',
              value: nightEnabled,
              onChanged: (value) => onChanged(morningEnabled, workEnabled, value),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScheduleTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ScheduleTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFFF7F4F0),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(color: Colors.grey.shade600)),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  final bool limitReminder;
  final bool motivationReminder;
  final bool weeklySummary;
  final void Function(bool limit, bool motivation, bool summary) onChanged;

  const _ReminderCard({
    required this.limitReminder,
    required this.motivationReminder,
    required this.weeklySummary,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.notifications_active, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                const Text('Pengingat', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            _ReminderTile(
              title: 'Pengingat Batas Waktu',
              subtitle: 'Notifikasi saat mendekati limit',
              value: limitReminder,
              onChanged: (value) => onChanged(value, motivationReminder, weeklySummary),
            ),
            _ReminderTile(
              title: 'Motivasi Harian',
              subtitle: 'Pesan semangat tiap pagi',
              value: motivationReminder,
              onChanged: (value) => onChanged(limitReminder, value, weeklySummary),
            ),
            _ReminderTile(
              title: 'Laporan Mingguan',
              subtitle: 'Ringkasan setiap Minggu',
              value: weeklySummary,
              onChanged: (value) => onChanged(limitReminder, motivationReminder, value),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReminderTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ReminderTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(subtitle, style: TextStyle(color: Colors.grey.shade600)),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _TipsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFFFF7A18), Color(0xFFFF9E42)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('💪 Tips Sukses', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          _TipText(text: 'Mulai target realistis'),
          _TipText(text: 'Kurangi 15-30 menit tiap minggu'),
          _TipText(text: 'Pakai jadwal waktu fokus'),
          _TipText(text: 'Aktifkan reminder'),
        ],
      ),
    );
  }
}

class _TipText extends StatelessWidget {
  final String text;

  const _TipText({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text('• $text', style: const TextStyle(color: Colors.white)),
    );
  }
}

