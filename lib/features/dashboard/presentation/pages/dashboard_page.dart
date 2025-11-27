import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/today_medications_widget.dart';
import '../widgets/adherence_stats_widget.dart';
import '../widgets/quick_actions_widget.dart';
import '../blocs/dashboard_bloc/dashboard_bloc.dart';
import '../blocs/dashboard_bloc/dashboard_event.dart';
import '../blocs/dashboard_bloc/dashboard_state.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/services/pending_dose_tracker.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  void _loadDashboardData() {
    context.read<DashboardBloc>().add(LoadDashboardData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Good morning'),
            Text(
              _getGreeting(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
        actions: [
          _buildNotificationButton(),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading) {
            return const LoadingWidget();
          }

          if (state is DashboardError) {
            return ErrorDisplayWidget(
              message: state.message,
              onRetry: _loadDashboardData,
            );
          }

          if (state is DashboardLoaded) {
            return RefreshIndicator(
              onRefresh: () async => _loadDashboardData(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quick Actions
                    QuickActionsWidget(
                      onAddMedication: () =>
                          Navigator.pushNamed(context, '/add-medication'),
                      onViewMedications: () =>
                          Navigator.pushNamed(context, '/medications'),
                      onViewHistory: () =>
                          Navigator.pushNamed(context, '/adherence-history'),
                    ),
                    const SizedBox(height: 24),

                    // Notification Summary
                    _buildNotificationSummary(),
                    const SizedBox(height: 24),

                    // Today's Medications
                    Text(
                      'Today\'s Medications',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TodayMedicationsWidget(
                      medications: state.todayMedications,
                      onMedicationTaken: (medication) {
                        context.read<DashboardBloc>().add(
                          LogMedicationTakenEvent(medicationId: medication.id),
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Adherence Stats
                    Text(
                      'Your Progress',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    AdherenceStatsWidget(
                      adherenceStats: state.adherenceStats,
                      onViewDetails: () =>
                          Navigator.pushNamed(context, '/adherence-analytics'),
                    ),
                  ],
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildNotificationButton() {
    return FutureBuilder<int>(
      future: _getPendingDoseCount(),
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;

        return Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () async {
                await Navigator.pushNamed(context, '/pending-doses');
                // Refresh count after returning
                setState(() {});
              },
            ),
            if (count > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Text(
                    count > 99 ? '99+' : count.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildNotificationSummary() {
    return FutureBuilder<int>(
      future: _getPendingDoseCount(),
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;

        return Card(
          child: InkWell(
            onTap: () async {
              await Navigator.pushNamed(context, '/pending-doses');
              setState(() {});
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.notifications_active,
                      color: Theme.of(context).primaryColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pending Doses',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          count == 0
                              ? 'All caught up!'
                              : '$count dose${count == 1 ? '' : 's'} need to be taken',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: count > 0
                                    ? Colors.orange[700]
                                    : Colors.grey[600],
                              ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<int> _getPendingDoseCount() async {
    try {
      return await PendingDoseTracker.getPendingDoseCount();
    } catch (e) {
      return 0;
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Let\'s start your day right';
    } else if (hour < 17) {
      return 'Keep up the good work';
    } else {
      return 'Evening medication check';
    }
  }
}
