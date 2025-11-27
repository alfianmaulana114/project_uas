import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../domain/entities/reward_item.dart';
import '../../domain/entities/reward_redemption.dart';

/// Reward Screen
/// Screen untuk menukar poin dengan voucher atau hadiah fisik
/// Mengikuti desain Figma dengan tema Strava
class RewardScreen extends StatefulWidget {
  const RewardScreen({super.key});

  @override
  State<RewardScreen> createState() => _RewardScreenState();
}

class _RewardScreenState extends State<RewardScreen> {
  String _selectedCategory = 'semua'; // 'semua', 'voucher', 'hadiah'

  // Mock data untuk reward items
  final List<RewardItem> _mockRewards = [
    RewardItem(
      id: '1',
      name: 'Voucher Starbucks',
      description: 'Voucher senilai Rp 50.000',
      category: 'voucher',
      pointsRequired: 500,
      stock: 25,
      icon: 'coffee',
    ),
    RewardItem(
      id: '2',
      name: 'Voucher Grab Food',
      description: 'Voucher senilai Rp 75.000',
      category: 'voucher',
      pointsRequired: 750,
      stock: 15,
      icon: 'restaurant',
    ),
    RewardItem(
      id: '3',
      name: 'Voucher Tokopedia',
      description: 'Voucher senilai Rp 100.000',
      category: 'voucher',
      pointsRequired: 1000,
      stock: 20,
      icon: 'shopping_cart',
    ),
    RewardItem(
      id: '4',
      name: 'Wireless Earbuds',
      description: 'TWS Bluetooth 5.0',
      category: 'hadiah',
      pointsRequired: 2500,
      stock: 5,
      icon: 'headphones',
    ),
    RewardItem(
      id: '5',
      name: 'Smart Watch',
      description: 'Fitness Tracker',
      category: 'hadiah',
      pointsRequired: 3500,
      stock: 3,
      icon: 'watch',
    ),
    RewardItem(
      id: '6',
      name: 'Power Bank 10000mAh',
      description: 'Fast Charging',
      category: 'hadiah',
      pointsRequired: 1800,
      stock: 8,
      icon: 'battery_charging_full',
    ),
    RewardItem(
      id: '7',
      name: 'Voucher Shopee',
      description: 'Voucher senilai Rp 30.000',
      category: 'voucher',
      pointsRequired: 300,
      stock: 30,
      icon: 'shopping_bag',
    ),
  ];

