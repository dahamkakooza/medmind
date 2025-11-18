import 'package:flutter/material.dart';

class AdherenceChart extends StatelessWidget {
  final String period;
  final List<ChartData> data;

  const AdherenceChart({
    super.key,
    required this.period,
    required this.data,
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
                  'Adherence Trend',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  period,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Chart area
            SizedBox(
              height: 200,
              child: _buildChart(context),
            ),
            
            const SizedBox(height: 16),
            
            // Legend
            _buildLegend(context),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(BuildContext context) {
    if (data.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart,
              size: 48,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 8),
            Text(
              'No data available',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      );
    }

    return CustomPaint(
      size: const Size(double.infinity, 200),
      painter: AdherenceChartPainter(
        data: data,
        primaryColor: Theme.of(context).colorScheme.primary,
        backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
      ),
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildLegendItem(
          context,
          Colors.green,
          'Taken',
        ),
        _buildLegendItem(
          context,
          Colors.orange,
          'Partial',
        ),
        _buildLegendItem(
          context,
          Colors.red,
          'Missed',
        ),
      ],
    );
  }

  Widget _buildLegendItem(BuildContext context, Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class AdherenceChartPainter extends CustomPainter {
  final List<ChartData> data;
  final Color primaryColor;
  final Color backgroundColor;

  AdherenceChartPainter({
    required this.data,
    required this.primaryColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..style = PaintingStyle.fill;

    final barWidth = size.width / data.length * 0.8;
    final barSpacing = size.width / data.length * 0.2;

    for (int i = 0; i < data.length; i++) {
      final x = i * (barWidth + barSpacing) + barSpacing / 2;
      final barHeight = (data[i].percentage / 100) * size.height;
      final y = size.height - barHeight;

      // Draw bar
      paint.color = _getBarColor(data[i].percentage);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, barWidth, barHeight),
          const Radius.circular(4),
        ),
        paint,
      );

      // Draw percentage text
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${data[i].percentage.toInt()}%',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          x + (barWidth - textPainter.width) / 2,
          y - textPainter.height - 4,
        ),
      );
    }
  }

  Color _getBarColor(double percentage) {
    if (percentage >= 90) return Colors.green;
    if (percentage >= 70) return Colors.orange;
    return Colors.red;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

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