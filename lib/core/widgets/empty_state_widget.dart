import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String description;
  final String? assetPath;
  final IconData? icon;
  final Color? iconColor;
  final double iconSize;
  final VoidCallback? onAction;
  final String? actionText;
  final Widget? actionWidget;
  final bool showAction;

  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.description,
    this.assetPath,
    this.icon,
    this.iconColor,
    this.iconSize = 64,
    this.onAction,
    this.actionText,
    this.actionWidget,
    this.showAction = true,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Visual Element (Image or Icon)
            _buildVisualElement(context),
            const SizedBox(height: 24),
            
            // Title
            Text(
              title,
              style: TextStyles.titleLarge.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            
            // Description
            Text(
              description,
              style: TextStyles.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // Action Button (if provided)
            if (showAction && (actionText != null || actionWidget != null)) 
              _buildActionButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildVisualElement(BuildContext context) {
    if (assetPath != null) {
      return Image.asset(
        assetPath!,
        width: iconSize * 1.5,
        height: iconSize * 1.5,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
      );
    } else if (icon != null) {
      return Icon(
        icon,
        size: iconSize,
        color: iconColor ?? Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
      );
    } else {
      return Container(
        width: iconSize,
        height: iconSize,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.inbox_outlined,
          size: iconSize * 0.6,
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    }
  }

  Widget _buildActionButton(BuildContext context) {
    if (actionWidget != null) {
      return actionWidget!;
    }
    
    return ElevatedButton(
      onPressed: onAction,
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      child: Text(actionText!),
    );
  }
}

// Pre-built Empty State Widgets for Common Scenarios

class NoMedicationsEmptyState extends StatelessWidget {
  final VoidCallback onAddMedication;

  const NoMedicationsEmptyState({
    super.key,
    required this.onAddMedication,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: 'No Medications Added',
      description: 'Start by adding your first medication to track your adherence and receive reminders.',
      icon: Icons.medication_outlined,
      actionText: 'Add Medication',
      onAction: onAddMedication,
      iconColor: AppColors.primary,
    );
  }
}

class NoAdherenceDataEmptyState extends StatelessWidget {
  final VoidCallback? onViewMedications;

  const NoAdherenceDataEmptyState({
    super.key,
    this.onViewMedications,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: 'No Adherence Data',
      description: 'Your adherence statistics will appear here once you start taking your medications.',
      icon: Icons.analytics_outlined,
      actionText: onViewMedications != null ? 'View Medications' : null,
      onAction: onViewMedications,
      iconColor: AppColors.info,
      showAction: onViewMedications != null,
    );
  }
}

class NoSearchResultsEmptyState extends StatelessWidget {
  final String searchQuery;

  const NoSearchResultsEmptyState({
    super.key,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: 'No Results Found',
      description: 'No medications found for "$searchQuery". Try adjusting your search terms.',
      icon: Icons.search_off_outlined,
      iconColor: AppColors.grey500,
      showAction: false,
    );
  }
}

class NoNotificationsEmptyState extends StatelessWidget {
  const NoNotificationsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: 'No Notifications',
      description: 'You don\'t have any notifications yet. Reminders and updates will appear here.',
      icon: Icons.notifications_none_outlined,
      iconColor: AppColors.grey500,
      showAction: false,
    );
  }
}

class OfflineEmptyState extends StatelessWidget {
  final VoidCallback onRetry;

  const OfflineEmptyState({
    super.key,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: 'No Internet Connection',
      description: 'Please check your internet connection and try again.',
      icon: Icons.wifi_off_outlined,
      actionText: 'Retry',
      onAction: onRetry,
      iconColor: AppColors.warning,
    );
  }
}

class ErrorEmptyState extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;

  const ErrorEmptyState({
    super.key,
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: 'Something Went Wrong',
      description: errorMessage,
      icon: Icons.error_outline_outlined,
      actionText: 'Try Again',
      onAction: onRetry,
      iconColor: AppColors.error,
    );
  }
}

class NoUpcomingMedicationsEmptyState extends StatelessWidget {
  final VoidCallback onAddMedication;

  const NoUpcomingMedicationsEmptyState({
    super.key,
    required this.onAddMedication,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: 'No Medications Scheduled',
      description: 'You don\'t have any medications scheduled for today. Add medications to see them here.',
      icon: Icons.calendar_today_outlined,
      actionText: 'Add Medication',
      onAction: onAddMedication,
      iconColor: AppColors.success,
    );
  }
}

class NoHistoryEmptyState extends StatelessWidget {
  final VoidCallback onViewMedications;

  const NoHistoryEmptyState({
    super.key,
    required this.onViewMedications,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      title: 'No History Yet',
      description: 'Your medication history will appear here once you start tracking your doses.',
      icon: Icons.history_outlined,
      actionText: 'View Medications',
      onAction: onViewMedications,
      iconColor: AppColors.secondary,
    );
  }
}

// Customizable Empty State with Additional Options

class CustomEmptyState extends StatelessWidget {
  final String title;
  final String description;
  final Widget? image;
  final IconData? icon;
  final Color? iconColor;
  final double iconSize;
  final List<Widget> actions;
  final Widget? footer;

  const CustomEmptyState({
    super.key,
    required this.title,
    required this.description,
    this.image,
    this.icon,
    this.iconColor,
    this.iconSize = 80,
    this.actions = const [],
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Visual Element
            if (image != null) image!,
            if (icon != null && image == null)
              Icon(
                icon,
                size: iconSize,
                color: iconColor ?? Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            const SizedBox(height: 24),
            
            // Title
            Text(
              title,
              style: TextStyles.headlineSmall.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            
            // Description
            Text(
              description,
              style: TextStyles.bodyLarge.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // Actions
            if (actions.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: actions
                    .map((action) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: action,
                        ))
                    .toList(),
              ),
            
            // Footer
            if (footer != null) ...[
              const SizedBox(height: 16),
              footer!,
            ],
          ],
        ),
      ),
    );
  }
}

// Loading Empty State (for skeleton loading)

class LoadingEmptyState extends StatelessWidget {
  final String title;
  final String description;

  const LoadingEmptyState({
    super.key,
    this.title = 'Loading...',
    this.description = 'Please wait while we load your data',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Loading Icon
            SizedBox(
              width: 64,
              height: 64,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Title
            Text(
              title,
              style: TextStyles.titleLarge.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            
            // Description
            Text(
              description,
              style: TextStyles.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
