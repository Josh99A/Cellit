# Cellit

[![License: MIT](https://img.shields.io/badge/license-MIT-orange)](./LICENSE)
[![Made with Flutter](https://img.shields.io/badge/made%20with-Flutter-blue)](https://flutter.dev/)

**Cellit** is an offline-first Point of Sale (POS) application built with Flutter, designed around **Clean Architecture** principles with automatic data synchronization between local storage (SQLite) and cloud database (Firestore).

The app prioritizes local-first operations, storing all data in SQLite and automatically syncing with Firestore when online. When offline, all user actions (create, update, delete) are recorded as `QueuedActions` in the local database and automatically executed in sequence when internet connectivity is restored.

## Features

### Core Functionality

- **Product Management**: Full CRUD operations for products with image upload support
- **Sales Transactions**: POS interface with cart management and transaction history
- **Thermal Receipt Printing**: Print transaction receipts via USB, Bluetooth, BLE, or network printers with configurable paper sizes (58mm, 72mm, 80mm)
- **User Authentication**: Firebase Authentication with Google Sign-In integration
- **Account Management**: User profile management and settings

### Technical Implementation

- **Offline-First Architecture**: Works seamlessly without internet connection
- **Automatic Data Sync**: SQLite ↔ Firestore bidirectional synchronization
- **Queued Actions**: Automatic retry mechanism for offline operations (create, update, delete)
- **Clean Architecture**: Separation between presentation, domain, and data layers
- **State Management**: Riverpod with the Notifier/State pattern
- **Dependency Injection**: Centralized DI setup for better code organization
- **Unit Testing**: Tests for datasources, repositories, and use cases
- **Material Design 3**: Dark & light theme switching built on the Cellit palette
- **Multi-Platform**: Supports Android, iOS, Windows, macOS, and Linux
- **Error Handling**: User-friendly error messages and states
- **Reusable Widgets**: Custom UI components for consistent design

## Brand

The Cellit palette is seeded from the primary brand color:

| Role      | Color        | Hex       |
| --------- | ------------ | --------- |
| Primary   | Orange       | `#FB8500` |
| Accent    | Amber        | `#FFB703` |
| Secondary | Deep Navy    | `#023047` |
| Tertiary  | Teal         | `#219EBC` |
| Support   | Sky Blue     | `#8ECAE6` |

Logo sources live in [`assets/images/cellit_logo.svg`](assets/images/cellit_logo.svg) (vector) and `assets/images/cellit_logo.png` (raster, also used to generate launcher icons via `flutter_launcher_icons`).

## Project Structure

```
cellit/
├── lib/
│   ├── app/                          # Application setup and configuration
│   │   ├── di/                       # Dependency injection
│   │   ├── error/                    # Error handling
│   │   └── routes/                   # App routing and navigation
│   │
│   ├── core/                         # Core utilities and shared resources
│   │   ├── assets/                   # Asset management
│   │   ├── common/                   # Common utilities (Result wrapper)
│   │   ├── constants/                # App constants
│   │   ├── extensions/               # Dart extensions
│   │   ├── locale/                   # Localization
│   │   ├── services/                 # Core services
│   │   │   ├── connectivity/         # Network connectivity checking
│   │   │   ├── database/             # Local database service (sqflite)
│   │   │   ├── info/                 # Device info service
│   │   │   ├── logger/               # Error logging service
│   │   │   └── printer/              # Thermal printer service
│   │   ├── themes/                   # App theming (colors, sizes, themes)
│   │   ├── usecase/                  # Base usecase interface
│   │   └── utilities/                # Helper utilities (formatters, loggers, etc.)
│   │
│   ├── data/                         # Data layer
│   │   ├── datasources/              # Data sources (interfaces, local, remote)
│   │   ├── models/                   # Data models with JSON serialization
│   │   └── repositories/             # Repository implementations
│   │
│   ├── domain/                       # Domain layer (Business logic)
│   │   ├── entities/                 # Business entities
│   │   ├── repositories/             # Repository interfaces
│   │   └── usecases/                 # Use cases (business logic operations)
│   │
│   ├── presentation/                 # Presentation layer (UI)
│   │   ├── providers/                # State management (Riverpod)
│   │   ├── screens/                  # UI screens
│   │   └── widgets/                  # Reusable UI components
│   │
│   ├── firebase_options.dart         # Firebase configuration
│   └── main.dart                     # App entry point
│
├── test/                             # Unit and widget tests
└── assets/                           # Static assets
```

## Getting Started

### Prerequisites

- [Flutter](https://flutter.dev/docs/get-started/install)
- [Dart](https://dart.dev/get-dart)
- Firebase account for backend services

### Installation

1. **Install dependencies:**

   ```sh
   flutter pub get
   ```

2. **Set up Firebase:**
   - Create a new project on [Firebase](https://firebase.google.com/).
   - Configure the app for your project (bundle ID `com.cellit.pos`):

     ```sh
     flutterfire configure
     ```

   - Enable the Google authentication provider
   - Update Cloud Firestore rules to allow read/write operations:

   ```
   service cloud.firestore {
     match /databases/{database}/documents {
       match /{document=**} {
         allow read, write: if request.auth != null;
       }
     }
   }
   ```

   - Add Cloud Firestore indexes to enable queries (see `docs/firestore_indexes.png`)
   - Update Firebase Storage rules to allow read/write operations:

   ```
   service firebase.storage {
     match /b/{bucket}/o {
       match /{allPaths=**} {
         allow read, write: if request.auth != null;
       }
     }
   }
   ```

3. **Set up your `config.json` file**
   <br/> `GOOGLE_SERVER_CLIENT_ID` is the `Web client ID` from your Firebase Google sign-in provider

   ```
   {
     "GOOGLE_SERVER_CLIENT_ID": "xxxxxxxxxxxxx.apps.googleusercontent.com"
   }
   ```

4. **Run the application:**
   ```sh
   flutter run --dart-define-from-file config.json
   ```

### Test

```sh
flutter test --coverage
```

## AI Agent Guidelines

This project includes documentation files designed for AI coding agents (e.g., Claude Code) to keep code consistent when modifying the project:

- [`CLAUDE.md`](CLAUDE.md) — Project conventions (architecture, naming, code style)
- [`UI.md`](UI.md) — UI reference (layouts, components, design specs)
- [`DATABASE.md`](DATABASE.md) — Database schema reference (tables, columns)
- [`WORKFLOW.md`](WORKFLOW.md) — Git workflow (commits, branches, PRs)

## Attribution

Cellit is based on [flutter_pos](https://github.com/elrizwiraswara/flutter_pos) by Elriz Wiraswara, used under the MIT License.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
