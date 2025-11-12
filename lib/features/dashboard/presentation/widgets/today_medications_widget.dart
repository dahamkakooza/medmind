import 'package:flutter/material.dart';
import '../../../medication/domain/entities/medication_entity.dart';
import '../../../medication/presentation/widgets/medication_card.dart';

class TodayMedicationsWidget extends StatelessWidget {
  final List<MedicationEntity> medications;
  final Function(MedicationEntity) onMedicationTaken;

  const TodayMedicationsWidget({
    super.key,
    required this.medications,
    required this.onMedicationTaken,
  });

  @override
  Widget build(BuildContext context) {
    if (medications.isEmpty) {
      return _buildEmptyState(context);
    }

    return Column(
      children: [
        _buildProgressIndicator(context),
        const SizedBox(height: 16),
        ...medications.map((medication) => MedicationCard(
          medication: medication,
          onTap: () => Navigator.pushNamed(
            context,
            '/medication-detail',
            arguments: medication,
          ),
          onTaken: () => onMedicationTaken(medication),
        )),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 48,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 12),
          Text(
            'All done for today!',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'You\'ve taken all your medications',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(BuildContext context) {
    final totalMedications = medications.length;
    final takenMedications = medications.where((med) => med.isTakenToday).length;
    final progress = totalMedications > 0 ? takenMedications / totalMedications : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Today\'s Progress',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$takenMedications of $totalMedications medications taken',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          CircularProgressIndicator(
            value: progress,
            backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}