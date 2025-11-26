library test_dependency_injection;

import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import repositories
import 'package:medmind/features/auth/domain/repositories/auth_repository.dart';
import 'package:medmind/features/medication/domain/repositories/medication_repository.dart';
import 'package:medmind/features/adherence/domain/repositories/adherence_repository.dart';
import 'package:medmind/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:medmind/features/profile/domain/repositories/profile_repository.dart';

// Import data sources
import 'package:medmind/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:medmind/features/medication/data/datasources/medication_remote_data_source.dart';
import 'package:medmind/features/medication/data/datasources/medication_local_data_source.dart';
import 'package:medmind/features/adherence/data/datasources/adherence_remote_data_source.dart';
import 'package:medmind/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:medmind/features/profile/data/datasources/profile_local_data_source.dart';

/// Mock classes for testing
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockFirebaseStorage extends Mock implements FirebaseStorage {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

// Repository mocks
class MockAuthRepository extends Mock implements AuthRepository {}

class MockMedicationRepository extends Mock implements MedicationRepository {}

class MockAdherenceRepository extends Mock implements AdherenceRepository {}

class MockDashboardRepository extends Mock implements DashboardRepository {}

class MockProfileRepository extends Mock implements ProfileRepository {}

// Data source mocks
class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockMedicationRemoteDataSource extends Mock
    implements MedicationRemoteDataSource {}

class MockMedicationLocalDataSource extends Mock
    implements MedicationLocalDataSource {}

class MockAdherenceRemoteDataSource extends Mock
    implements AdherenceRemoteDataSource {}

class MockDashboardRemoteDataSource extends Mock
    implements DashboardRemoteDataSource {}

class MockProfileLocalDataSource extends Mock
    implements ProfileLocalDataSource {}

/// Test service locator
final testServiceLocator = GetIt.instance;

/// Initialize test dependencies
///
/// This sets up mock versions of all dependencies for testing.
/// Call this in setUp() for each test suite.
Future<void> initTestDependencies() async {
  // Reset the service locator
  await testServiceLocator.reset();

  // Register Firebase mocks
  testServiceLocator.registerLazySingleton<FirebaseAuth>(
    () => MockFirebaseAuth(),
  );
  testServiceLocator.registerLazySingleton<FirebaseFirestore>(
    () => MockFirebaseFirestore(),
  );
  testServiceLocator.registerLazySingleton<FirebaseStorage>(
    () => MockFirebaseStorage(),
  );

  // Register SharedPreferences mock
  SharedPreferences.setMockInitialValues({});
  final sharedPreferences = await SharedPreferences.getInstance();
  testServiceLocator.registerLazySingleton<SharedPreferences>(
    () => sharedPreferences,
  );

  // Register repository mocks
  testServiceLocator.registerLazySingleton<AuthRepository>(
    () => MockAuthRepository(),
  );
  testServiceLocator.registerLazySingleton<MedicationRepository>(
    () => MockMedicationRepository(),
  );
  testServiceLocator.registerLazySingleton<AdherenceRepository>(
    () => MockAdherenceRepository(),
  );
  testServiceLocator.registerLazySingleton<DashboardRepository>(
    () => MockDashboardRepository(),
  );
  testServiceLocator.registerLazySingleton<ProfileRepository>(
    () => MockProfileRepository(),
  );

  // Register data source mocks
  testServiceLocator.registerLazySingleton<AuthRemoteDataSource>(
    () => MockAuthRemoteDataSource(),
  );
  testServiceLocator.registerLazySingleton<MedicationRemoteDataSource>(
    () => MockMedicationRemoteDataSource(),
  );
  testServiceLocator.registerLazySingleton<MedicationLocalDataSource>(
    () => MockMedicationLocalDataSource(),
  );
  testServiceLocator.registerLazySingleton<AdherenceRemoteDataSource>(
    () => MockAdherenceRemoteDataSource(),
  );
  testServiceLocator.registerLazySingleton<DashboardRemoteDataSource>(
    () => MockDashboardRemoteDataSource(),
  );
  testServiceLocator.registerLazySingleton<ProfileLocalDataSource>(
    () => MockProfileLocalDataSource(),
  );
}

/// Clean up test dependencies
///
/// Call this in tearDown() for each test suite.
Future<void> cleanupTestDependencies() async {
  await testServiceLocator.reset();
}

/// Get a mock repository from the service locator
T getMockRepository<T extends Object>() {
  return testServiceLocator<T>();
}

/// Get a mock data source from the service locator
T getMockDataSource<T extends Object>() {
  return testServiceLocator<T>();
}

/// Get a mock Firebase service from the service locator
T getMockFirebaseService<T extends Object>() {
  return testServiceLocator<T>();
}
