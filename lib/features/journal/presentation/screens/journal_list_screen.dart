import 'package:flutter/material.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import 'package:provider/provider.dart';

/// Model sederhana untuk catatan mood
class JournalEntry {
  final String id;
  final String? userId;
  final int mood; // 1-5
  final String note;
  final DateTime createdAt;

  JournalEntry({
    required this.id,
    required this.userId,
    required this.mood,
    required this.note,
    required this.createdAt,
  });
}

/// Layar daftar catatan mood
class JournalListScreen extends StatefulWidget {
  const JournalListScreen({super.key});

  @override
  State<JournalListScreen> createState() => _JournalListScreenState();
}

class _JournalListScreenState extends State<JournalListScreen> {
  final List<JournalEntry> _entries = [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // Future integration with Supabase can be placed here.
      // For now, we keep in-memory list. If needed, fetch entries from server.
      await Future.delayed(const Duration(milliseconds: 300));
    } catch (e) {
      _error = 'Gagal memuat catatan: $e';
    }

    setState(() {
      _loading = false;
    });
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 16,
                      width: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 14,
                      width: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _moodLabel(int mood) {
    switch (mood) {
      case 1:
        return 'Sangat Buruk';
      case 2:
        return 'Buruk';
      case 3:
        return 'Biasa saja';
      case 4:
        return 'Baik';
      case 5:
        return 'Sangat Baik';
      default:
        return 'Tidak diketahui';
    }
  }

  IconData _moodIcon(int mood) {
    switch (mood) {
      case 1:
        return Icons.sentiment_very_dissatisfied;
      case 2:
        return Icons.sentiment_dissatisfied;
      case 3:
        return Icons.sentiment_neutral;
      case 4:
        return Icons.sentiment_satisfied;
      case 5:
        return Icons.sentiment_very_satisfied;
      default:
        return Icons.sentiment_neutral;
    }
  }

  Color _moodColor(BuildContext context, int mood) {
    final cs = Theme.of(context).colorScheme;
    switch (mood) {
      case 1:
        return Colors.red.shade400;
      case 2:
        return Colors.orange.shade400;
      case 3:
        return Colors.grey.shade500;
      case 4:
        return Colors.teal.shade500;
      case 5:
        return cs.primary;
      default:
        return Colors.grey.shade500;
    }
  }

  Future<void> _showAddBottomSheet() async {
    int selectedMood = 3;
    final noteController = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final insets = MediaQuery.of(ctx).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.only(bottom: insets),
          child: StatefulBuilder(
            builder: (sheetCtx, setSheetState) {
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.edit_note_outlined),
                          const SizedBox(width: 8),
                          Text(
                            'Catat Mood Hari Ini',
                            style: Theme.of(sheetCtx).textTheme.titleLarge,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Pilih mood kamu:',
                        style: Theme.of(sheetCtx).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: List.generate(5, (i) {
                          final mood = i + 1;
                          final active = selectedMood == mood;
                          return ChoiceChip(
                            selected: active,
                            label: Icon(
                              _moodIcon(mood),
                              color: active ? Colors.white : _moodColor(sheetCtx, mood),
                            ),
                            labelPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                            selectedColor: _moodColor(sheetCtx, mood),
                            onSelected: (_) => setSheetState(() {
                              selectedMood = mood;
                            }),
                          );
                        }),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Tuliskan catatan:',
                        style: Theme.of(sheetCtx).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      CustomTextField(
                        controller: noteController,
                        hint: 'Contoh: Hari ini produktif dan fokus belajar 2 jam',
                        maxLines: 4,
                      ),
                      const SizedBox(height: 16),
                      CustomButton(
                        text: 'Simpan',
                        onPressed: () {
                          final note = noteController.text.trim();
                          if (note.isEmpty) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              const SnackBar(content: Text('Catatan tidak boleh kosong')),
                            );
                            return;
                          }
                          final auth = context.read<AuthProvider>();
                          final entry = JournalEntry(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            userId: auth.currentUser?.id,
                            mood: selectedMood,
                            note: note,
                            createdAt: DateTime.now(),
                          );
                          setState(() {
                            _entries.insert(0, entry);
                          });
                          Navigator.of(ctx).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Catatan mood tersimpan')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Mood'),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary.withOpacity(0.3),
                Theme.of(context).colorScheme.primary.withOpacity(0.1),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddBottomSheet,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Catatan'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadInitial,
        child: ListView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE1D1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.self_improvement, color: Color(0xFFFC4C02)),
                      SizedBox(width: 8),
                      Text('Refleksi Harian'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Luangkan waktu sejenak untuk mengenali perasaanmu dan tuliskan hal penting dari hari ini.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (_loading) _buildLoadingState(),
            if (_error != null) ...[
              Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              const SizedBox(height: 12),
            ],
            if (_entries.isEmpty && !_loading)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F4),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.edit_note, size: 48, color: Color(0xFF9CA3AF)),
                    const SizedBox(height: 8),
                    Text(
                      'Belum ada catatan mood',
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tekan tombol \'Tambah Catatan\' untuk mulai menulis.',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ..._entries.map((e) => _JournalEntryCard(
                  entry: e,
                  moodLabel: _moodLabel(e.mood),
                  moodIcon: _moodIcon(e.mood),
                  moodColor: _moodColor(context, e.mood),
                  onDelete: () {
                    setState(() {
                      _entries.removeWhere((x) => x.id == e.id);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Catatan dihapus')),
                    );
                  },
                )),
          ],
        ),
      ),
    );
  }
}

class _JournalEntryCard extends StatefulWidget {
  final JournalEntry entry;
  final String moodLabel;
  final IconData moodIcon;
  final Color moodColor;
  final VoidCallback onDelete;

  const _JournalEntryCard({
    required this.entry,
    required this.moodLabel,
    required this.moodIcon,
    required this.moodColor,
    required this.onDelete,
  });

  @override
  State<_JournalEntryCard> createState() => _JournalEntryCardState();
}

class _JournalEntryCardState extends State<_JournalEntryCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onLongPress: widget.onDelete,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_hovered ? 0.12 : 0.04),
                blurRadius: _hovered ? 16 : 8,
                offset: Offset(0, _hovered ? 8 : 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: widget.moodColor.withOpacity(0.15),
                child: Icon(widget.moodIcon, color: widget.moodColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.moodLabel,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        Text(
                          _formatDate(widget.entry.createdAt),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(widget.entry.note, style: Theme.of(context).textTheme.bodyLarge),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}