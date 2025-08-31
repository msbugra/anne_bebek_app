# Firebase Setup Instructions

This document provides instructions for setting up Firebase services in the Anne Bebek application.

## Prerequisites

1. A Google account
2. Firebase project created in the Firebase Console

## Setup Steps

### 1. Create Firebase Project

1. Go to the [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project"
3. Enter project name (e.g., "Anne Bebek App")
4. Accept the terms and conditions
5. Enable Google Analytics if desired
6. Click "Create project"

### 2. Register Android App

1. In the Firebase Console, click "Add app" or the Android icon
2. Enter the package name: `com.example.anne_bebek_app`
3. Enter an app nickname (optional)
4. Enter the debug signing certificate SHA-1 (optional but recommended)
5. Click "Register app"

### 3. Download Configuration File

1. Download the `google-services.json` file
2. Place it in the `android/app` directory of your project

### 4. Add Firebase SDK

The Firebase dependencies have already been added to `pubspec.yaml`. Make sure to run:

```
flutter pub get
```

### 5. Add Google Services Plugin

In `android/build.gradle`, add the Google services classpath:

```gradle
buildscript {
  dependencies {
    // ... other dependencies
    classpath 'com.google.gms:google-services:4.3.15'
  }
}
```

In `android/app/build.gradle`, apply the Google services plugin:

```gradle
apply plugin: 'com.google.gms.google-services'
```

### 6. Initialize Firebase in Your App

Firebase initialization has already been added to `main.dart`. No additional steps are needed.

## Firebase Services Used

### Firebase Crashlytics

Used for error reporting in production. The app automatically sends unhandled errors to Crashlytics.

### Firebase Analytics

Used for tracking user interactions and app usage patterns.

## Testing Firebase Integration

To test if Firebase is properly integrated:

1. Run the app in debug mode
2. Trigger an error condition
3. Check the Firebase Console for error reports

## Troubleshooting

### Common Issues

1. **Missing google-services.json**: Make sure the file is in the correct location (`android/app`)

2. **Gradle sync issues**: Try running `flutter clean` and then `flutter pub get`

3. **Firebase not initializing**: Check that all dependencies are properly added

### Error Messages

- "Default FirebaseApp is not initialized": Check that google-services.json is properly placed and Gradle plugins are correctly configured

## Additional Configuration

For production apps, you may want to configure:

1. Crashlytics custom keys and logs
2. Analytics custom events
3. Performance monitoring