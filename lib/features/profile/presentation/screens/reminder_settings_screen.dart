import 'package:flutter/material.dart';

/// Screen untuk mengatur pengingat (reminder)
/// Memungkinkan user mengatur waktu dan jenis pengingat
class ReminderSettingsScreen extends StatefulWidget {
  const ReminderSettingsScreen({super.key});

  @override
  State<ReminderSettingsScreen> createState() => _ReminderSettingsScreenState();
}

class _ReminderSettingsScreenState extends State<ReminderSettingsScreen> {
  // Status pengingat
  bool _checkInReminderEnabled = true;
  bool _dailyTargetReminderEnabled = true;
  bool _streakReminderEnabled = false;
  bool _weeklyReportEnabled = false;

  // Waktu pengingat
  TimeOfDay _checkInTime = const TimeOfDay(hour: 20, minute: 0);
  TimeOfDay _dailyTargetTime = const TimeOfDay(hour: 9, minute: 0);

  Future<void> _selectTime(BuildContext context, bool isCheckIn) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isCheckIn ? _checkInTime : _dailyTargetTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          _checkInTime = picked;
        } else {
          _dailyTargetTime = picked;
        }
      });
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Atur Pengingat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              // TODO: Simpan pengaturan pengingat ke database/local storage
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pengaturan pengingat berhasil disimpan'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Aktifkan pengingat untuk membantu Anda tetap konsisten dalam digital detox',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Pengingat Check-in Harian
            Text(
              'Pengingat Harian',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Pengingat Check-in'),
                    subtitle: const Text('Ingatkan untuk check-in challenge setiap hari'),
                    value: _checkInReminderEnabled,
                    onChanged: (value) {
                      setState(() => _checkInReminderEnabled = value);
                    },
                    secondary: const Icon(Icons.check_circle_outline),
                  ),
                  if (_checkInReminderEnabled) ...[
                    const Divider(height: 0),
                    ListTile(
                      leading: const Icon(Icons.access_time),
                      title: const Text('Waktu Pengingat'),
                      subtitle: Text(_formatTime(_checkInTime)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _selectTime(context, true),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Pengingat Target Harian
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Pengingat Target Harian'),
                    subtitle: const Text('Ingatkan untuk mencapai target harian'),
                    value: _dailyTargetReminderEnabled,
                    onChanged: (value) {
                      setState(() => _dailyTargetReminderEnabled = value);
                    },
                    secondary: const Icon(Icons.flag_outlined),
                  ),
                  if (_dailyTargetReminderEnabled) ...[
                    const Divider(height: 0),
                    ListTile(
                      leading: const Icon(Icons.access_time),
                      title: const Text('Waktu Pengingat'),
                      subtitle: Text(_formatTime(_dailyTargetTime)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _selectTime(context, false),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Pengingat Lainnya
            Text(
              'Pengingat Lainnya',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Pengingat Streak'),
                    subtitle: const Text('Ingatkan jika streak hampir terputus'),
                    value: _streakReminderEnabled,
                    onChanged: (value) {
                      setState(() => _streakReminderEnabled = value);
                    },
                    secondary: const Icon(Icons.local_fire_department_outlined),
                  ),
                  const Divider(height: 0),
                  SwitchListTile(
                    title: const Text('Laporan Mingguan'),
                    subtitle: const Text('Kirim ringkasan progress setiap minggu'),
                    value: _weeklyReportEnabled,
                    onChanged: (value) {
                      setState(() => _weeklyReportEnabled = value);
                    },
                    secondary: const Icon(Icons.insights_outlined),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Tips
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Tips',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildTip('Pilih waktu yang konsisten setiap hari'),
                  _buildTip('Aktifkan pengingat check-in di malam hari'),
                  _buildTip('Gunakan pengingat target di pagi hari'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

