
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_preferences_model.dart';

abstract class ProfileLocalDataSource {
  Future<UserPreferencesModel> getPreferences();
  Future<void> savePreferences(UserPreferencesModel preferences);
  Future<void> clearPreferences();
  Future<bool> hasStoredPreferences();
}

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String _preferencesKey = 'user_preferences';

  ProfileLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<UserPreferencesModel> getPreferences() async {
    try {
      final jsonString = sharedPreferences.getString(_preferencesKey);
      if (jsonString == null) {
        print('📱 No stored preferences found, returning defaults');
        return UserPreferencesModel.defaultPreferences;
      }

      final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
      final preferences = UserPreferencesModel.fromJson(jsonMap);
      print('📱 Loaded preferences: ${preferences.themeMode}, ${preferences.language}');
      return preferences;
    } catch (e) {
      print('❌ Error loading preferences: $e, returning defaults');
      return UserPreferencesModel.defaultPreferences;
    }
  }

  @override
  Future<void> savePreferences(UserPreferencesModel preferences) async {
    try {
      final jsonString = json.encode(preferences.toJson());
      await sharedPreferences.setString(_preferencesKey, jsonString);
      print('💾 Preferences saved: ${preferences.themeMode}, ${preferences.language}');
    } catch (e) {
      print('❌ Failed to save preferences: $e');
      throw Exception('Failed to save preferences: $e');
    }
  }

  @override
  Future<void> clearPreferences() async {
    try {
      await sharedPreferences.remove(_preferencesKey);
      print('🗑️ Preferences cleared');
    } catch (e) {
      print('❌ Failed to clear preferences: $e');
      throw Exception('Failed to clear preferences: $e');
    }
  }

  @override
  Future<bool> hasStoredPreferences() async {
    return sharedPreferences.containsKey(_preferencesKey);
  }
}