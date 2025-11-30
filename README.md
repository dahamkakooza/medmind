# 💊 MedMind

**Your Medication Companion** - A comprehensive medication management and adherence tracking application built with Flutter.

[![Flutter](https://img.shields.io/badge/Flutter-3.24.0+-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.8.0+-0175C2?logo=dart)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Enabled-FFCA28?logo=firebase)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## 📋 Overview

MedMind is a modern, feature-rich mobile application designed to help users manage their medications effectively, track adherence, and maintain better health outcomes. Built with Clean Architecture principles and powered by Firebase, MedMind provides a seamless experience across Android, iOS, and web platforms.

## ✨ Key Features

### 🏥 Medication Management
- **Add & Edit Medications** - Comprehensive medication profiles with dosage, frequency, and instructions
- **Barcode Scanner** - Quick medication entry using barcode scanning
- **Medication List** - Organized view of all your medications
- **Detailed Information** - View complete medication details and history

### 📊 Adherence Tracking
- **Real-time Tracking** - Monitor medication intake in real-time
- **Adherence Analytics** - Visual charts and statistics showing adherence patterns
- **History Logs** - Complete history of medication intake
- **Adherence Summary** - Weekly, monthly, and yearly adherence reports

### 🔔 Smart Notifications
- **Scheduled Reminders** - Never miss a dose with timely notifications
- **Snooze Functionality** - Flexible snooze options (1, 5, 10, 15, 30 minutes)
- **Pending Doses** - Track and manage missed or pending doses
- **Notification Customization** - Personalize notification settings

### 📱 Dashboard
- **Today's Medications** - Quick view of medications due today
- **Adherence Stats** - At-a-glance adherence statistics
- **Quick Actions** - Mark medications as taken directly from dashboard
- **Real-time Updates** - Live synchronization across devices

### 👤 User Profile & Settings
- **Profile Management** - Edit personal information and preferences
- **Theme Customization** - Light, Dark, and System theme modes
- **Multi-language Support** - English, Spanish (Español), and French (Français)
- **Privacy & Security** - Biometric authentication and data backup options

### 🔐 Authentication
- **Email/Password** - Traditional authentication method
- **Google Sign-In** - Quick sign-in with Google account
- **Secure Storage** - Encrypted user data storage

## 🏗️ Architecture

MedMind follows **Clean Architecture** principles with clear separation of concerns:

```
lib/
├── core/                    # Core utilities and shared components
│   ├── constants/          # App-wide constants
│   ├── services/           # Core services (notifications, tracking)
│   ├── theme/              # Theme configuration
│   ├── utils/              # Utility functions
│   └── widgets/            # Reusable widgets
├── config/                  # Configuration files
├── features/               # Feature modules
│   ├── auth/              # Authentication
│   ├── medication/        # Medication management
│   ├── adherence/         # Adherence tracking
│   ├── dashboard/         # Dashboard
│   ├── profile/           # User profile
│   └── notifications/     # Notifications
└── main.dart              # App entry point
```

Each feature follows the **Clean Architecture** pattern:
- **Presentation Layer** - UI, Pages, Widgets, BLoC
- **Domain Layer** - Entities, Use Cases, Repository Interfaces
- **Data Layer** - Models, Data Sources, Repository Implementations

## 🛠️ Tech Stack

### Core
- **Flutter** 3.24.0+ - UI framework
- **Dart** 3.8.0+ - Programming language

### State Management
- **flutter_bloc** - BLoC pattern implementation
- **equatable** - Value equality

### Backend & Database
- **Firebase Core** - Firebase initialization
- **Firebase Auth** - User authentication
- **Cloud Firestore** - NoSQL database
- **Firebase Storage** - File storage
- **Google Sign-In** - OAuth authentication

### Local Storage
- **shared_preferences** - Key-value storage

### Notifications
- **flutter_local_notifications** - Local notifications
- **timezone** - Timezone handling

### UI & Visualization
- **fl_chart** - Charts and graphs
- **mobile_scanner** - Barcode scanning
- **image_picker** - Image selection

### Utilities
- **dartz** - Functional programming
- **intl** - Internationalization
- **permission_handler** - Runtime permissions
- **url_launcher** - URL handling

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.24.0 or higher
- Dart SDK 3.8.0 or higher
- Android Studio / Xcode (for mobile development)
- Firebase account and project

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/medmind.git
   cd medmind
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com)
   - Add Android/iOS/Web apps to your Firebase project
   - Download and place configuration files:
     - `google-services.json` in `android/app/`
     - `GoogleService-Info.plist` in `ios/Runner/`
   - Update `lib/firebase_options.dart` with your Firebase configuration

4. **Configure Firebase Services**
   - Enable Authentication (Email/Password and Google Sign-In)
   - Create Firestore database
   - Set up Firestore security rules (see `firestore.rules`)
   - Enable Firebase Storage

5. **Run the app**
   ```bash
   # For Android
   flutter run

   # For iOS
   flutter run -d ios

   # For Web
   flutter run -d chrome
   ```

## 🧪 Testing

MedMind includes comprehensive test coverage:

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test file
flutter test test/features/medication/domain/medication_verification_tests.dart
```

### Test Categories
- **Unit Tests** - Domain logic and use cases
- **Widget Tests** - UI components
- **Integration Tests** - End-to-end workflows
- **Property-Based Tests** - Custom property testing framework

See [test/README.md](test/README.md) for detailed testing documentation.

## 📱 Supported Platforms

- ✅ Android (API 21+)
- ✅ iOS (iOS 12+)
- ✅ Web
- ✅ macOS (experimental)

## 🌍 Localization

MedMind supports multiple languages:
- 🇺🇸 English (en_US)
- 🇪🇸 Spanish (es_ES)
- 🇫🇷 French (fr_FR)

To add more languages, update the supported locales in `lib/main.dart`.

## 🎨 Theming

MedMind supports three theme modes:
- **Light Mode** - Clean, bright interface
- **Dark Mode** - Easy on the eyes
- **System Default** - Follows device settings

Theme can be changed in Settings → Appearance → Theme.

## 📖 Documentation

- [Project Reports](docs/) - Detailed project documentation
- [Testing Guide](test/README.md) - Comprehensive testing documentation
- [Security Guide](test/features/security/README.md) - Security testing and rules
- [Theme & Language Fix](docs/THEME_LANGUAGE_FIX.md) - Theme and localization implementation

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Authors

- **Your Name** - Initial work

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- All contributors and testers

## 📞 Support

For support, email support@medmind.app or open an issue in the repository.

## 🗺️ Roadmap

- [ ] Apple Health integration
- [ ] Google Fit integration
- [ ] Medication interaction warnings
- [ ] Pharmacy integration
- [ ] Family account sharing
- [ ] Medication refill reminders
- [ ] Doctor appointment scheduling
- [ ] Export health reports

---

**Made with ❤️ using Flutter**
