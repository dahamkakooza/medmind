import 'package:flutter/material.dart';

// Simple ChartData model for adherence charts
class ChartData {
  final String label;
  final double percentage;
  final DateTime date;

  ChartData({
    required this.label,
    required this.percentage,
    required this.date,
  });
}

// Simple placeholder chart widget
class AdherenceChart extends StatelessWidget {
  final String period;
  final List<ChartData> data;

  const AdherenceChart({super.key, required this.period, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart,
            size: 60,
            color: Theme.of(context).primaryColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Adherence Chart ($period)',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            '${data.length} data points',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          const Text(
            'Chart visualization coming soon!',
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
