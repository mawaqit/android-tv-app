# Mawaqit Android TV

## Prerequisites

### 1. Install FVM (Flutter Version Manager)

To ensure compatibility with the Flutter version used in this project, it's recommended to use [FVM](https://fvm.app/).

- **Flutter Version:** 3.13.9

- **Install FVM:**

  ```sh
  dart pub global activate fvm
  ```

- **Set Up FVM:**

  Use FVM to install the required Flutter version:

  ```sh
  fvm install 3.13.9
  fvm use 3.13.9
  ```

## Project Setup

### 2. Clone the Repository

- Clone the project:

  ```sh
  git clone https://github.com/mawaqit/android-tv-app
  cd android-tv-app
  ```

- Install dependencies:

  ```sh
  flutter pub get
  ```

- Generate necessary files:

  ```sh
  flutter pub run build_runner build --delete-conflicting-outputs
  ```

## Environment Variables

### 3. Check Environment Variables

Ensure you have set the following environment variables:

```dart
const kApiToken = String.fromEnvironment('mawaqit.api.key');
const kSentryDns = String.fromEnvironment('mawaqit.sentry.dns');
```

- Run the app with environment variables:

  ```sh
  flutter run --dart-define=mawaqit.api.key=your_api_key --dart-define=mawaqit.sentry.dns=your_sentry_dns
  ```

## Asset Generation

### Setting Up `Mawaqit Android TV`

1. **Install the Asset Generator:**

   Install `flutter_asset_generator` globally:

   ```sh
   dart pub global activate flutter_asset_generator
   ```

2. **Generate Asset File:**

   Run the asset generator with:

   ```sh
   fgen
   ```

### Note:

Replace `your_api_key` and `your_sentry_dns` with your actual values.
