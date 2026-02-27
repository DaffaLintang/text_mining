import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class PieChartWidget extends StatelessWidget {
  const PieChartWidget({
    super.key,
    required this.positifCount,
    required this.negatifCount,
  });

  final int positifCount;
  final int negatifCount;

  @override
  Widget build(BuildContext context) {
    final total = positifCount + negatifCount;
    final positifPct = total > 0
        ? (positifCount / total * 100).toStringAsFixed(1)
        : '0.0';
    final negatifPct = total > 0
        ? (negatifCount / total * 100).toStringAsFixed(1)
        : '0.0';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(18),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          // Stat cards
          Expanded(
            flex: 5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StatBadge(
                  label: 'Positif',
                  count: positifCount,
                  percentage: positifPct,
                  color: const Color(0xFF22C55E),
                  bgColor: const Color(0xFFDCFCE7),
                  icon: Icons.sentiment_satisfied_alt_rounded,
                ),
                const SizedBox(height: 12),
                _StatBadge(
                  label: 'Negatif',
                  count: negatifCount,
                  percentage: negatifPct,
                  color: const Color(0xFFEF4444),
                  bgColor: const Color(0xFFFFE4E4),
                  icon: Icons.sentiment_dissatisfied_rounded,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Pie chart
          SizedBox(
            width: 90,
            height: 90,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: negatifCount.toDouble(),
                    color: const Color(0xFFEF4444),
                    title: '',
                    radius: 38,
                    borderSide: const BorderSide(color: Colors.white, width: 2),
                  ),
                  PieChartSectionData(
                    value: positifCount.toDouble(),
                    color: const Color(0xFF22C55E),
                    title: '',
                    radius: 38,
                    borderSide: const BorderSide(color: Colors.white, width: 2),
                  ),
                ],
                // sectionsSpace: 2,
                // centerSpaceRadius: 18,
                // centerSpaceColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String label;
  final int count;
  final String percentage;
  final Color color;
  final Color bgColor;
  final IconData icon;

  const _StatBadge({
    required this.label,
    required this.count,
    required this.percentage,
    required this.color,
    required this.bgColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
              Text(
                '$count  ($percentage%)',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
