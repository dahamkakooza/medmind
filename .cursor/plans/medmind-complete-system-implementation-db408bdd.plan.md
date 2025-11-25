<!-- db408bdd-f236-4bfb-ae38-88d6f7c8f366 542f878f-f784-44ba-b426-2949baa7cc0f -->
# Backend Developer 2 - Firestore & Data Operations Implementation Plan

## Overview

As Backend Developer 2, you are responsible for implementing all Firestore database operations, data models, remote data sources, and repository implementations for the medication, dashboard, and adherence features. This includes Firebase configuration and ensuring proper data flow between the domain and data layers.

## Phase 1: Domain Layer Setup (Foundation)

### 1.1 Create Domain Entities

Based on the Firestore schema specification, create domain entities that represent business objects:

**MedicationEntity** (`lib/features/medication/domain/entities/medication_entity.dart`)

- Fields matching Firestore schema:
- id, userId, name, dosage, form (enum: tablet, capsule, liquid, injection)
- frequency (enum: daily, weekly, custom), times (List<TimeOfDay>), days (List<int>)
- startDate, isActive, barcodeData, refillReminder
- instructions, createdAt, updatedAt

**AdherenceLogEntity** (`lib/features/adherence/domain/entities/adherence_log_entity.dart`)

- Fields: id, userId, medicationId, scheduledTime, takenTime
- status (enum: taken, missed, snoozed), snoozeDuration
- createdAt, deviceInfo

**AdherenceEntity** (`lib/features/dashboard/domain/entities/adherence_entity.dart`)

- Fields: adherenceRate, totalMedications, takenCount, missedCount
- weeklyStats, monthlyStats, streakDays

### 1.2 Create Repository Interfaces

Define abstract repository interfaces that domain layer will use:

**MedicationRepository** (`lib/features/medication/domain/repositories/medication_repository.dart`)

- Methods: getMedications(), addMedication(), updateMedication(), deleteMedication()
- scanBarcode(), getMedicationById()
- Stream<List<MedicationEntity>> watchMedications() for real-time updates

**AdherenceRepository** (`lib/features/adherence/domain/repositories/adherence_repository.dart`)

- Methods: getAdherenceLogs(), logMedicationTaken(), getAdherenceSummary()
- exportAdherenceData()

**DashboardRepository** (`lib/features/dashboard/domain/repositories/dashboard_repository.dart`)

- Methods: getTodayMedications(), getAdherenceStats()
- Stream<AdherenceEntity> watchAdherenceStats() for real-time updates

## Phase 2: Data Models & Firestore Mapping

### 2.1 MedicationModel

Create `lib/features/medication/data/models/medication_model.dart`:

- Extends MedicationEntity (or implements with toEntity/fromEntity)
- Implements JSON serialization (toJson/fromJson)
- Firestore document mapping (toDocument/fromDocument)
- Handles enum conversions (form, frequency)
- Handles TimeOfDay to/from Firestore Timestamp conversion
- Handles DateTime serialization

### 2.2 AdherenceLogModel

Create `lib/features/adherence/data/models/adherence_log_model.dart`:

- Extends AdherenceLogEntity
- JSON and Firestore document serialization
- Handles status enum conversion
- Handles DateTime/Timestamp conversions

### 2.3 AdherenceModel

Create `lib/features/dashboard/data/models/adherence_model.dart`:

- Extends AdherenceEntity
- Handles statistics aggregation
- JSON serialization for caching

## Phase 3: Remote Data Sources (Firestore Operations)

### 3.1 MedicationRemoteDataSource

Create `lib/features/medication/data/datasources/medication_remote_data_source.dart`:

- **CRUD Operations:**
- `Future<List<MedicationModel>> getMedications(String userId)` - Query with userId filter
- `Future<MedicationModel> getMedicationById(String id)` - Single document fetch
- `Future<MedicationModel> addMedication(MedicationModel medication)` - Add with auto-generated ID
- `Future<void> updateMedication(MedicationModel medication)` - Update existing
- `Future<void> deleteMedication(String id)` - Soft delete (set isActive = false)
- **Real-time Operations:**
- `Stream<List<MedicationModel>> watchMedications(String userId)` - Real-time stream
- **Barcode Operations:**
- `Future<MedicationModel?> lookupBarcode(String barcodeData)` - Query by barcode
- **Error Handling:**
- Catch Firestore exceptions and throw custom exceptions
- Handle network errors, permission errors, not found errors

### 3.2 AdherenceRemoteDataSource

Create `lib/features/adherence/data/datasources/adherence_remote_data_source.dart`:

