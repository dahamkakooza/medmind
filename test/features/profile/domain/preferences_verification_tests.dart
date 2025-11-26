import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medmind/features/profile/data/datasources/profile_local_data_source.dart';
import 'package:medmind/features/profile/data/models/user_preferences_model.dart';
import 'package:medmind/features/profile/data/repositories/profile_repository_impl.dart';
import '../../../utils/property_test_framework.dart';

/// **Feature: system-verification, Property 28 & 29: Preferences persist and synchronize**
/// **Validates: Requirements 8.3, 8.5**
///
/// This test verifies that user preferences are correctly persisted to SharedPreferences
/// and can be retrieved across app sessions, and that preference changes synchronize UI.
void main() {
  group('SharedPreferences Verification Tests', () {
    late SharedPreferences sharedPreferences;

    setUp(() async {
      // Initialize SharedPreferences with mock values
      SharedPreferences.setMockInitialValues({});
      sharedPreferences = await SharedPreferences.getInstance();
    });

    tearDown(() async {
      // Clear all preferences after each test
      await sharedPreferences.clear();
    });

    group('Property 28: Preferences persist across sessions', () {
      test('should persist and retrieve theme mode preference', () async {
        await runPropertyTest<ThemeMode>(
          name: 'Theme mode persists across sessions',
          generator: () {
            final modes = [ThemeMode.light, ThemeMode.dark, ThemeMode.system];
            return modes[DateTime.now().microsecond % modes.length];
          },
          property: (themeMode) async {
            // Create data source and repository
            final dataSource = ProfileLocalDataSourceImpl(
              sharedPreferences: sharedPreferences,
            );
            final repository = ProfileRepositoryImpl(
              localDataSource: dataSource,
            );

            // Save theme mode preference
            final result = await repository.updateThemeMode(themeMode);

            // Verify save was successful
            if (result.isLeft()) return false;

            // Simulate app restart by creating new instances
            final newDataSource = ProfileLocalDataSourceImpl(
              sharedPreferences: sharedPreferences,
            );
            final newRepository = ProfileRepositoryImpl(
              localDataSource: newDataSource,
            );

            // Retrieve preferences
            final retrieveResult = await newRepository.getPreferences();

            return retrieveResult.fold(
              (failure) => false,
              (preferences) => preferences.themeMode == themeMode,
            );
          },
          config: PropertyTestConfig(iterations: 50),
        );
      });

      test('should persist and retrieve notification settings', () async {
        await runPropertyTest<bool>(
          name: 'Notification settings persist across sessions',
          generator: () => DateTime.now().microsecond % 2 == 0,
          property: (notificationsEnabled) async {
            // Create data source and repository
            final dataSource = ProfileLocalDataSourceImpl(
              sharedPreferences: sharedPreferences,
            );
            final repository = ProfileRepositoryImpl(
              localDataSource: dataSource,
            );

            // Save notification preference
            final result = await repository.updateNotifications(
              notificationsEnabled,
            );

            // Verify save was successful
            if (result.isLeft()) return false;

            // Simulate app restart by creating new instances
            final newDataSource = ProfileLocalDataSourceImpl(
              sharedPreferences: sharedPreferences,
            );
            final newRepository = ProfileRepositoryImpl(
              localDataSource: newDataSource,
            );

            // Retrieve preferences
            final retrieveResult = await newRepository.getPreferences();

            return retrieveResult.fold(
              (failure) => false,
              (preferences) =>
                  preferences.notificationsEnabled == notificationsEnabled,
            );
          },
          config: PropertyTestConfig(iterations: 50),
        );
      });

      test('should persist and retrieve snooze duration preference', () async {
        await runPropertyTest<int>(
          name: 'Snooze duration persists across sessions',
          generator: () =>
              1 + (DateTime.now().microsecond % 60), // 1-60 minutes
          property: (snoozeDuration) async {
            // Create data source and repository
            final dataSource = ProfileLocalDataSourceImpl(
              sharedPreferences: sharedPreferences,
            );

            // Get current preferences
            final currentPrefs = await dataSource.getPreferences();

            // Update with new snooze duration
            final updatedPrefs = currentPrefs.copyWith(
              reminderSnoozeDuration: snoozeDuration,
            );

            await dataSource.savePreferences(updatedPrefs);

            // Simulate app restart by creating new instance
            final newDataSource = ProfileLocalDataSourceImpl(
              sharedPreferences: sharedPreferences,
            );

            // Retrieve preferences
            final retrievedPrefs = await newDataSource.getPreferences();

            return retrievedPrefs.reminderSnoozeDuration == snoozeDuration;
          },
          config: PropertyTestConfig(iterations: 50),
        );
      });

      test('should persist and retrieve language preference', () async {
        await runPropertyTest<Language>(
          name: 'Language preference persists across sessions',
          generator: () {
            final languages = [
              Language.english,
              Language.spanish,
              Language.french,
            ];
            return languages[DateTime.now().microsecond % languages.length];
          },
          property: (language) async {
            // Create data source
            final dataSource = ProfileLocalDataSourceImpl(
              sharedPreferences: sharedPreferences,
            );

            // Get current preferences
            final currentPrefs = await dataSource.getPreferences();

            // Update with new language
            final updatedPrefs = currentPrefs.copyWith(language: language);
            await dataSource.savePreferences(updatedPrefs);

            // Simulate app restart by creating new instance
            final newDataSource = ProfileLocalDataSourceImpl(
              sharedPreferences: sharedPreferences,
            );

            // Retrieve preferences
            final retrievedPrefs = await newDataSource.getPreferences();

            return retrievedPrefs.language == language;
          },
          config: PropertyTestConfig(iterations: 50),
        );
      });

      test('should persist and retrieve biometric auth preference', () async {
        await runPropertyTest<bool>(
          name: 'Biometric auth preference persists across sessions',
          generator: () => DateTime.now().microsecond % 2 == 0,
          property: (biometricEnabled) async {
            // Create data source
            final dataSource = ProfileLocalDataSourceImpl(
              sharedPreferences: sharedPreferences,
            );

            // Get current preferences
            final currentPrefs = await dataSource.getPreferences();

            // Update with new biometric setting
            final updatedPrefs = currentPrefs.copyWith(
              biometricAuthEnabled: biometricEnabled,
            );
            await dataSource.savePreferences(updatedPrefs);

            // Simulate app restart by creating new instance
            final newDataSource = ProfileLocalDataSourceImpl(
              sharedPreferences: sharedPreferences,
            );

            // Retrieve preferences
            final retrievedPrefs = await newDataSource.getPreferences();

            return retrievedPrefs.biometricAuthEnabled == biometricEnabled;
          },
          config: PropertyTestConfig(iterations: 50),
        );
      });

      test('should persist and retrieve data backup preference', () async {
        await runPropertyTest<bool>(
          name: 'Data backup preference persists across sessions',
          generator: () => DateTime.now().microsecond % 2 == 0,
          property: (backupEnabled) async {
            // Create data source
            final dataSource = ProfileLocalDataSourceImpl(
              sharedPreferences: sharedPreferences,
            );

            // Get current preferences
            final currentPrefs = await dataSource.getPreferences();

            // Update with new backup setting
            final updatedPrefs = currentPrefs.copyWith(
              dataBackupEnabled: backupEnabled,
            );
            await dataSource.savePreferences(updatedPrefs);

            // Simulate app restart by creating new instance
            final newDataSource = ProfileLocalDataSourceImpl(
              sharedPreferences: sharedPreferences,
            );

            // Retrieve preferences
            final retrievedPrefs = await newDataSource.getPreferences();

            return retrievedPrefs.dataBackupEnabled == backupEnabled;
          },
          config: PropertyTestConfig(iterations: 50),
        );
      });

      test('should return default preferences when none are saved', () async {
        // Clear any existing preferences
        await sharedPreferences.clear();

        // Create data source
        final dataSource = ProfileLocalDataSourceImpl(
          sharedPreferences: sharedPreferences,
        );

        // Retrieve preferences (should return defaults)
        final retrievedPrefs = await dataSource.getPreferences();
        final defaultPrefs = UserPreferencesModel.defaultPreferences;

        // Verify all default values match
        expect(retrievedPrefs.themeMode, defaultPrefs.themeMode);
        expect(
          retrievedPrefs.notificationsEnabled,
          defaultPrefs.notificationsEnabled,
        );
        expect(
          retrievedPrefs.reminderSnoozeDuration,
          defaultPrefs.reminderSnoozeDuration,
        );
        expect(retrievedPrefs.language, defaultPrefs.language);
        expect(
          retrievedPrefs.biometricAuthEnabled,
          defaultPrefs.biometricAuthEnabled,
        );
        expect(
          retrievedPrefs.dataBackupEnabled,
          defaultPrefs.dataBackupEnabled,
        );
      });

      test('should handle corrupted preference data gracefully', () async {
        // Manually set corrupted JSON data
        await sharedPreferences.setString(
          'user_preferences',
          'invalid-json-data',
        );

        // Create data source
        final dataSource = ProfileLocalDataSourceImpl(
          sharedPreferences: sharedPreferences,
        );

        // Should return default preferences without throwing
        final retrievedPrefs = await dataSource.getPreferences();
        final defaultPrefs = UserPreferencesModel.defaultPreferences;

        expect(retrievedPrefs.themeMode, defaultPrefs.themeMode);
        expect(
          retrievedPrefs.notificationsEnabled,
          defaultPrefs.notificationsEnabled,
        );
      });

      test('should persist multiple preference changes in sequence', () async {
        final dataSource = ProfileLocalDataSourceImpl(
          sharedPreferences: sharedPreferences,
        );

        // Make multiple changes
        var prefs = await dataSource.getPreferences();

        prefs = prefs.copyWith(themeMode: ThemeMode.dark);
        await dataSource.savePreferences(prefs);

        prefs = prefs.copyWith(notificationsEnabled: false);
        await dataSource.savePreferences(prefs);

        prefs = prefs.copyWith(reminderSnoozeDuration: 15);
        await dataSource.savePreferences(prefs);

        // Simulate app restart
        final newDataSource = ProfileLocalDataSourceImpl(
          sharedPreferences: sharedPreferences,
        );

        // Verify all changes persisted
        final retrievedPrefs = await newDataSource.getPreferences();
        expect(retrievedPrefs.themeMode, ThemeMode.dark);
        expect(retrievedPrefs.notificationsEnabled, false);
        expect(retrievedPrefs.reminderSnoozeDuration, 15);
      });
    });

    group('Property 29: Preference changes synchronize UI', () {
      test('should emit updated state when theme mode changes', () async {
        await runPropertyTest<ThemeMode>(
          name: 'Theme mode changes synchronize UI state',
          generator: () {
            final modes = [ThemeMode.light, ThemeMode.dark, ThemeMode.system];
            return modes[DateTime.now().microsecond % modes.length];
          },
          property: (themeMode) async {
            // Create data source and repository
            final dataSource = ProfileLocalDataSourceImpl(
              sharedPreferences: sharedPreferences,
            );
            final repository = ProfileRepositoryImpl(
              localDataSource: dataSource,
            );

            // Update theme mode
            final result = await repository.updateThemeMode(themeMode);

            // Verify the result contains the updated preference
            return result.fold(
              (failure) => false,
              (preferences) => preferences.themeMode == themeMode,
            );
          },
          config: PropertyTestConfig(iterations: 50),
        );
      });

      test(
        'should emit updated state when notification settings change',
        () async {
          await runPropertyTest<bool>(
            name: 'Notification settings changes synchronize UI state',
            generator: () => DateTime.now().microsecond % 2 == 0,
            property: (notificationsEnabled) async {
              // Create data source and repository
              final dataSource = ProfileLocalDataSourceImpl(
                sharedPreferences: sharedPreferences,
              );
              final repository = ProfileRepositoryImpl(
                localDataSource: dataSource,
              );

              // Update notification settings
              final result = await repository.updateNotifications(
                notificationsEnabled,
              );

              // Verify the result contains the updated preference
              return result.fold(
                (failure) => false,
                (preferences) =>
                    preferences.notificationsEnabled == notificationsEnabled,
              );
            },
            config: PropertyTestConfig(iterations: 50),
          );
        },
      );

      test('should synchronize all preference fields after update', () async {
        final dataSource = ProfileLocalDataSourceImpl(
          sharedPreferences: sharedPreferences,
        );
        final repository = ProfileRepositoryImpl(localDataSource: dataSource);

        // Get initial preferences
        final initialResult = await repository.getPreferences();
        expect(initialResult.isRight(), true);

        final initialPrefs = initialResult.getOrElse(
          () => throw Exception('Failed to get initial prefs'),
        );

        // Update theme mode
        final themeResult = await repository.updateThemeMode(ThemeMode.dark);
        expect(themeResult.isRight(), true);

        final updatedPrefs = themeResult.getOrElse(
          () => throw Exception('Failed to update theme'),
        );

        // Verify theme mode changed
        expect(updatedPrefs.themeMode, ThemeMode.dark);

        // Verify other fields remain unchanged
        expect(
          updatedPrefs.notificationsEnabled,
          initialPrefs.notificationsEnabled,
        );
        expect(
          updatedPrefs.reminderSnoozeDuration,
          initialPrefs.reminderSnoozeDuration,
        );
        expect(updatedPrefs.language, initialPrefs.language);
        expect(
          updatedPrefs.biometricAuthEnabled,
          initialPrefs.biometricAuthEnabled,
        );
        expect(updatedPrefs.dataBackupEnabled, initialPrefs.dataBackupEnabled);
      });

      test(
        'should maintain consistency between repository and data source',
        () async {
          await runPropertyTest<bool>(
            name: 'Repository and data source remain synchronized',
            generator: () => DateTime.now().microsecond % 2 == 0,
            property: (notificationsEnabled) async {
              // Create data source and repository
              final dataSource = ProfileLocalDataSourceImpl(
                sharedPreferences: sharedPreferences,
              );
              final repository = ProfileRepositoryImpl(
                localDataSource: dataSource,
              );

              // Update via repository
              final repoResult = await repository.updateNotifications(
                notificationsEnabled,
              );
              if (repoResult.isLeft()) return false;

              // Read directly from data source
              final dataSourcePrefs = await dataSource.getPreferences();

              // Verify both have the same value
              return dataSourcePrefs.notificationsEnabled ==
                  notificationsEnabled;
            },
            config: PropertyTestConfig(iterations: 50),
          );
        },
      );

      test(
        'should handle rapid preference changes without data loss',
        () async {
          final dataSource = ProfileLocalDataSourceImpl(
            sharedPreferences: sharedPreferences,
          );
          final repository = ProfileRepositoryImpl(localDataSource: dataSource);

          // Make rapid changes
          await repository.updateThemeMode(ThemeMode.light);
          await repository.updateThemeMode(ThemeMode.dark);
          await repository.updateThemeMode(ThemeMode.system);
          await repository.updateNotifications(true);
          await repository.updateNotifications(false);
          await repository.updateNotifications(true);

          // Verify final state is correct
          final finalResult = await repository.getPreferences();
          expect(finalResult.isRight(), true);

          final finalPrefs = finalResult.getOrElse(
            () => throw Exception('Failed to get final prefs'),
          );

          // Last values should be persisted
          expect(finalPrefs.themeMode, ThemeMode.system);
          expect(finalPrefs.notificationsEnabled, true);
        },
      );

      test('should update preferences atomically', () async {
        await runPropertyTest<Map<String, dynamic>>(
          name: 'Preference updates are atomic',
          generator: () {
            final modes = [ThemeMode.light, ThemeMode.dark, ThemeMode.system];
            final themeMode = modes[DateTime.now().microsecond % modes.length];
            final notificationsEnabled = DateTime.now().microsecond % 2 == 0;

            return {
              'themeMode': themeMode,
              'notificationsEnabled': notificationsEnabled,
            };
          },
          property: (changes) async {
            final dataSource = ProfileLocalDataSourceImpl(
              sharedPreferences: sharedPreferences,
            );

            // Get current preferences
            final currentPrefs = await dataSource.getPreferences();

            // Apply both changes
            final updatedPrefs = currentPrefs.copyWith(
              themeMode: changes['themeMode'] as ThemeMode,
              notificationsEnabled: changes['notificationsEnabled'] as bool,
            );

            await dataSource.savePreferences(updatedPrefs);

            // Verify both changes were applied
            final retrievedPrefs = await dataSource.getPreferences();

            return retrievedPrefs.themeMode == changes['themeMode'] &&
                retrievedPrefs.notificationsEnabled ==
                    changes['notificationsEnabled'];
          },
          config: PropertyTestConfig(iterations: 50),
        );
      });

      test('should preserve preferences during concurrent reads', () async {
        final dataSource = ProfileLocalDataSourceImpl(
          sharedPreferences: sharedPreferences,
        );

        // Set initial preferences
        final initialPrefs = UserPreferencesModel.defaultPreferences.copyWith(
          themeMode: ThemeMode.dark,
          notificationsEnabled: false,
        );
        await dataSource.savePreferences(initialPrefs);

        // Perform multiple concurrent reads
        final futures = List.generate(10, (_) => dataSource.getPreferences());

        final results = await Future.wait(futures);

        // All reads should return the same values
        for (final prefs in results) {
          expect(prefs.themeMode, ThemeMode.dark);
          expect(prefs.notificationsEnabled, false);
        }
      });
    });
  });
}
