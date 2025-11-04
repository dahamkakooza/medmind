import 'package:dartz/dartz.dart';
import '../errors/failures.dart';

class InputConverter {
  Either<Failure, String> validateEmail(String email) {
    const emailRegex = r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+';
    
    if (email.isEmpty) {
      return Left(ValidationFailure(message: 'Email is required'));
    } else if (!RegExp(emailRegex).hasMatch(email)) {
      return Left(ValidationFailure(message: 'Please enter a valid email'));
    } else if (email.length > AppConstants.maxEmailLength) {
      return Left(ValidationFailure(message: 'Email is too long'));
    } else {
      return Right(email);
    }
  }

  Either<Failure, String> validatePassword(String password) {
    if (password.isEmpty) {
      return Left(ValidationFailure(message: 'Password is required'));
    } else if (password.length < AppConstants.minPasswordLength) {
      return Left(ValidationFailure(
        message: 'Password must be at least ${AppConstants.minPasswordLength} characters',
      ));
    } else {
      return Right(password);
    }
  }

  Either<Failure, String> validateName(String name, {String fieldName = 'Name'}) {
    if (name.isEmpty) {
      return Left(ValidationFailure(message: '$fieldName is required'));
    } else if (name.length < 2) {
      return Left(ValidationFailure(message: '$fieldName is too short'));
    } else if (name.length > 50) {
      return Left(ValidationFailure(message: '$fieldName is too long'));
    } else {
      return Right(name);
    }
  }

  Either<Failure, DateTime> validateDate(DateTime date, {String fieldName = 'Date'}) {
    final now = DateTime.now();
    
    if (date.isAfter(now)) {
      return Left(ValidationFailure(message: '$fieldName cannot be in the future'));
    } else {
      return Right(date);
    }
  }

  Either<Failure, String> validateMedicationName(String name) {
    if (name.isEmpty) {
      return Left(ValidationFailure(message: 'Medication name is required'));
    } else if (name.length > AppConstants.maxMedicationNameLength) {
      return Left(ValidationFailure(message: 'Medication name is too long'));
    } else {
      return Right(name);
    }
  }

  Either<Failure, String> validateDosage(String dosage) {
    if (dosage.isEmpty) {
      return Left(ValidationFailure(message: 'Dosage is required'));
    } else if (dosage.length > 50) {
      return Left(ValidationFailure(message: 'Dosage description is too long'));
    } else {
      return Right(dosage);
    }
  }
}