- **CRUD Operations:**
- `Future<List<AdherenceLogModel>> getAdherenceLogs(String userId, {DateTime? startDate, DateTime? endDate})`
- `Future<AdherenceLogModel> logMedicationTaken(AdherenceLogModel log)` - Create log entry
- `Future<void> updateAdherenceLog(AdherenceLogModel log)`
- **Aggregation Queries:**
- `Future<Map<String, dynamic>> getAdherenceSummary(String userId, DateTime startDate, DateTime endDate)`
- Calculate adherence rate, missed doses, streaks
- **Real-time Operations:**
- `Stream<List<AdherenceLogModel>> watchAdherenceLogs(String userId)`

### 3.3 DashboardRemoteDataSource

Create `lib/features/dashboard/data/datasources/dashboard_remote_data_source.dart`:

- **Today's Medications:**
- `Future<List<MedicationModel>> getTodayMedications(String userId)` - Query active medications for today
- Filter by isActive and match today's schedule
- **Adherence Statistics:**
- `Future<AdherenceModel> getAdherenceStats(String userId, {DateTime? startDate, DateTime? endDate})`
- Aggregate data from adherence_logs collection
- Calculate weekly/monthly statistics
- **Real-time Operations:**
- `Stream<AdherenceModel> watchAdherenceStats(String userId)`

## Phase 4: Repository Implementations

### 4.1 MedicationRepositoryImpl

Create `lib/features/medication/data/repositories/medication_repository_impl.dart`:

- Implements MedicationRepository interface
- Uses MedicationRemoteDataSource
- Maps exceptions to Failures:
- FirestoreException → DataFailure/NetworkFailure
- Permission errors → PermissionFailure
- Not found → DataFailure
- Returns Either<Failure, Type> for all operations
- Handles entity ↔ model conversions

### 4.2 AdherenceRepositoryImpl

Create `lib/features/adherence/data/repositories/adherence_repository_impl.dart`:

- Implements AdherenceRepository interface
- Uses AdherenceRemoteDataSource
- Maps exceptions to Failures
- Handles entity ↔ model conversions
- Implements aggregation logic

### 4.3 DashboardRepositoryImpl

Create `lib/features/dashboard/data/repositories/dashboard_repository_impl.dart`:

- Implements DashboardRepository interface
- Uses DashboardRemoteDataSource
- Maps exceptions to Failures
- Handles entity ↔ model conversions
- Implements statistics calculation

## Phase 5: Firebase Configuration

### 5.1 Firebase Initialization

Enhance `lib/config/firebase_config.dart`:

- Complete Firebase.initializeApp() with proper options
- Handle platform-specific configurations (Android, iOS, Web)
- Add error handling and logging
- Ensure Firestore and Storage are initialized

### 5.2 Firestore Indexes

Create `firestore.indexes.json`:

- Composite indexes for queries:
- medications: userId + isActive
- adherence_logs: userId + scheduledTime
- adherence_logs: userId + createdAt
- Single field indexes where needed

## Phase 6: Error Handling & Edge Cases

### 6.1 Exception Mapping

Create custom exception classes in `lib/core/errors/exceptions.dart`:

- FirestoreException wrapper
- NetworkException
- PermissionException
- NotFoundException

### 6.2 Error Handling in Data Sources

- Try-catch blocks around all Firestore operations
- Map Firestore error codes to custom exceptions
- Handle offline scenarios
- Implement retry logic for transient failures

## Phase 7: Testing Preparation

### 7.1 Mock Data Sources

Create mock implementations for testing:

- MockMedicationRemoteDataSource
- MockAdherenceRemoteDataSource
- MockDashboardRemoteDataSource

### 7.2 Test Data

Create test fixtures:

- Sample MedicationModel instances
- Sample AdherenceLogModel instances
- Sample Firestore document snapshots

## Key Implementation Details

### Firestore Collection Structure

Based on specification:

- `/medications/{medicationId}` - User's medications
- `/adherence_logs/{logId}` - Adherence tracking logs
- `/users/{userId}` - User data (handled by Backend Dev 1)

### Query Patterns

- Always filter by userId for user-specific data
- Use isActive field for soft deletes
- Index frequently queried fields
- Use real-time listeners for live updates

### Data Validation

- Validate required fields before Firestore operations
- Validate userId matches authenticated user
- Validate date ranges for queries
- Validate enum values

### Performance Considerations

- Use pagination for large datasets
- Implement caching where appropriate
- Optimize queries with proper indexes
- Use batch writes for multiple operations

## Files to Create/Implement

### Domain Layer (if not exists):

