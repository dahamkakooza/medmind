import 'package:flutter/material.dart';

class AdherenceHistoryPage extends StatelessWidget {
  const AdherenceHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adherence History'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHistoryCard(
            date: 'Today',
            taken: 3,
            total: 4,
            percentage: 75,
          ),
          _buildHistoryCard(
            date: 'Yesterday',
            taken: 4,
            total: 4,
            percentage: 100,
          ),
          _buildHistoryCard(
            date: 'Nov 25, 2024',
            taken: 3,
            total: 4,
            percentage: 75,
          ),
          _buildHistoryCard(
            date: 'Nov 24, 2024',
            taken: 2,
            total: 4,
            percentage: 50,
          ),
          _buildHistoryCard(
            date: 'Nov 23, 2024',
            taken: 4,
            total: 4,
            percentage: 100,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard({
    required String date,
    required int taken,
    required int total,
    required int percentage,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    date,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$taken/$total medications taken',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getPercentageColor(percentage),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$percentage%',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getPercentageColor(int percentage) {
    if (percentage >= 90) return Colors.green;
    if (percentage >= 75) return Colors.blue;
    if (percentage >= 50) return Colors.orange;
    return Colors.red;
  }
}