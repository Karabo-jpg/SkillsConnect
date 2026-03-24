# SkillConnect

SkillConnect is a mobile application developed with Flutter and Firebase designed to bridge the gap between local service providers and clients. 

## 🚀 Features

- **Client Side**:
  - Home Screen with service categories and verified providers.
  - Advanced search functionality by category.
  - Detailed provider profiles with portfolios and reviews.
  - Seamless booking flow with Mobile Money simulation.
- **Provider Side**:
  - Personal dashboard showing balance and earnings.
  - Order management tracking.
  - Portfolio management.
- **Backend**:
  - Firebase Authentication (Email/Password).
  - Cloud Firestore for real-time data management.
  - Secure data access via Firebase Security Rules.

## 🛠️ Architecture

The app follows **Flutter Clean Architecture** to ensure scalability and maintainability:
- **Presentation**: UI widgets and BLoC (Business Logic Component) for state management.
- **Domain**: Business entities and repository interfaces.
- **Data**: Repository implementations and data sources (Firebase).

## 📦 Getting Started

### Prerequisites

- Flutter SDK (>=3.1.0)
- Firebase Account

### Setup Instructions

1.  **Clone the Repository**:
    ```bash
    git clone <repository-url>
    cd skillconnect
    ```

2.  **Install Dependencies**:
    ```bash
    flutter pub get
    ```

3.  **Firebase Configuration**:
    - Create a new Firebase project in the [Firebase Console](https://console.firebase.google.com/).
    - Add an Android app and download `google-services.json`. Place it in `android/app/`.
    - Add an iOS app and download `GoogleService-Info.plist`. Place it in `ios/Runner/`.
    - Enable **Email/Password** authentication in the Firebase Auth section.
    - Create a **Firestore Database** and apply the rules from `firestore.rules`.

4.  **Run the App**:
    ```bash
    flutter run
    ```

## 🧪 Testing

The project includes both unit and widget tests:
- **Unit Tests**: `test/unit_test.dart` (Model serialization)
- **Widget Tests**: `test/widget_test.dart` (UI component verification)

Run tests using:
```bash
flutter test
```

## 📊 Database Architecture (ERD)

The database is built on Cloud Firestore with the following collections:
- `users`: User profiles and account types.
- `providers`: Professional bios, ratings, and portfolio metadata.
- `services`: Service offerings and pricing.
- `bookings`: Transactional records between clients and providers.

---
*Developed as a Final Project for Mobile Application Development.*