- `lib/features/medication/domain/entities/medication_entity.dart`
- `lib/features/medication/domain/repositories/medication_repository.dart`
- `lib/features/adherence/domain/entities/adherence_log_entity.dart`
- `lib/features/adherence/domain/repositories/adherence_repository.dart`
- `lib/features/dashboard/domain/entities/adherence_entity.dart`
- `lib/features/dashboard/domain/repositories/dashboard_repository.dart`

### Data Layer:

- `lib/features/medication/data/models/medication_model.dart` ✅ (exists, needs implementation)
- `lib/features/medication/data/datasources/medication_remote_data_source.dart` ✅ (exists, needs implementation)
- `lib/features/medication/data/repositories/medication_repository_impl.dart` ✅ (exists, needs implementation)
- `lib/features/adherence/data/models/adherence_log_model.dart` ✅ (exists, needs implementation)
- `lib/features/adherence/data/datasources/adherence_remote_data_source.dart` ✅ (exists, needs implementation)
- `lib/features/adherence/data/repositories/adherence_repository_impl.dart` ✅ (exists, needs implementation)
- `lib/features/dashboard/data/models/adherence_model.dart` ✅ (exists, needs implementation)
- `lib/features/dashboard/data/datasources/dashboard_remote_data_source.dart` ✅ (exists, needs implementation)
- `lib/features/dashboard/data/repositories/dashboard_repository_impl.dart` ✅ (exists, needs implementation)

### Configuration:

- `lib/config/firebase_config.dart` ✅ (exists, needs completion)
- `firestore.indexes.json` (create new)

## Dependencies Needed

- `cloud_firestore` - Already in pubspec.yaml ✅
- `firebase_core` - Already in pubspec.yaml ✅
- `firebase_auth` - For getting current user ID ✅

## Implementation Order

1. Create domain entities and repository interfaces
2. Create data models with Firestore mapping
3. Implement remote data sources with Firestore operations
4. Implement repository classes with error mapping
5. Complete Firebase configuration
6. Create Firestore indexes
7. Test all CRUD operations
8. Test real-time streams
9. Test error handling
10. Test edge cases (offline, permissions, etc.)

### To-dos

- [ ] Complete dependency injection setup and run build_runner to generate config files
- [ ] Implement centralized navigation router with route guards and splash screen
- [ ] Create Firestore and Storage security rules, configure Firebase initialization
- [ ] Create splash screen with authentication state checking and auto-navigation
- [ ] Enhance authentication screens (login, register, password reset) with proper validation and error handling
- [ ] Enhance authentication BLoC with session management, timeout, and security features
- [ ] Complete medication CRUD operations with real-time Firestore streaming, search, filter, and pagination
- [ ] Complete barcode scanner integration with permission handling, validation, and offline caching
- [ ] Ensure medication models match Firestore schema with all required fields and enums
- [ ] Enhance notification system with snooze functionality, action buttons, and adaptive timing
- [ ] Create reminder BLoC for state management and notification interactions
- [ ] Create reminder configuration screens, snooze dialogs, and reminder history
- [ ] Enhance dashboard with real data, adherence statistics, charts, and quick actions
- [ ] Complete adherence tracking system with logging, statistics, trend analysis, and goal tracking
- [ ] Complete adherence analytics screens with calendar view, charts, and missed doses analysis
- [ ] Create pharmacy price comparison feature module with Firestore integration and location search
- [ ] Create side effect reporting feature module with logging, history, and analytics
- [ ] Enhance profile and settings with photo upload, data export, and account management
- [ ] Complete all Firestore data sources with error handling, streaming, and offline persistence
- [ ] Complete SharedPreferences implementation and local caching with offline sync
- [ ] Complete all repository implementations with error mapping, caching, and retry logic
- [ ] Complete all screens according to specification with proper loading, error, and empty states
- [ ] Implement responsive design for different screen sizes and orientations
- [ ] Ensure WCAG 2.1 compliance, proper touch targets, and screen reader support
- [ ] Complete unit tests for domain layer, data layer, and all BLoC classes
- [ ] Create widget tests for all custom widgets and screen interactions
- [ ] Create integration tests for end-to-end user workflows
- [ ] Run flutter analyze, fix warnings, ensure formatting compliance, and review complexity
- [ ] Optimize for 60 FPS, sub-second load times, memory usage, and battery consumption
- [ ] Complete security rules, input validation, and secure data transmission
- [ ] Update README, add API documentation, create architecture diagrams
- [ ] Configure environment-based builds, app signing, and release variants
- [ ] Set up branching strategy, conventional commits, and PR templates