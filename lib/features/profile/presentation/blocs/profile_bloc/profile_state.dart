import 'package:equatable/equatable.dart';
import '../../domain/entities/user_preferences_entity.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object> get props => [];
}

// Initial State
class ProfileInitial extends ProfileState {}

// Loading States
class ProfileLoading extends ProfileState {}

class PreferencesLoading extends ProfileState {}

class PreferencesSaving extends ProfileState {}

class DataExporting extends ProfileState {}

class DataClearing extends ProfileState {}

// Loaded States
class PreferencesLoaded extends ProfileState {
  final UserPreferencesEntity preferences;

  const PreferencesLoaded({required this.preferences});

  @override
  List<Object> get props => [preferences];
}

class PreferencesUpdated extends ProfileState {
  final UserPreferencesEntity preferences;

  const PreferencesUpdated({required this.preferences});

  @override
  List<Object> get props => [preferences];
}

class PreferencesReset extends ProfileState {
  final UserPreferencesEntity preferences;

  const PreferencesReset({required this.preferences});

  @override
  List<Object> get props => [preferences];
}

class DataExported extends ProfileState {
  final String filePath;

  const DataExported({required this.filePath});

  @override
  List<Object> get props => [filePath];
}

class DataCleared extends ProfileState {}

// Error States
class ProfileError extends ProfileState {
  final String message;

  const ProfileError({required this.message});

  @override
  List<Object> get props => [message];
}

class PreferencesLoadError extends ProfileError {
  const PreferencesLoadError({required String message})
      : super(message: message);
}

class PreferencesSaveError extends ProfileError {
  const PreferencesSaveError({required String message})
      : super(message: message);
}

class DataExportError extends ProfileError {
  const DataExportError({required String message})
      : super(message: message);
}

class DataClearError extends ProfileError {
  const DataClearError({required String message})
      : super(message: message);
}
