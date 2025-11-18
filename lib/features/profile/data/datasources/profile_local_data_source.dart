import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_preferences_model.dart';

abstract class ProfileLocalDataSource {
  Future<UserPreferencesModel> getPreferences();
  Future<void> savePreferences(UserPreferencesModel preferences);
  Future<void> clearPreferences();
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
        return UserPreferencesModel.defaultPreferences;
      }

      final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
      return UserPreferencesModel.fromJson(jsonMap);
    } catch (e) {
      // If there's any error reading preferences, return defaults
      return UserPreferencesModel.defaultPreferences;
    }
  }

  @override
  Future<void> savePreferences(UserPreferencesModel preferences) async {
    try {
      final jsonString = json.encode(preferences.toJson());
      await sharedPreferences.setString(_preferencesKey, jsonString);
    } catch (e) {
      throw Exception('Failed to save preferences: $e');
    }
  }

  @override
  Future<void> clearPreferences() async {
    try {
      await sharedPreferences.remove(_preferencesKey);
    } catch (e) {
      throw Exception('Failed to clear preferences: $e');
    }
  }
}