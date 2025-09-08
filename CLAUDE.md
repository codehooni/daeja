# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter mobile application called "daeja" that displays parking lot information in Jeju Island. The app uses the Naver Map SDK for map functionality and fetches real-time parking data from the Jeju IT API.

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

### Core Structure
- **main.dart**: App entry point with Naver Map initialization and Provider setup
- **pages/**: Main UI screens (HomePage, SettingsPage, SearchPage, HistoryPage)
  - MainPage acts as the root with bottom navigation
  - Currently only HomePage and SettingsPage are active
- **models/**: Data models (ParkingLot)
- **service/**: API services (ParkingService for Jeju parking data)
- **widgets/**: Reusable UI components
- **theme/**: Theme management with dark/light mode support via Provider

### Key Dependencies
- **flutter_naver_map**: Naver Map integration with client ID `wg25ls4i17`
- **provider**: State management for theme switching
- **geolocator/location**: Location services for map functionality
- **http**: API calls to Jeju IT parking services

### API Integration
The app fetches parking data from two Jeju IT endpoints:
- Info API: `http://api.jejuits.go.kr/api/infoParkingInfoList?code=860725`
- State API: `http://api.jejuits.go.kr/api/infoParkingStateList?code=860725`

### Custom UI Framework
The `ceyhun/` directory contains custom UI utilities:
- Text extensions for styling
- Container widgets
- Padding helpers
- Width/height utilities

### Data Flow
1. ParkingService fetches data from both info and state APIs
2. Data is combined into ParkingLot models
3. Map displays parking locations with availability status
4. Theme changes are managed through ThemeProvider

## Development Notes

- The app targets SDK version ^3.8.1
- Uses Material Design with custom theme implementation
- Bottom navigation is partially implemented (search/history pages commented out)
- Naver Map requires proper client ID configuration for production use