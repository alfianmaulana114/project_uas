import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/daily_checkin_stat.dart';

class CheckinBarChart extends StatelessWidget {
  final List<DailyCheckInStat> data;
  const CheckinBarChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= data.length) return const SizedBox.shrink();
                  final d = data[i].date;
                  return Text('${d.day}/${d.month}', style: Theme.of(context).textTheme.labelSmall);
                },
                reservedSize: 30,
              ),
            ),
          ),
          gridData: FlGridData(show: true),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(data.length, (i) {
            final item = data[i];
            return BarChartGroupData(
              x: i,
              barsSpace: 4,
              barRods: [
                BarChartRodData(
                  toY: item.successCount.toDouble(),
                  color: Colors.green.shade500,
                  width: 10,
                ),
                BarChartRodData(
                  toY: item.failedCount.toDouble(),
                  color: Colors.red.shade400,
                  width: 10,
                ),
              ],
            );
          }),
          maxY: _calcMaxY(data),
        ),
        swapAnimationDuration: const Duration(milliseconds: 250),
      ),
    );
  }

  double _calcMaxY(List<DailyCheckInStat> d) {
    var max = 1.0;
    for (final x in d) {
      max = [max, x.successCount.toDouble(), x.failedCount.toDouble()].reduce((a, b) => a > b ? a : b);
    }
    return (max + 1).clamp(2, 10);
  }
}