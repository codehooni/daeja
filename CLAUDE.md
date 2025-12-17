# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter mobile application called "daeja" that displays parking lot information across South Korea, with focus on Jeju Island. The app follows Clean Architecture principles, uses the Naver Map SDK for map functionality, and fetches real-time parking data from multiple public APIs (Jeju IT, Airport, Seoul).

## Development Commands

### Build and Run
- `flutter run` - Run the app on connected device/simulator
- `flutter build apk` - Build APK for Android
- `flutter build ios` - Build for iOS (requires macOS with Xcode)

### Code Quality
- `flutter analyze` - Run static analysis with linting rules from `package:flutter_lints`
- `flutter test` - Run unit and widget tests
- `flutter clean` - Clean build artifacts
- `flutter pub get` - Install/update dependencies

### Dependencies Management
- `flutter pub upgrade` - Upgrade packages to latest compatible versions
- `flutter pub outdated` - Check for newer package versions

## Architecture Overview

This project follows **Clean Architecture** principles with clear separation of concerns.

### Clean Architecture Layers

Each feature domain is organized into three layers:

1. **Data Layer** (`features/*/data/`)
   - **datasources/**: API clients and data sources (remote/local)
   - **entities/**: API response models
   - **mappers/**: Entity to Domain model conversion
   - **repositories/**: Implementation of domain repository interfaces

2. **Domain Layer** (`features/*/domain/`)
   - **models/**: Business logic models (immutable)
   - **repositories/**: Repository interfaces (contracts)
   - **services/**: Business logic and use cases

3. **Presentation Layer** (`features/*/presentation/`)
   - **providers/**: Riverpod state management providers
   - **screens/**: UI screens (to be organized)
   - **widgets/**: Feature-specific UI components

### Feature Domains

The app is divided into four main domains:

- **auth**: Firebase phone authentication
- **location**: GPS location services and user position tracking
- **parking**: Parking lot data from multiple APIs (Jeju, Airport, Seoul, Private)
- **user**: User profile and vehicle information

### Core Module

- **core/constants/**: App-wide constants (airports, APIs, app configs)
- **core/utils/**: Utility functions (logger, formatters)
- **core/widgets/**: Reusable UI components across features

### Key Dependencies

- **flutter_riverpod**: State management (replacing Provider/BLoC)
- **firebase_auth**: Phone number authentication
- **cloud_firestore**: Backend database
- **flutter_naver_map**: Naver Map integration
- **geolocator**: Location services
- **hive**: Local storage
- **http/dio**: Network requests

### API Integration

The app integrates with multiple public APIs:
- **Jeju IT API**: Real-time parking info for Jeju Island
- **Airport API**: National airport parking data
- **Seoul Open API**: Seoul city parking lots
- **Firebase Firestore**: Private parking lot data

### Data Flow

1. **DataSources** fetch raw data from APIs or local storage
2. **Mappers** convert API entities to domain models
3. **Repositories** provide clean interfaces for data access
4. **Services** implement business logic using repositories
5. **Providers** manage state and expose data to UI
6. **Screens/Widgets** display data and handle user interactions

## Development Notes

- The app targets SDK version ^3.8.1
- Uses Material Design with custom theme implementation
- Bottom navigation is partially implemented (search/history pages commented out)
- Naver Map requires proper client ID configuration for production use