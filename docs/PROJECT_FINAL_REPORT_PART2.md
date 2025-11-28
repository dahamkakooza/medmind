## 4. SYSTEM ARCHITECTURE & DESIGN

### 4.1 Architectural Overview

MedMind implements **Clean Architecture** principles, ensuring separation of concerns, testability, and maintainability. The architecture consists of three distinct layers:

```
┌─────────────────────────────────────────────────────────┐
│                  PRESENTATION LAYER                      │
│  (UI, Widgets, BLoCs, Pages)                            │
│  - User Interface Components                             │
│  - State Management (BLoC Pattern)                       │
│  - Navigation & Routing                                  │
└────────────────┬────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────┐
│                    DOMAIN LAYER                          │
│  (Entities, Use Cases, Repository Interfaces)           │
│  - Business Logic                                        │
│  - Core Entities                                         │
│  - Abstract Repositories                                 │
└────────────────┬────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────┐
│                     DATA LAYER                           │
│  (Repository Implementations, Data Sources, Models)     │
│  - Firebase Integration                                  │
│  - Local Storage                                         │
│  - API Communication                                     │
└─────────────────────────────────────────────────────────┘
```

### 4.2 Project Structure

```
lib/
├── core/                           # Shared utilities and components
│   ├── constants/                  # App-wide constants
│   ├── error/                      # Error handling
│   ├── theme/                      # Design system
│   ├── utils/                      # Helper functions
│   └── widgets/                    # Reusable UI components
│
├── features/                       # Feature modules
│   ├── auth/                       # Authentication feature
│   │   ├── data/
│   │   │   ├── datasources/       # Firebase Auth integration
│   │   │   ├── models/            # User model
│   │   │   └── repositories/      # Auth repository implementation
│   │   ├── domain/
│   │   │   ├── entities/          # User entity
│   │   │   ├── repositories/      # Auth repository interface
│   │   │   └── usecases/          # Login, Register, Logout
│   │   └── presentation/
│   │       ├── blocs/             # AuthBloc
│   │       ├── pages/             # Login, Register pages
│   │       └── widgets/           # Auth-specific widgets
│   │
│   ├── medication/                 # Medication management
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── adherence/                  # Adherence tracking
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   └── profile/                    # User profile
│       ├── data/
│       ├── domain/
│       └── presentation/
│
├── injection_container.dart        # Dependency injection setup
└── main.dart                       # Application entry point
```


### 4.3 Design Patterns Implemented

#### 4.3.1 BLoC (Business Logic Component) Pattern

The BLoC pattern separates business logic from UI, ensuring:
- **Testability:** Business logic can be tested independently
- **Reusability:** BLoCs can be shared across multiple widgets
- **Predictability:** State changes are explicit and traceable

**Example: AuthBloc Implementation**

```dart
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInWithEmail signInWithEmail;
  final SignInWithGoogle signInWithGoogle;
  final SignOut signOut;
  
  AuthBloc({
    required this.signInWithEmail,
    required this.signInWithGoogle,
    required this.signOut,
  }) : super(AuthInitial()) {
    on<SignInWithEmailEvent>(_onSignInWithEmail);
    on<SignInWithGoogleEvent>(_onSignInWithGoogle);
    on<SignOutEvent>(_onSignOut);
  }
  
  Future<void> _onSignInWithEmail(
    SignInWithEmailEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await signInWithEmail(
      Params(email: event.email, password: event.password),
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }
}
```

#### 4.3.2 Repository Pattern

Abstracts data sources, allowing:
- Easy switching between data sources (Firebase, local storage, API)
- Simplified testing with mock repositories
- Clear separation between data and business logic

#### 4.3.3 Dependency Injection

Using GetIt and Injectable for:
- Loose coupling between components
- Simplified testing
- Better code organization

```dart
@module
abstract class AppModule {
  @lazySingleton
  FirebaseAuth get firebaseAuth => FirebaseAuth.instance;
  
  @lazySingleton
  FirebaseFirestore get firestore => FirebaseFirestore.instance;
}
```

