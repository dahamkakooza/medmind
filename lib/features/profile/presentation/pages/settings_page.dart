import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medmind/core/constants/route_constants.dart';
import '../../domain/entities/user_preferences_entity.dart';
import '../blocs/profile_bloc/profile_bloc.dart';
import '../blocs/profile_bloc/profile_event.dart';
import '../blocs/profile_bloc/profile_state.dart';
import '../../domain/entities/user_preferences_entity.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
    // Load preferences when settings page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileBloc>().add(LoadPreferences());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }

          if (state is PreferencesUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Settings updated'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is PreferencesLoading || state is ProfileInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          final UserPreferencesEntity? preferences;
          if (state is PreferencesLoaded) {
            preferences = state.preferences;
          } else if (state is PreferencesUpdated) {
            preferences = state.preferences;
          } else if (state is PreferencesReset) {
            preferences = state.preferences;
          } else {
            preferences = null;
          }

          final effectivePreferences = preferences ?? const UserPreferencesEntity();

          return ListView(
            children: [
              // Appearance Section
              _buildSectionHeader('Appearance'),
              _buildSettingItem(
                context,
                icon: Icons.palette,
                title: 'Theme',
                subtitle: _getThemeDisplayName(effectivePreferences.themeMode),
                onTap: () => _showThemeDialog(context, effectivePreferences.themeMode),
              ),
              _buildSettingItem(
                context,
                icon: Icons.language,
                title: 'Language',
                subtitle: _getLanguageDisplayName(effectivePreferences.language),
                onTap: () => _showLanguageDialog(context, effectivePreferences.language),
              ),

              // Notifications Section
              _buildSectionHeader('Notifications'),
              _buildToggleSetting(
                context,
                icon: Icons.notifications,
                title: 'Notifications',
                subtitle: 'Enable all app notifications',
                value: effectivePreferences.notificationsEnabled,
                onChanged: (value) => context.read<ProfileBloc>().add(
                  UpdateNotificationsEnabled(enabled: value),
                ),
              ),
              _buildSettingItem(
                context,
                icon: Icons.snooze,
                title: 'Snooze Duration',
                subtitle: '${effectivePreferences.reminderSnoozeDuration} minutes',
                onTap: () => _showSnoozeDialog(context, effectivePreferences.reminderSnoozeDuration),
              ),

              // Security Section
              _buildSectionHeader('Security & Privacy'),
              _buildToggleSetting(
                context,
                icon: Icons.fingerprint,
                title: 'Biometric Authentication',
                subtitle: 'Use fingerprint or face ID',
                value: effectivePreferences.biometricAuthEnabled,
                onChanged: (value) => _updatePreference(
                  context,
                  effectivePreferences.copyWith(biometricAuthEnabled: value),
                ),
              ),
              _buildToggleSetting(
                context,
                icon: Icons.backup,
                title: 'Data Backup',
                subtitle: 'Automatically backup your data',
                value: effectivePreferences.dataBackupEnabled,
                onChanged: (value) => _updatePreference(
                  context,
                  effectivePreferences.copyWith(dataBackupEnabled: value),
                ),
              ),

              // Actions Section
              _buildSectionHeader('Actions'),
              _buildActionItem(
                context,
                icon: Icons.help_outline,
                title: 'Help & Support',
                onTap: () {
                  Navigator.pushNamed(context, RouteConstants.helpSupport);
                },
              ),
              _buildActionItem(
                context,
                icon: Icons.security,
                title: 'Privacy & Security',
                onTap: () {
                  Navigator.pushNamed(context, RouteConstants.privacySecurity);
                },
              ),
              _buildActionItem(
                context,
                icon: Icons.info_outline,
                title: 'About',
                onTap: () {
                  Navigator.pushNamed(context, RouteConstants.about);
                },
              ),

              // Reset Section
              _buildSectionHeader('Reset'),
              _buildActionItem(
                context,
                icon: Icons.restore,
                title: 'Reset to Defaults',
                color: Colors.orange,
                onTap: () => _showResetConfirmationDialog(context),
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
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  String _getThemeDisplayName(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System Default';
    }
  }

  String _getLanguageDisplayName(String language) {
    switch (language) {
      case 'spanish':
        return 'Español';
      case 'french':
        return 'Français';
      case 'english':
      default:
        return 'English';
    }
  }

  void _updatePreference(BuildContext context, UserPreferencesEntity preferences) {
    context.read<ProfileBloc>().add(UpdatePreferences(preferences: preferences));
  }

  void _showThemeDialog(BuildContext context, ThemeMode currentTheme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeOption(context, ThemeMode.system, 'System Default', currentTheme),
            _buildThemeOption(context, ThemeMode.light, 'Light', currentTheme),
            _buildThemeOption(context, ThemeMode.dark, 'Dark', currentTheme),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(BuildContext context, ThemeMode themeMode, String label, ThemeMode currentTheme) {
    return ListTile(
      title: Text(label),
      leading: Radio<ThemeMode>(
        value: themeMode,
        groupValue: currentTheme,
        onChanged: (value) {
          Navigator.pop(context);
          if (value != null) {
            context.read<ProfileBloc>().add(UpdateThemeModeEvent(themeMode: value));
          }
        },
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, String currentLanguage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption(context, 'english', 'English', currentLanguage),
            _buildLanguageOption(context, 'spanish', 'Español', currentLanguage),
            _buildLanguageOption(context, 'french', 'Français', currentLanguage),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(BuildContext context, String language, String label, String currentLanguage) {
    return ListTile(
      title: Text(label),
      leading: Radio<String>(
        value: language,
        groupValue: currentLanguage,
        onChanged: (value) {
          Navigator.pop(context);
          if (value != null) {
            _updatePreference(
              context,
              UserPreferencesEntity.defaultPreferences.copyWith(language: value),
            );
          }
        },
      ),
    );
  }

  void _showSnoozeDialog(BuildContext context, int currentDuration) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Snooze Duration'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [1, 5, 10, 15, 30]
              .map((duration) => _buildSnoozeOption(context, duration, currentDuration))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildSnoozeOption(BuildContext context, int duration, int currentDuration) {
    return ListTile(
      title: Text('$duration minutes'),
      leading: Radio<int>(
        value: duration,
        groupValue: currentDuration,
        onChanged: (value) {
          Navigator.pop(context);
          if (value != null) {
            _updatePreference(
              context,
              UserPreferencesEntity.defaultPreferences.copyWith(reminderSnoozeDuration: value),
            );
          }
        },
      ),
    );
  }

  void _showResetConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text('Are you sure you want to reset all settings to default values? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<ProfileBloc>().add(ResetToDefaults());
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Settings reset to defaults'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text(
              'Reset',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}