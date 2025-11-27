import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medmind/features/profile/presentation/blocs/profile_bloc/profile_bloc.dart';
import 'package:medmind/features/profile/presentation/blocs/profile_bloc/profile_event.dart';
import 'package:medmind/features/profile/presentation/blocs/profile_bloc/profile_state.dart';

import '../blocs/profile_bloc/profile_event.dart';
import '../blocs/profile_bloc/profile_state.dart';

class PrivacySecurityPage extends StatefulWidget {
  const PrivacySecurityPage({super.key});

  @override
  State<PrivacySecurityPage> createState() => _PrivacySecurityPageState();
}

class _PrivacySecurityPageState extends State<PrivacySecurityPage> {
  bool _biometricEnabled = false;
  bool _dataBackupEnabled = true;
  bool _analyticsEnabled = true;
  bool _locationEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy & Security'),
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          // Load current preferences if available
          if (state is PreferencesLoaded) {
            _biometricEnabled = state.preferences.biometricAuthEnabled;
            _dataBackupEnabled = state.preferences.dataBackupEnabled;
          }

          return ListView(
            children: [
              // Security Section
              _buildSectionHeader('Security'),
              _buildToggleSetting(
                context,
                icon: Icons.fingerprint,
                title: 'Biometric Authentication',
                subtitle: 'Use fingerprint or face ID to unlock the app',
                value: _biometricEnabled,
                onChanged: (value) {
                  setState(() {
                    _biometricEnabled = value;
                  });
                  context.read<ProfileBloc>().add(
                    UpdateBiometricAuth(enabled: value),
                  );
                },
              ),
              _buildSettingItem(
                context,
                icon: Icons.lock,
                title: 'Change Password',
                subtitle: 'Update your account password',
                onTap: () => _showChangePasswordDialog(context),
              ),
              _buildSettingItem(
                context,
                icon: Icons.security,
                title: 'Two-Factor Authentication',
                subtitle: 'Add an extra layer of security',
                onTap: () => _showTwoFactorDialog(context),
              ),

              // Privacy Section
              _buildSectionHeader('Privacy'),
              _buildToggleSetting(
                context,
                icon: Icons.backup,
                title: 'Data Backup',
                subtitle: 'Automatically backup your health data',
                value: _dataBackupEnabled,
                onChanged: (value) {
                  setState(() {
                    _dataBackupEnabled = value;
                  });
                  context.read<ProfileBloc>().add(
                    UpdateDataBackup(enabled: value),
                  );
                },
              ),
              _buildToggleSetting(
                context,
                icon: Icons.analytics,
                title: 'Analytics & Improvements',
                subtitle: 'Help improve MedMind by sharing usage data',
                value: _analyticsEnabled,
                onChanged: (value) {
                  setState(() {
                    _analyticsEnabled = value;
                  });
                  _showAnalyticsDialog(context, value);
                },
              ),
              _buildToggleSetting(
                context,
                icon: Icons.location_on,
                title: 'Location Services',
                subtitle: 'Use your location for nearby pharmacy features',
                value: _locationEnabled,
                onChanged: (value) {
                  setState(() {
                    _locationEnabled = value;
                  });
                  _showLocationDialog(context, value);
                },
              ),

              // Data Management Section
              _buildSectionHeader('Data Management'),
              _buildActionItem(
                context,
                icon: Icons.download,
                title: 'Export My Data',
                subtitle: 'Download all your personal data',
                onTap: () => _exportUserData(context),
              ),
              _buildActionItem(
                context,
                icon: Icons.delete,
                title: 'Clear All Data',
                color: Colors.red,
                subtitle: 'Delete all your local app data',
                onTap: () => _showClearDataDialog(context),
              ),
              _buildActionItem(
                context,
                icon: Icons.delete_forever,
                title: 'Delete Account',
                color: Colors.red,
                subtitle: 'Permanently delete your account and all data',
                onTap: () => _showDeleteAccountDialog(context),
              ),

              const SizedBox(height: 32),

              // Privacy Policy Links
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Privacy Information',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    _buildPrivacyLink(
                      'Privacy Policy',
                      Icons.privacy_tip,
                          () => _showPrivacyPolicy(context),
                    ),
                    _buildPrivacyLink(
                      'Terms of Service',
                      Icons.description,
                          () => _showTermsOfService(context),
                    ),
                    _buildPrivacyLink(
                      'Data Processing Agreement',
                      Icons.assignment,
                          () => _showDataAgreement(context),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildSettingItem(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required VoidCallback onTap,
      }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildToggleSetting(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required bool value,
        required ValueChanged<bool> onChanged,
      }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
        ),
        onTap: () => onChanged(!value),
      ),
    );
  }

  Widget _buildActionItem(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        Color? color,
        required VoidCallback onTap,
      }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(
          title,
          style: TextStyle(color: color),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: color?.withOpacity(0.7)),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildPrivacyLink(String text, IconData icon, VoidCallback onTap) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, size: 20),
      title: Text(
        text,
        style: const TextStyle(
          color: Colors.blue,
          decoration: TextDecoration.underline,
        ),
      ),
      onTap: onTap,
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('This feature will be available in the next update.'),
            SizedBox(height: 16),
            Text('For now, you can reset your password from the login screen.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showTwoFactorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Two-Factor Authentication'),
        content: const Text('Two-factor authentication adds an extra layer of security to your account. This feature is coming soon.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAnalyticsDialog(BuildContext context, bool enabled) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Analytics & Improvements'),
        content: Text(
          enabled
              ? 'Thank you for helping improve MedMind! Your anonymous usage data helps us make the app better for everyone.'
              : 'You have opted out of analytics. You can enable this anytime to help us improve the app.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showLocationDialog(BuildContext context, bool enabled) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Services'),
        content: Text(
          enabled
              ? 'Location services enabled. This helps us show you nearby pharmacies and healthcare providers.'
              : 'Location services disabled. Some features like finding nearby pharmacies will not be available.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _exportUserData(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Data'),
        content: const Text('This will export all your personal data including medication history, preferences, and profile information.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<ProfileBloc>().add(ExportUserData());
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Data export started. You will be notified when it\'s ready.'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text('This will delete all your local app data including medications, reminders, and preferences. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<ProfileBloc>().add(ClearAllData());
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All local data has been cleared.'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text(
              'Clear Data',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text('This will permanently delete your account and all associated data. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _confirmDeleteAccount(context);
            },
            child: const Text(
              'Delete Account',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Account Deletion'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('This is your final warning. All your data will be:'),
            SizedBox(height: 8),
            Text('• Permanently deleted'),
            Text('• Cannot be recovered'),
            Text('• All medications and history lost'),
            SizedBox(height: 16),
            Text('Type "DELETE" to confirm:'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account deletion feature coming in next update'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: SingleChildScrollView(
          child: Text(
            'MedMind Privacy Policy\n\n'
                'We take your privacy seriously. This policy describes what personal information we collect and how we use it.\n\n'
                'Data Collection:\n'
                '• Basic profile information\n'
                '• Medication and health data you enter\n'
                '• App usage statistics (if enabled)\n\n'
                'Data Usage:\n'
                '• Provide medication reminders\n'
                '• Improve app functionality\n'
                '• Personalize your experience\n\n'
                'We never sell your personal data to third parties.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms of Service'),
        content: SingleChildScrollView(
          child: Text(
            'MedMind Terms of Service\n\n'
                'By using MedMind, you agree to these terms:\n\n'
                '1. You are responsible for the accuracy of the health information you enter.\n'
                '2. MedMind provides reminders but is not a substitute for professional medical advice.\n'
                '3. You must maintain the security of your account credentials.\n'
                '4. We may update these terms with notice to users.\n\n'
                'Please consult healthcare professionals for medical decisions.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDataAgreement(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Data Processing Agreement'),
        content: SingleChildScrollView(
          child: Text(
            'Data Processing Agreement\n\n'
                'This agreement outlines how MedMind processes your personal data in compliance with privacy regulations.\n\n'
                'Your Rights:\n'
                '• Access your personal data\n'
                '• Correct inaccurate data\n'
                '• Request data deletion\n'
                '• Export your data\n'
                '• Opt-out of data processing\n\n'
                'Contact us for any privacy-related concerns.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}