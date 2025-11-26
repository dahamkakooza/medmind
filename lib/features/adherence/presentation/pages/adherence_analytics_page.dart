import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/adherence_bloc/adherence_bloc.dart';
import '../blocs/adherence_bloc/adherence_event.dart';
import '../blocs/adherence_bloc/adherence_state.dart';
import '../widgets/adherence_chart.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';

class AdherenceAnalyticsPage extends StatefulWidget {
  const AdherenceAnalyticsPage({super.key});

  @override
  State<AdherenceAnalyticsPage> createState() => _AdherenceAnalyticsPageState();
}

class _AdherenceAnalyticsPageState extends State<AdherenceAnalyticsPage> {
  String _selectedPeriod = 'Last 30 Days';

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  void _loadAnalytics() {
    context.read<AdherenceBloc>().add(GetAdherenceSummaryRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adherence Analytics'),
        actions: [
          PopupMenuButton<String>(
            initialValue: _selectedPeriod,
            onSelected: (value) {
              setState(() => _selectedPeriod = value);
              _loadAnalytics();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'Last 7 Days', child: Text('Last 7 Days')),
              const PopupMenuItem(value: 'Last 30 Days', child: Text('Last 30 Days')),
              const PopupMenuItem(value: 'Last 3 Months', child: Text('Last 3 Months')),
              const PopupMenuItem(value: 'Last Year', child: Text('Last Year')),
            ],
          ),
        ],
      ),
      body: BlocBuilder<AdherenceBloc, AdherenceState>(
        builder: (context, state) {
          if (state is AdherenceLoading) {
            return const LoadingWidget();
          }

          if (state is AdherenceError) {
            return ErrorDisplayWidget(
              message: state.message,
              onRetry: _loadAnalytics,
            );
          }

          if (state is AdherenceSummaryLoaded) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Period selector
                  _buildPeriodInfo(context),
                  const SizedBox(height: 24),

                  // Key metrics - USING REAL DATA FROM STATE
                  _buildKeyMetrics(context, state),
                  const SizedBox(height: 24),

                  // Adherence chart
                  Text(
                    'Adherence Trend',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  AdherenceChart(
                    period: _selectedPeriod,
                    data: state.chartData,
                  ),
                  const SizedBox(height: 24),

                  // Insights
                  _buildInsights(context, state),
                  const SizedBox(height: 24),

                  // Export options
                  _buildExportOptions(context),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildPeriodInfo(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Analysis Period',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                Text(
                  _selectedPeriod,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyMetrics(BuildContext context, AdherenceSummaryLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Key Metrics',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                context,
                'Overall Adherence',
                '${state.overallAdherence.toStringAsFixed(0)}%', // REAL DATA
                Icons.trending_up,
                _getAdherenceColor(state.overallAdherence),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                context,
                'Current Streak',
                '${state.currentStreak} days', // REAL DATA
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
              child: _buildMetricCard(
                context,
                'Best Streak',
                '${state.bestStreak} days', // REAL DATA
                Icons.emoji_events,
                Colors.amber,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                context,
                'Missed Doses',
                '${state.missedDoses}', // REAL DATA
                Icons.warning_outlined,
                Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(
      BuildContext context,
      String title,
      String value,
      IconData icon,
      Color color,
      ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsights(BuildContext context, AdherenceSummaryLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Insights & Recommendations',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInsightItem(
                  context,
                  Icons.lightbulb_outline,
                  state.overallAdherence >= 80
                      ? 'Great Progress!'
                      : 'Room for Improvement',
                  state.overallAdherence >= 80
                      ? 'You\'ve maintained a ${state.overallAdherence.toStringAsFixed(0)}% adherence rate.'
                      : 'Your current adherence is ${state.overallAdherence.toStringAsFixed(0)}%. Try setting more reminders.',
                  state.overallAdherence >= 80 ? Colors.green : Colors.orange,
                ),
                const Divider(),
                _buildInsightItem(
                  context,
                  Icons.schedule,
                  'Timing Consistency',
                  'Try to take medications at the same time daily for better results.',
                  Colors.blue,
                ),
                const Divider(),
                _buildInsightItem(
                  context,
                  Icons.trending_up,
                  'Streak Performance',
                  state.currentStreak >= 7
                      ? 'Amazing ${state.currentStreak}-day streak! Keep it up.'
                      : 'Build a longer streak by not missing doses.',
                  state.currentStreak >= 7 ? Colors.green : Colors.orange,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInsightItem(
      BuildContext context,
      IconData icon,
      String title,
      String description,
      Color color,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportOptions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Export Data',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  context.read<AdherenceBloc>().add(
                    ExportAdherenceDataRequested(format: 'pdf'),
                  );
                },
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Export PDF'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  context.read<AdherenceBloc>().add(
                    ExportAdherenceDataRequested(format: 'csv'),
                  );
                },
                icon: const Icon(Icons.table_chart),
                label: const Text('Export CSV'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getAdherenceColor(double percentage) {
    if (percentage >= 90) return Colors.green;
    if (percentage >= 70) return Colors.orange;
    return Colors.red;
  }
}