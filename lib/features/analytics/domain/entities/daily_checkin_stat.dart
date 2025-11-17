class DailyCheckInStat {
  final DateTime date;
  final int successCount;
  final int failedCount;

  const DailyCheckInStat({
    required this.date,
    required this.successCount,
    required this.failedCount,
  });
}