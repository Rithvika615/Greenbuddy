
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/growth_log.dart';
import '../utils/app_colors.dart';

class GrowthChart extends StatelessWidget {
  final List<GrowthLog> logs;

  const GrowthChart({
    super.key,
    required this.logs,
  });

  @override
  Widget build(BuildContext context) {
    final heightLogs = logs
        .where((log) => log.heightCm != null)
        .toList()
      ..sort((a, b) => a.recordedOn.compareTo(b.recordedOn));

    if (heightLogs.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            'Add plant height records to view your growth chart.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final spots = heightLogs.asMap().entries.map((entry) {
      return FlSpot(
        entry.key.toDouble(),
        entry.value.heightCm!,
      );
    }).toList();

    final maxHeight = heightLogs
        .map((log) => log.heightCm!)
        .reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Height Growth',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGreen,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 220,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: maxHeight < 5 ? 5 : maxHeight * 1.2,
                  gridData: const FlGridData(show: true),
                  borderData: FlBorderData(show: false),
                  titlesData: const FlTitlesData(
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: AppColors.primary,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.lightGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Measurements recorded over time (cm)',
              style: TextStyle(color: AppColors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
