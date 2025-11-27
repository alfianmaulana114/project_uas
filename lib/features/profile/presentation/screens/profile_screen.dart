import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import 'edit_profile_screen.dart';

/// Halaman profil dengan berbagai pengaturan dan ringkasan user.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _focusModeEnabled = true;
  bool _limitSocialEnabled = false;
  bool _reminderCheckInEnabled = true;
  bool _communityUpdatesEnabled = true;

  String _displayName(AuthProvider auth) {
    final user = auth.currentUser;
    if (user == null) return 'Pengguna';
    return user.fullName?.trim().isNotEmpty == true
        ? user.fullName!.trim()
        : (user.username?.trim().isNotEmpty == true ? user.username!.trim() : user.email);
  }

  void _showComingSoon(String label) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('$label akan hadir segera!')));
  }

  Widget _quickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: FilledButton.tonalIcon(
          icon: Icon(icon),
          label: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13),
          ),
          onPressed: onTap,
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: auth.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                        child: Icon(Icons.person, size: 36, color: Theme.of(context).colorScheme.primary),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _displayName(auth),
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user?.email ?? 'Tidak ada email',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text('Aksi Cepat', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _quickAction(
                        icon: Icons.edit_outlined,
                        label: 'Edit Profil',
                        onTap: () async {
                          final result = await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const EditProfileScreen(),
                            ),
                          );
                          // Refresh data setelah edit jika perlu
                          if (result == true && mounted) {
                            final auth = context.read<AuthProvider>();
                            await auth.getCurrentUser();
                          }
                        },
                      ),
                      _quickAction(
                        icon: Icons.shield_moon_outlined,
                        label: 'Mode Fokus',
                        onTap: () => setState(() => _focusModeEnabled = !_focusModeEnabled),
                      ),
                      _quickAction(
                        icon: Icons.notifications_outlined,
                        label: 'Atur Pengingat',
                        onTap: () => _showComingSoon('Atur Pengingat'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Statistik & Progress', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Total Poin', style: TextStyle(color: Colors.grey)),
                                    Text('${user?.totalPoints ?? 0}',
                                        style: Theme.of(context).textTheme.headlineSmall),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Streak Saat Ini', style: TextStyle(color: Colors.grey)),
                                    Text('${user?.currentStreak ?? 0}',
                                        style: Theme.of(context).textTheme.headlineSmall),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Streak Terpanjang', style: TextStyle(color: Colors.grey)),
                                    Text('${user?.longestStreak ?? 0}',
                                        style: Theme.of(context).textTheme.headlineSmall),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              Chip(
                                avatar: Icon(Icons.flag, color: Theme.of(context).colorScheme.primary, size: 18),
                                label: const Text('Target 3 challenge/minggu'),
                              ),
                              Chip(
                                avatar: Icon(Icons.timer, color: Theme.of(context).colorScheme.primary, size: 18),
                                label: const Text('Limit sosmed 90m/hari'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    child: Column(
                      children: [
                        SwitchListTile(
                          title: const Text('Mode Fokus Harian'),
                          subtitle: const Text('Mute notifikasi sosial saat fokus'),
                          value: _focusModeEnabled,
                          onChanged: (value) => setState(() => _focusModeEnabled = value),
                          secondary: const Icon(Icons.remove_red_eye_outlined),
                        ),
                        const Divider(height: 0),
                        SwitchListTile(
                          title: const Text('Batasi Sosial Media'),
                          subtitle: const Text('Kunci aplikasi saat melebihi batas'),
                          value: _limitSocialEnabled,
                          onChanged: (value) => setState(() => _limitSocialEnabled = value),
                          secondary: const Icon(Icons.phonelink_lock_outlined),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    child: Column(
                      children: [
                        SwitchListTile(
                          title: const Text('Pengingat Check-in'),
                          subtitle: const Text('Kirim notifikasi setiap malam'),
                          value: _reminderCheckInEnabled,
                          onChanged: (value) => setState(() => _reminderCheckInEnabled = value),
                          secondary: const Icon(Icons.notifications_active_outlined),
                        ),
                        const Divider(height: 0),
                        SwitchListTile(
                          title: const Text('Update Komunitas'),
                          subtitle: const Text('Dapatkan highlight komunitas mingguan'),
                          value: _communityUpdatesEnabled,
                          onChanged: (value) => setState(() => _communityUpdatesEnabled = value),
                          secondary: const Icon(Icons.groups_outlined),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    leading: const Icon(Icons.email_outlined),
                    title: const Text('Email'),
                    subtitle: Text(user?.email ?? '-'),
                  ),
                  if (user?.username != null && user!.username!.isNotEmpty)
                    ListTile(
                      leading: const Icon(Icons.person_outline),
                      title: const Text('Username'),
                      subtitle: Text(user.username!),
                    ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.security_outlined),
                    title: const Text('Keamanan & Privasi'),
                    subtitle: const Text('Atur sandi, autentikasi ganda'),
                    onTap: () => _showComingSoon('Keamanan & Privasi'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.help_outline),
                    title: const Text('Pusat Bantuan'),
                    subtitle: const Text('FAQ, kontak tim dukungan'),
                    onTap: () => _showComingSoon('Pusat Bantuan'),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    icon: const Icon(Icons.logout),
                    label: const Text('Keluar dari Akun'),
                    onPressed: auth.isLoading
                        ? null
                        : () async {
                            final success = await context.read<AuthProvider>().signOut();
                            if (!success && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(auth.error ?? 'Gagal logout')),
                              );
                            } else if (context.mounted) {
                              Navigator.of(context).popUntil((route) => route.isFirst);
                            }
                          },
                  ),
                ],
              ),
            ),
    );
  }
}