  // Mock data untuk riwayat penukaran
  final List<RewardRedemption> _mockRedemptions = [
    RewardRedemption(
      id: '1',
      userId: 'user1',
      rewardItemId: '1',
      rewardName: 'Voucher Starbucks',
      pointsUsed: 500,
      status: 'completed',
      redeemedAt: DateTime(2025, 11, 20),
      completedAt: DateTime(2025, 11, 20),
    ),
    RewardRedemption(
      id: '2',
      userId: 'user1',
      rewardItemId: '2',
      rewardName: 'Voucher Grab Food',
      pointsUsed: 750,
      status: 'completed',
      redeemedAt: DateTime(2025, 11, 15),
      completedAt: DateTime(2025, 11, 15),
    ),
    RewardRedemption(
      id: '3',
      userId: 'user1',
      rewardItemId: '3',
      rewardName: 'Voucher Tokopedia',
      pointsUsed: 1000,
      status: 'processing',
      redeemedAt: DateTime(2025, 11, 10),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    final userPoints = user?.totalPoints ?? 0;

    final filteredRewards = _selectedCategory == 'semua'
        ? _mockRewards
        : _mockRewards.where((r) => r.category == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _buildHeader(context, user),
          ),
          SliverToBoxAdapter(
            child: _buildPointsCard(context, userPoints),
          ),
          SliverToBoxAdapter(
            child: _buildCategoryFilter(context),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Katalog Hadiah',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (filteredRewards.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 64,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Tidak ada reward tersedia',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return Padding(
                    padding: EdgeInsets.fromLTRB(
                      20,
                      0,
                      20,
                      index == filteredRewards.length - 1 ? 16 : 12,
                    ),
                    child: _RewardCard(
                      reward: filteredRewards[index],
                      userPoints: userPoints,
                      onRedeem: () => _handleRedeem(context, filteredRewards[index], userPoints),
                    ),
                  );
                },
                childCount: filteredRewards.length,
              ),
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Row(
                children: [
                  Icon(
                    Icons.history,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Riwayat Penukaran',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return Padding(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    0,
                    20,
                    index == _mockRedemptions.length - 1 ? 16 : 12,
                  ),
                  child: _RedemptionHistoryCard(
                    redemption: _mockRedemptions[index],
                  ),
                );
              },
              childCount: _mockRedemptions.length,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: _TipsCard(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, user) {
    final streak = user?.currentStreak ?? 0;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
          ],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Social Detox',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Kontrol sosial media Anda',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$streak hari',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPointsCard(BuildContext context, int userPoints) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Poin Saya',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        userPoints.toString(),
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.star_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ],
                  ),
                ],
              ),
              Icon(
                Icons.card_giftcard_outlined,
                color: Colors.white.withOpacity(0.3),
                size: 64,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Dapatkan poin dengan mencapai target harian dan mempertahankan streak!',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: _CategoryChip(
              label: 'Semua',
              icon: Icons.apps,
              isSelected: _selectedCategory == 'semua',
              onTap: () => setState(() => _selectedCategory = 'semua'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _CategoryChip(
              label: 'Voucher',
              icon: Icons.receipt_long,
              isSelected: _selectedCategory == 'voucher',
              onTap: () => setState(() => _selectedCategory = 'voucher'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _CategoryChip(
              label: 'Hadiah',
              icon: Icons.card_giftcard,
              isSelected: _selectedCategory == 'hadiah',
              onTap: () => setState(() => _selectedCategory = 'hadiah'),
            ),
          ),
        ],
      ),
    );
  }

  void _handleRedeem(BuildContext context, RewardItem reward, int userPoints) {
    if (userPoints < reward.pointsRequired) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Poin tidak cukup. Dibutuhkan ${reward.pointsRequired} poin.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    if (reward.stock <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Stok habis.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Tukar Reward'),
        content: Text(
          'Apakah Anda yakin ingin menukar ${reward.pointsRequired} poin untuk ${reward.name}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement actual redemption logic
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${reward.name} berhasil ditukar!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Tukar'),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outlineVariant,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? Colors.white
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RewardCard extends StatelessWidget {
  final RewardItem reward;
  final int userPoints;
  final VoidCallback onRedeem;

  const _RewardCard({
    required this.reward,
    required this.userPoints,
    required this.onRedeem,
  });

  IconData _getIcon(String? iconName) {
    switch (iconName) {
      case 'coffee':
        return Icons.coffee;
      case 'restaurant':
        return Icons.restaurant;
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'headphones':
        return Icons.headphones;
      case 'watch':
        return Icons.watch;
      case 'battery_charging_full':
        return Icons.battery_charging_full;
      case 'shopping_bag':
        return Icons.shopping_bag;
      default:
        return Icons.card_giftcard;
    }
  }

  Color _getIconColor(BuildContext context, String category) {
    if (category == 'voucher') {
      return Colors.purple.shade300;
    }
    return Colors.green.shade300;
  }

  @override
  Widget build(BuildContext context) {
    final canRedeem = userPoints >= reward.pointsRequired && reward.stock > 0;
    final iconColor = _getIconColor(context, reward.category);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getIcon(reward.icon),
                  color: iconColor,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reward.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (reward.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        reward.description!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star_rounded,
                                size: 14,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${reward.pointsRequired}',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Stok: ${reward.stock}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              icon: Icon(canRedeem ? Icons.card_giftcard : Icons.lock),
              label: Text(canRedeem ? 'Tukar Sekarang' : 'Poin Tidak Cukup'),
              style: FilledButton.styleFrom(
                backgroundColor: canRedeem
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                foregroundColor: canRedeem
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: canRedeem ? onRedeem : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _RedemptionHistoryCard extends StatelessWidget {
  final RewardRedemption redemption;

  const _RedemptionHistoryCard({required this.redemption});

  Color _getStatusColor(BuildContext context, String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'processing':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Theme.of(context).colorScheme.onSurfaceVariant;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'completed':
        return Icons.check_circle;
      case 'processing':
        return Icons.access_time;
      case 'pending':
        return Icons.pending;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${_getMonthName(date.month)} ${date.year}';
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(context, redemption.status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  redemption.rewardName,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(redemption.redeemedAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '-${redemption.pointsUsed} pts',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getStatusIcon(redemption.status),
                    size: 16,
                    color: statusColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    redemption.status == 'completed'
                        ? 'Selesai'
                        : redemption.status == 'processing'
                            ? 'Proses'
                            : redemption.status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TipsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Tips Kumpulkan Poin',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _TipItem(
            text: 'Konsisten capai target harian untuk bonus poin',
          ),
          _TipItem(
            text: 'Pertahankan streak untuk poin multiplier',
          ),
          _TipItem(
            text: 'Unlock semua achievement untuk bonus besar',
          ),
          _TipItem(
            text: 'Blokir lebih banyak app untuk extra poin',
          ),
        ],
      ),
    );
  }
}

class _TipItem extends StatelessWidget {
  final String text;

  const _TipItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
