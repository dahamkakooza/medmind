import 'package:flutter/material.dart';
import '../../domain/entities/adherence_entity.dart';

class AdherenceStatsWidget extends StatelessWidget {
  final AdherenceEntity adherenceStats;
  final VoidCallback onViewDetails;

  const AdherenceStatsWidget({
    super.key,
    required this.adherenceStats,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Adherence Overview',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: onViewDetails,
                  child: const Text('View Details'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Weekly adherence percentage
            _buildAdherenceCircle(context),
            const SizedBox(height: 20),

            // Stats grid
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'This Week',
                    '${adherenceStats.weeklyPercentage.toStringAsFixed(0)}%',
                    Icons.calendar_view_week,
                    _getAdherenceColor(adherenceStats.weeklyPercentage),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Streak',
                    '${adherenceStats.currentStreak} days',
                    Icons.local_fire_department,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'This Month',
                    '${adherenceStats.monthlyPercentage.toStringAsFixed(0)}%',
                    Icons.calendar_month,
                    _getAdherenceColor(adherenceStats.monthlyPercentage),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Total Taken',
                    '${adherenceStats.totalTaken}',
                    Icons.check_circle,
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdherenceCircle(BuildContext context) {
    final percentage = adherenceStats.weeklyPercentage;
    final color = _getAdherenceColor(percentage);

    return Center(
      child: SizedBox(
        width: 120,
        height: 120,
        child: Stack(
          children: [
            CircularProgressIndicator(
              value: percentage / 100,
              strokeWidth: 8,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${percentage.toStringAsFixed(0)}%',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    'This Week',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getAdherenceColor(double percentage) {
    if (percentage >= 90) return Colors.green;
    if (percentage >= 70) return Colors.orange;
    return Colors.red;
  }
}
