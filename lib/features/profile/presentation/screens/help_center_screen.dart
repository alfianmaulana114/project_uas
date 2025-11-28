import 'package:flutter/material.dart';

/// Screen untuk Pusat Bantuan dengan FAQ
class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final List<FAQItem> _faqs = [
    FAQItem(
      question: 'Apa itu Social Detox?',
      answer:
          'Social Detox adalah aplikasi yang membantu Anda mengurangi penggunaan media sosial secara bertahap melalui challenge, tracking, dan reward system. Aplikasi ini dirancang untuk membantu Anda mengontrol waktu yang dihabiskan di media sosial.',
      category: 'Umum',
    ),
    FAQItem(
      question: 'Bagaimana cara memulai challenge?',
      answer:
          'Untuk memulai challenge, buka tab "Challenge" di bottom navigation, pilih challenge yang ingin Anda ikuti, lalu tekan tombol "Mulai Challenge". Anda bisa memilih challenge berdasarkan kategori seperti Social Media, Olahraga, Bersosialisasi, atau Membaca Buku.',
      category: 'Challenge',
    ),
    FAQItem(
      question: 'Bagaimana sistem poin bekerja?',
      answer:
          'Anda mendapatkan poin dengan menyelesaikan challenge, melakukan check-in harian, dan mempertahankan streak. Poin yang terkumpul bisa ditukar dengan voucher atau hadiah di tab "Reward".',
      category: 'Reward',
    ),
    FAQItem(
      question: 'Apa itu streak dan bagaimana cara mempertahankannya?',
      answer:
          'Streak adalah jumlah hari berturut-turut Anda berhasil melakukan check-in. Untuk mempertahankan streak, pastikan Anda melakukan check-in setiap hari. Jika melewatkan satu hari, streak akan kembali ke 0.',
      category: 'Challenge',
    ),
    FAQItem(
      question: 'Bagaimana cara check-in harian?',
      answer:
          'Check-in harian dilakukan di halaman Challenge. Jika Anda memiliki challenge aktif, akan ada tombol "Mark Success" yang bisa Anda tekan setiap hari setelah menyelesaikan target challenge hari tersebut.',
      category: 'Challenge',
    ),
    FAQItem(
      question: 'Bisakah saya memiliki lebih dari satu challenge aktif?',
      answer:
          'Ya, Anda bisa memiliki beberapa challenge aktif sekaligus, asalkan challenge tersebut dari kategori yang berbeda. Misalnya, Anda bisa memiliki challenge Social Media dan Olahraga secara bersamaan.',
      category: 'Challenge',
    ),
    FAQItem(
      question: 'Bagaimana cara menukar poin dengan reward?',
      answer:
          'Buka tab "Reward", pilih reward yang ingin Anda tukar, lalu tekan tombol "Tukar Sekarang". Pastikan poin Anda cukup untuk reward yang dipilih. Setelah berhasil, reward akan ditambahkan ke riwayat penukaran Anda.',
      category: 'Reward',
    ),
    FAQItem(
      question: 'Apa itu catatan mood?',
      answer:
          'Catatan mood adalah fitur untuk mencatat perasaan dan refleksi harian Anda. Fitur ini membantu Anda melacak perubahan mood seiring dengan progress digital detox Anda. Catatan mood tersimpan di Supabase dan tidak akan hilang.',
      category: 'Journal',
    ),
    FAQItem(
      question: 'Bagaimana cara mengubah password?',
      answer:
          'Buka tab "Profil", pilih "Keamanan & Privasi", lalu pilih "Ubah Password". Masukkan password saat ini dan password baru, lalu konfirmasi password baru Anda.',
      category: 'Akun',
    ),
    FAQItem(
      question: 'Bagaimana cara mengatur pengingat?',
      answer:
          'Buka tab "Profil", tekan tombol "Atur Pengingat" di bagian Aksi Cepat. Di sana Anda bisa mengatur waktu pengingat untuk check-in harian, target harian, dan pengingat lainnya.',
      category: 'Pengaturan',
    ),
    FAQItem(
      question: 'Data saya aman?',
      answer:
          'Ya, semua data Anda disimpan dengan aman di Supabase dengan enkripsi. Kami menggunakan Row Level Security (RLS) untuk memastikan hanya Anda yang bisa mengakses data Anda sendiri.',
      category: 'Keamanan',
    ),
    FAQItem(
      question: 'Bagaimana cara menghapus akun?',
      answer:
          'Untuk menghapus akun, silakan hubungi tim dukungan melalui email. Proses penghapusan akun memerlukan verifikasi untuk keamanan.',
      category: 'Akun',
    ),
  ];

  String _selectedCategory = 'Semua';

  List<String> get _categories {
    final categories = _faqs.map((faq) => faq.category).toSet().toList();
    categories.sort();
    return ['Semua', ...categories];
  }

  List<FAQItem> get _filteredFAQs {
    if (_selectedCategory == 'Semua') {
      return _faqs;
    }
    return _faqs.where((faq) => faq.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pusat Bantuan'),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari pertanyaan...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
            ),
          ),

          // Category Filter
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedCategory = category);
                    },
                    selectedColor: Theme.of(context).colorScheme.primaryContainer,
                    checkmarkColor: Theme.of(context).colorScheme.primary,
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // FAQ List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredFAQs.length,
              itemBuilder: (context, index) {
                return _FAQCard(faq: _filteredFAQs[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class FAQItem {
  final String question;
  final String answer;
  final String category;

  FAQItem({
    required this.question,
    required this.answer,
    required this.category,
  });
}

class _FAQCard extends StatefulWidget {
  final FAQItem faq;

  const _FAQCard({required this.faq});

  @override
  State<_FAQCard> createState() => _FAQCardState();
}

class _FAQCardState extends State<_FAQCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Icon(
          Icons.help_outline,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(
          widget.faq.question,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Chip(
            label: Text(
              widget.faq.category,
              style: const TextStyle(fontSize: 11),
            ),
            padding: EdgeInsets.zero,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
        ),
        trailing: Icon(
          _isExpanded ? Icons.expand_less : Icons.expand_more,
          color: Theme.of(context).colorScheme.primary,
        ),
        onExpansionChanged: (expanded) {
          setState(() => _isExpanded = expanded);
        },
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              widget.faq.answer,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.6,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

