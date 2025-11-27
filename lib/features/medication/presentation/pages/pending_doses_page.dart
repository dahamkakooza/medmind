import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/pending_dose_tracker.dart';
import '../../../adherence/domain/entities/adherence_log_entity.dart';
import '../../../adherence/presentation/blocs/adherence_bloc/adherence_bloc.dart';
import '../../../adherence/presentation/blocs/adherence_bloc/adherence_event.dart';

class PendingDosesPage extends StatefulWidget {
  const PendingDosesPage({super.key});

  @override
  State<PendingDosesPage> createState() => _PendingDosesPageState();
}

class _PendingDosesPageState extends State<PendingDosesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pending Doses')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: PendingDoseTracker.getPendingDoses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final pendingDoses = snapshot.data ?? {};

          if (pendingDoses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 80,
                    color: Colors.green[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'All Caught Up!',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No pending doses to take',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          // Convert to list and sort by scheduled time
          final dosesList = pendingDoses.entries.map((entry) {
            return {'id': entry.key, ...entry.value};
          }).toList();

          dosesList.sort((a, b) {
            final timeA = DateTime.parse(a['scheduledTime']);
            final timeB = DateTime.parse(b['scheduledTime']);
            return timeA.compareTo(timeB);
          });

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: dosesList.length,
            itemBuilder: (context, index) {
              final dose = dosesList[index];
              final scheduledTime = DateTime.parse(dose['scheduledTime']);
              final now = DateTime.now();
              final isOverdue = now.difference(scheduledTime).inHours > 2;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isOverdue
                          ? Colors.red.withOpacity(0.1)
                          : Colors.orange.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.medication,
                      color: isOverdue ? Colors.red : Colors.orange,
                    ),
                  ),
                  title: Text(
                    dose['medicationName'],
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('Scheduled: ${_formatTime(scheduledTime)}'),
                      if (isOverdue)
                        Text(
                          'Overdue by ${_getOverdueText(scheduledTime, now)}',
                          style: TextStyle(
                            color: Colors.red[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'taken') {
                        await _markAsTaken(Map<String, dynamic>.from(dose));
                      } else if (value == 'missed') {
                        await _markAsMissed(Map<String, dynamic>.from(dose));
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'taken',
                        child: Row(
                          children: [
                            Icon(Icons.check, color: Colors.green),
                            SizedBox(width: 8),
                            Text('Mark as Taken'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'missed',
                        child: Row(
                          children: [
                            Icon(Icons.close, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Mark as Missed'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _markAsTaken(Map<String, dynamic> dose) async {
    final scheduledTime = DateTime.parse(dose['scheduledTime']);
    final now = DateTime.now();

    // Log as taken
    final log = AdherenceLogEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      medicationId: dose['medicationId'],
      userId: '',
      scheduledTime: scheduledTime,
      takenTime: now,
      status: AdherenceStatus.taken,
      createdAt: now,
    );

    context.read<AdherenceBloc>().add(LogMedicationTakenEvent(log: log));

    // Remove from pending
    await PendingDoseTracker.removePendingDose(
      medicationId: dose['medicationId'],
      scheduledTime: scheduledTime,
    );

    setState(() {});

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${dose['medicationName']} marked as taken'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _markAsMissed(Map<String, dynamic> dose) async {
    final scheduledTime = DateTime.parse(dose['scheduledTime']);
    final now = DateTime.now();

    // Log as missed
    final log = AdherenceLogEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      medicationId: dose['medicationId'],
      userId: '',
      scheduledTime: scheduledTime,
      takenTime: null,
      status: AdherenceStatus.missed,
      createdAt: now,
    );

    context.read<AdherenceBloc>().add(LogMedicationTakenEvent(log: log));

    // Remove from pending
    await PendingDoseTracker.removePendingDose(
      medicationId: dose['medicationId'],
      scheduledTime: scheduledTime,
    );

    setState(() {});

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${dose['medicationName']} marked as missed'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _getOverdueText(DateTime scheduled, DateTime now) {
    final diff = now.difference(scheduled);
    if (diff.inDays > 0) {
      return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''}';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''}';
    } else {
      return '${diff.inMinutes} minute${diff.inMinutes > 1 ? 's' : ''}';
    }
  }
}
