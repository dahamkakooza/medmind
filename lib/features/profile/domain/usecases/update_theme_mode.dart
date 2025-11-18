import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart'; // ADD THIS
import '../../../../core/errors/failures.dart';
import '../entities/user_preferences_entity.dart';
import '../repositories/profile_repository.dart';

class UpdateThemeMode {
  final ProfileRepository repository;

  UpdateThemeMode(this.repository);

  Future<Either<Failure, UserPreferencesEntity>> call(ThemeMode themeMode) async { // CHANGED PARAMETER TYPE
    try {
      return await repository.updateThemeMode(themeMode);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to update theme mode: $e'));
    }
  }
}