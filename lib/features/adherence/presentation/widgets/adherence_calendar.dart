import 'package:flutter/material.dart';

class AdherenceCalendar extends StatelessWidget {
  final DateTime selectedMonth;
  final List<dynamic> adherenceLogs;
  final Function(DateTime) onDateSelected;

  const AdherenceCalendar({
    super.key,
    required this.selectedMonth,
    required this.adherenceLogs,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 16),
            _buildWeekdayHeaders(context),
            const SizedBox(height: 8),
            _buildCalendarGrid(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.calendar_month,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Text(
          'Adherence Calendar',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildWeekdayHeaders(BuildContext context) {
    const weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    
    return Row(
      children: weekdays.map((day) => Expanded(
        child: Center(
          child: Text(
            day,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildCalendarGrid(BuildContext context) {
    final firstDayOfMonth = DateTime(selectedMonth.year, selectedMonth.month, 1);
    final lastDayOfMonth = DateTime(selectedMonth.year, selectedMonth.month + 1, 0);
    final firstDayWeekday = firstDayOfMonth.weekday % 7;
    final daysInMonth = lastDayOfMonth.day;
    
    final List<Widget> dayWidgets = [];
    
    // Add empty cells for days before the first day of the month
    for (int i = 0; i < firstDayWeekday; i++) {
      dayWidgets.add(const SizedBox.shrink());
    }
    
    // Add day cells
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(selectedMonth.year, selectedMonth.month, day);
      dayWidgets.add(_buildDayCell(context, date));
    }
    
    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: dayWidgets,
    );
  }

  Widget _buildDayCell(BuildContext context, DateTime date) {
    final isToday = _isSameDay(date, DateTime.now());
    final isFuture = date.isAfter(DateTime.now());
    final adherenceStatus = _getAdherenceStatus(date);
    
    Color? backgroundColor;
    Color? textColor;
    
    if (isFuture) {
      backgroundColor = Colors.grey[100];
      textColor = Colors.grey[400];
    } else {
      switch (adherenceStatus) {
        case AdherenceStatus.taken:
          backgroundColor = Colors.green[100];
          textColor = Colors.green[800];
          break;
        case AdherenceStatus.missed:
          backgroundColor = Colors.red[100];
          textColor = Colors.red[800];
          break;
        case AdherenceStatus.partial:
          backgroundColor = Colors.orange[100];
          textColor = Colors.orange[800];
          break;
        case AdherenceStatus.none:
          backgroundColor = Colors.grey[50];
          textColor = Theme.of(context).colorScheme.onSurface;
          break;
      }
    }
    
    if (isToday) {
      backgroundColor = Theme.of(context).colorScheme.primary.withOpacity(0.2);
      textColor = Theme.of(context).colorScheme.primary;
    }
    
    return GestureDetector(
      onTap: isFuture ? null : () => onDateSelected(date),
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: isToday ? Border.all(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ) : null,
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                '${date.day}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: textColor,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (adherenceStatus != AdherenceStatus.none && !isFuture)
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _getStatusColor(adherenceStatus),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  AdherenceStatus _getAdherenceStatus(DateTime date) {
    // Simplified logic - in real implementation, check against adherenceLogs
    final random = date.day % 4;
    switch (random) {
      case 0:
        return AdherenceStatus.taken;
      case 1:
        return AdherenceStatus.missed;
      case 2:
        return AdherenceStatus.partial;
      default:
        return AdherenceStatus.none;
    }
  }

  Color _getStatusColor(AdherenceStatus status) {
    switch (status) {
      case AdherenceStatus.taken:
        return Colors.green;
      case AdherenceStatus.missed:
        return Colors.red;
      case AdherenceStatus.partial:
        return Colors.orange;
      case AdherenceStatus.none:
        return Colors.grey;
    }
  }
}

enum AdherenceStatus {
  taken,
  missed,
  partial,
  none,
}