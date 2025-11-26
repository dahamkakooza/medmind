import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medmind/features/medication/domain/repositories/medication_repository.dart';
import 'package:medmind/features/medication/domain/usecases/add_medication.dart';
import 'package:medmind/features/medication/domain/usecases/get_medications.dart';
import 'package:medmind/features/medication/domain/usecases/update_medication.dart';
import 'package:medmind/features/medication/domain/usecases/delete_medication.dart';
import 'package:medmind/features/medication/presentation/blocs/medication_bloc/medication_bloc.dart';
import 'package:medmind/features/medication/data/datasources/medication_remote_data_source.dart';
import 'package:medmind/features/medication/data/repositories/medication_repository_impl.dart';
import '../utils/test_dependency_injection.dart';

/// Tests for dependency injection
///
/// **Validates: Requirements 14.2, 14.3, 14.4**
void main() {
  final testGetIt = GetIt.instance;

  setUp(() async {
    await testGetIt.reset();
  });

  tearDown(() async {
    await testGetIt.reset();
  });

  group('Dependency Injection Tests', () {
    test('BLoCs receive injected dependencies', () {
      // Arrange - Register dependencies
      final mockRepository = MockMedicationRepository();
      testGetIt.registerLazySingleton<MedicationRepository>(
        () => mockRepository,
      );

      final getMedications = GetMedications(testGetIt<MedicationRepository>());
      final addMedication = AddMedication(testGetIt<MedicationRepository>());
      final updateMedication = UpdateMedication(
        testGetIt<MedicationRepository>(),
      );
      final deleteMedication = DeleteMedication(
        testGetIt<MedicationRepository>(),
      );

      // Act - Create BLoC with injected use cases
      final bloc = MedicationBloc(
        getMedications: getMedications,
        addMedication: addMedication,
        updateMedication: updateMedication,
        deleteMedication: deleteMedication,
      );

      // Assert - BLoC should have all dependencies
      expect(bloc.getMedications, equals(getMedications));
      expect(bloc.addMedication, equals(addMedication));
      expect(bloc.updateMedication, equals(updateMedication));
      expect(bloc.deleteMedication, equals(deleteMedication));
    });

    test('Repositories receive injected data sources', () {
      // Arrange - Register data sources
      final mockDataSource = MockMedicationRemoteDataSource();
      final mockFirebaseAuth = MockFirebaseAuth();

      testGetIt.registerLazySingleton<MedicationRemoteDataSource>(
        () => mockDataSource,
      );
      testGetIt.registerLazySingleton<FirebaseAuth>(() => mockFirebaseAuth);

      // Act - Create repository with injected data sources
      final repository = MedicationRepositoryImpl(
        remoteDataSource: testGetIt<MedicationRemoteDataSource>(),
        firebaseAuth: testGetIt<FirebaseAuth>(),
      );

      // Assert - Repository should have injected data sources
      expect(repository.remoteDataSource, equals(mockDataSource));
      expect(repository.firebaseAuth, equals(mockFirebaseAuth));
    });

    test('Singleton instances return same object', () {
      // Arrange - Register singleton
      final mockRepository = MockMedicationRepository();
      testGetIt.registerLazySingleton<MedicationRepository>(
        () => mockRepository,
      );

      // Act - Get instance multiple times
      final instance1 = testGetIt<MedicationRepository>();
      final instance2 = testGetIt<MedicationRepository>();
      final instance3 = testGetIt<MedicationRepository>();

      // Assert - All instances should be the same object
      expect(instance1, same(instance2));
      expect(instance2, same(instance3));
      expect(instance1, same(instance3));
      expect(identical(instance1, instance2), isTrue);
      expect(identical(instance2, instance3), isTrue);
    });

    test('Use cases receive repository dependencies', () {
      // Arrange
      final mockRepository = MockMedicationRepository();
      testGetIt.registerLazySingleton<MedicationRepository>(
        () => mockRepository,
      );

      // Act - Create use cases with injected repository
      final getMedications = GetMedications(testGetIt<MedicationRepository>());
      final addMedication = AddMedication(testGetIt<MedicationRepository>());
      final updateMedication = UpdateMedication(
        testGetIt<MedicationRepository>(),
      );
      final deleteMedication = DeleteMedication(
        testGetIt<MedicationRepository>(),
      );

      // Assert - Use cases should have the repository
      expect(getMedications.repository, equals(mockRepository));
      expect(addMedication.repository, equals(mockRepository));
      expect(updateMedication.repository, equals(mockRepository));
      expect(deleteMedication.repository, equals(mockRepository));
    });

    test('Multiple BLoCs can share same repository singleton', () {
      // Arrange - Register singleton repository
      final mockRepository = MockMedicationRepository();
      testGetIt.registerLazySingleton<MedicationRepository>(
        () => mockRepository,
      );

      final getMedications = GetMedications(testGetIt<MedicationRepository>());
      final addMedication = AddMedication(testGetIt<MedicationRepository>());
      final updateMedication = UpdateMedication(
        testGetIt<MedicationRepository>(),
      );
      final deleteMedication = DeleteMedication(
        testGetIt<MedicationRepository>(),
      );

      // Act - Create multiple BLoCs
      final bloc1 = MedicationBloc(
        getMedications: getMedications,
        addMedication: addMedication,
        updateMedication: updateMedication,
        deleteMedication: deleteMedication,
      );

      final bloc2 = MedicationBloc(
        getMedications: getMedications,
        addMedication: addMedication,
        updateMedication: updateMedication,
        deleteMedication: deleteMedication,
      );

      // Assert - Both BLoCs should use the same repository instance
      expect(
        bloc1.getMedications.repository,
        same(bloc2.getMedications.repository),
      );
      expect(
        bloc1.addMedication.repository,
        same(bloc2.addMedication.repository),
      );
    });
  });
}
