// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../blocs/dashboard_bloc/dashboard_bloc.dart';
// import '../blocs/dashboard_bloc/dashboard_event.dart';
// import '../blocs/dashboard_bloc/dashboard_state.dart';
// import '../widgets/today_medications_widget.dart';
// import '../widgets/adherence_stats_widget.dart';
// import '../widgets/quick_actions_widget.dart';
// import '../../../../core/widgets/loading_widget.dart';
// import '../../../../core/widgets/error_widget.dart';
//
// class DashboardPage extends StatefulWidget {
//   const DashboardPage({super.key});
//
//   @override
//   State<DashboardPage> createState() => _DashboardPageState();
// }
//
// class _DashboardPageState extends State<DashboardPage> {
//   @override
//   void initState() {
//     super.initState();
//     _loadDashboardData();
//   }
//
//   void _loadDashboardData() {
//     context.read<DashboardBloc>().add(LoadDashboardData());
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text('Good morning'),
//             Text(
//               _getGreeting(),
//               style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                 color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.notifications_outlined),
//             onPressed: () => Navigator.pushNamed(context, '/notifications'),
//           ),
//           IconButton(
//             icon: const Icon(Icons.person_outline),
//             onPressed: () => Navigator.pushNamed(context, '/profile'),
//           ),
//         ],
//       ),
//       body: BlocBuilder<DashboardBloc, DashboardState>(
//         builder: (context, state) {
//           if (state is DashboardLoading) {
//             return const LoadingWidget();
//           }
//
//           if (state is DashboardError) {
//             return ErrorDisplayWidget(
//               message: state.message,
//               onRetry: _loadDashboardData,
//             );
//           }
//
//           if (state is DashboardLoaded) {
//             return RefreshIndicator(
//               onRefresh: () async => _loadDashboardData(),
//               child: SingleChildScrollView(
//                 physics: const AlwaysScrollableScrollPhysics(),
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Quick Actions
//                     QuickActionsWidget(
//                       onAddMedication: () => Navigator.pushNamed(context, '/add-medication'),
//                       onViewMedications: () => Navigator.pushNamed(context, '/medications'),
//                       onViewHistory: () => Navigator.pushNamed(context, '/adherence-history'),
//                     ),
//                     const SizedBox(height: 24),
//
//                     // Today's Medications
//                     Text(
//                       'Today\'s Medications',
//                       style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     TodayMedicationsWidget(
//                       medications: state.todayMedications,
//                       onMedicationTaken: (medication) {
//                         context.read<DashboardBloc>().add(
//                           LogMedicationTaken(medicationId: medication.id),
//                         );
//                       },
//                     ),
//                     const SizedBox(height: 24),
//
//                     // Adherence Stats
//                     Text(
//                       'Your Progress',
//                       style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     AdherenceStatsWidget(
//                       adherenceStats: state.adherenceStats,
//                       onViewDetails: () => Navigator.pushNamed(context, '/adherence-analytics'),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           }
//
//           return const SizedBox.shrink();
//         },
//       ),
//     );
//   }
//
//   String _getGreeting() {
//     final hour = DateTime.now().hour;
//     if (hour < 12) {
//       return 'Let\'s start your day right';
//     } else if (hour < 17) {
//       return 'Keep up the good work';
//     } else {
//       return 'Evening medication check';
//     }
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/dashboard_bloc/dashboard_bloc.dart';
import '../blocs/dashboard_bloc/dashboard_event.dart';
import '../blocs/dashboard_bloc/dashboard_state.dart';
import '../widgets/today_medications_widget.dart';
import '../widgets/adherence_stats_widget.dart';
import '../widgets/quick_actions_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/constants/route_constants.dart'; // ADD THIS IMPORT

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
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => Navigator.pushNamed(context, RouteConstants.notifications), // FIXED
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.pushNamed(context, RouteConstants.profile), // FIXED
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
                      onAddMedication: () => Navigator.pushNamed(context, RouteConstants.addMedication), // FIXED
                      onViewMedications: () => Navigator.pushNamed(context, RouteConstants.medicationList), // FIXED
                      onViewHistory: () => Navigator.pushNamed(context, RouteConstants.adherenceHistory), // FIXED
                    ),
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
                          LogMedicationTaken(medicationId: medication.id),
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
                      onViewDetails: () => Navigator.pushNamed(context, RouteConstants.adherenceAnalytics), // FIXED
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