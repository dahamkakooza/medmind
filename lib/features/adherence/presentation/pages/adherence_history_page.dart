import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/adherence_bloc/adherence_bloc.dart';
import '../blocs/adherence_bloc/adherence_event.dart';
import '../blocs/adherence_bloc/adherence_state.dart';
import '../widgets/adherence_calendar.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';

class AdherenceHistoryPage extends StatefulWidget {
  const AdherenceHistoryPage({super.key});

  @override
  State<AdherenceHistoryPage> createState() => _AdherenceHistoryPageState();
}

class _AdherenceHistoryPageState extends State<AdherenceHistoryPage> {
  DateTime _selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadAdherenceData();
  }

  void _loadAdherenceData() {
    final startDate = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final endDate = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);
    
    context.read<AdherenceBloc>().add(
      GetAdherenceLogsRequested(
        startDate: startDate,
        endDate: endDate,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adherence History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            onPressed: () => Navigator.pushNamed(context, '/adherence-analytics'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Month selector
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => _changeMonth(-1),
                  icon: const Icon(Icons.chevron_left),
                ),
                Text(
                  _getMonthYearString(_selectedMonth),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  onPressed: _selectedMonth.isBefore(DateTime.now()) ? () => _changeMonth(1) : null,
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ),
          
          // Calendar and logs
          Expanded(
            child: BlocBuilder<AdherenceBloc, AdherenceState>(
              builder: (context, state) {
                if (state is AdherenceLoading) {
                  return const LoadingWidget();
                }
                
                if (state is AdherenceError) {
                  return ErrorDisplayWidget(
                    message: state.message,
                    onRetry: _loadAdherenceData,
                  );
                }
                
                if (state is AdherenceLogsLoaded) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Calendar view
                        AdherenceCalendar(
                          selectedMonth: _selectedMonth,
                          adherenceLogs: state.logs,
                          onDateSelected: (date) => _showDayDetails(context, date, state.logs),
                        ),
                        const SizedBox(height: 24),
                        
                        // Monthly summary
                        _buildMonthlySummary(context, state.logs),
                        const SizedBox(height: 16),
                        
                        // Recent logs list
                        _buildRecentLogs(context, state.logs),
                      ],
                    ),
                  );
                }
                
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  void _changeMonth(int delta) {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + delta, 1);
    });
    _loadAdherenceData();
  }

  String _getMonthYearString(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  Widget _buildMonthlySummary(BuildContext context, List<dynamic> logs) {
    final totalDays = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).day;
    final adherentDays = logs.length; // Simplified calculation
    final adherenceRate = (adherentDays / totalDays * 100).round();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly Summary',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem(context, 'Adherence Rate', '$adherenceRate%'),
                _buildSummaryItem(context, 'Days Tracked', '$adherentDays'),
                _buildSummaryItem(context, 'Missed Days', '${totalDays - adherentDays}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRecentLogs(BuildContext context, List<dynamic> logs) {
    if (logs.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No adherence data for this month'),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ...logs.take(5).map((log) => ListTile(
          leading: const Icon(Icons.check_circle, color: Colors.green),
          title: Text('Medication taken'),
          subtitle: Text('Today at 8:00 AM'), // Simplified
          trailing: const Icon(Icons.chevron_right),
        )),
      ],
    );
  }

  void _showDayDetails(BuildContext context, DateTime date, List<dynamic> logs) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Adherence for ${date.day}/${date.month}/${date.year}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            const Text('Medications taken on this day will be shown here'),
          ],
        ),
      ),
    );
  }
}