# SkillsConnect

SkillsConnect is a cross-platform mobile app built with Flutter and Firebase that connects local service providers (tailors, bakers, hair stylists, and more) with clients in their area. Clients can browse verified providers, book services, and track their bookings in real time. Providers get a personal dashboard to manage orders and monitor earnings. Developed as a Final Project for Mobile Application Development.

---

## Features 

- Modern, responsive UI matching Figma prototype
- Authentication: Email/Password & Google sign-in, password reset, email verification
- Provider & client dashboards
- Real-time messaging
- Marketplace for products/services
- Wallet for earnings and transactions
- Review/rating system
- User preferences (theme/settings)
- Robust state management (BLoC)
- Widget & unit testing

---

## Architecture

The app follows **Flutter Clean Architecture** for clear separation of concerns:

```
lib/
├── data/           # Repository implementations, Firebase data sources
├── domain/         # Business entities and repository interfaces
├── presentation/   # UI pages, BLoC state management
│   ├── blocs/      # AuthBloc, ProviderBloc, SettingsBloc
│   └── pages/      # All screen widgets
├── injection_container.dart   # Dependency injection setup
└── main.dart
```

State management uses the **BLoC pattern** (via `flutter_bloc`). Business logic never sits inside UI widgets; all state changes flow through events and states.

---

## Getting Started

### Prerequisites

- Flutter SDK `>=3.1.0` ([install guide](https://docs.flutter.dev/get-started/install))
- A Firebase account ([console](https://console.firebase.google.com/))
- Android emulator or physical device (Android 6.0+)

### Setup Instructions

1. **Clone the repository**
	```bash
	git clone https://github.com/Karabo-jpg/SkillsConnect.git
	cd SkillsConnect
	```

2. **Install dependencies**
	```bash
	flutter pub get
	```

3. **Configure Firebase**
	- Go to the [Firebase Console](https://console.firebase.google.com/) and create a new project.
	- Register an **Android** app with package name `com.example.skillconnect`.
	- Download `google-services.json` and place it in `android/app/`.
	- For iOS, download `GoogleService-Info.plist` and place it in `ios/Runner/`.
	- Enable **Email/Password** under Authentication > Sign-in method.
	- Create a **Firestore Database** and copy `firestore.rules` into your Security Rules tab.

4. **Run the app**
	```bash
	flutter run
	```

> Run on a physical device or emulator only. Web and desktop builds are not supported.

---

## Firestore Collections

| Collection | Key Fields |
|---|---|
| `users` | `uid`, `email`, `displayName`, `userType`, `createdAt` |
| `providers` | `uid`, `businessName`, `category`, `hourlyRate`, `rating`, `totalEarnings` |
| `bookings` | `bid`, `clientId`, `providerId`, `serviceName`, `status`, `depositAmount`, `scheduledDate`, `createdAt` |

---

## Firebase Security Rules

Security rules are defined in `firestore.rules`:
- Users can only read and write their own profile document.
- Provider profiles are readable by all authenticated users, writable only by the provider.
- Bookings are accessible only to the client or provider involved.

---

## Testing

We use Flutter’s testing libraries for both widget and unit tests.

```bash
flutter test
```

- **Unit tests** (`test/unit_test.dart`): model serialization and business logic
- **Widget tests** (`test/widget_test.dart`): UI component rendering verification

Coverage: >70%. All tests pass.



## Demo Video

Watch our full demo here: https://www.youtube.com/watch?v=SN_f0VklfUs

---

## GitHub Repository

[https://github.com/Karabo-jpg/SkillsConnect]
---

