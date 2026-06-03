import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class UsageGraph extends StatelessWidget {
  final List<double> values;
  final Color color;

  UsageGraph({super.key, required this.values, required this.color});

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) return const SizedBox.shrink();

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: 30, // Show last 30 points
        minY: 0,
        maxY: 100,
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(values.length, (i) => FlSpot(i.toDouble(), values[i])),
            isCurved: true,
            color: color,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: color.withOpacity(0.05),
            ),
          ),
        ],
      ),
    );
  }
}
