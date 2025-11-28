class DailyCheckInStat {
  final DateTime date;
  final int successCount;
  final int failedCount;
  final int totalMinutes; // Total waktu aktivitas dalam menit

  const DailyCheckInStat({
    required this.date,
    required this.successCount,
    required this.failedCount,
    this.totalMinutes = 0,
  });
}