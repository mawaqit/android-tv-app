# Mawaqit Android TV

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Installation](#installation)
3. [Project Setup](#project-setup)
4. [Environment Variables](#environment-variables)
5. [Running the App](#running-the-app)
6. [Development Section](#development-section)

## Prerequisites

Before you begin, ensure you have the following installed:

- Flutter SDK (version 3.27.1)
- Git
- Dart

## Installation

There are several ways to install **Flutter Version Management**  [(FVM)](https://fvm.app/). Choose the method that best suits your operating system and preferences.

### FVM Installation Options

#### 1. Install via Install.sh (Unix-based systems)

You can install FVM by running an installation script:

```bash  
curl -fsSL https://fvm.app/install.sh | bash  
```  

#### 2. Install via Homebrew (macOS)

For macOS users, FVM can be installed using Homebrew:

```bash  
brew tap leoafarias/fvmbrew install fvm  
```  

To uninstall:

```bash  
brew uninstall fvmbrew untap leoafarias/fvm 
```

#### 3. Install via Chocolatey (Windows)

For Windows users, FVM can be installed using Chocolatey:

```bash  
choco install fvm
```

#### 4. Install via Dart pub (Cross-platform)

If the above methods don't work, you can install FVM using Dart's pub:

```bash  
dart pub global activate fvm
```

#### 5. Standalone Packages

You can also download standalone packages from the [FVM GitHub releases page](https://github.com/leoafarias/fvm/releases). Choose the appropriate package for your operating system and architecture.

### Alternative Installation Methods

If you encounter issues with the above methods, try these alternatives:

1. **Manual Installation:**
- Download the FVM binary for your platform from the [releases page](https://github.com/leoafarias/fvm/releases).
- Add the binary to your system's PATH.

2. **Build from Source:**
- Clone the FVM repository: `git clone https://github.com/leoafarias/fvm.git`
- Navigate to the cloned directory: `cd fvm`
- Run: `dart pub get`
- Activate FVM: `dart pub global activate --source path .`

3. **Using Flutter:**  
   If you already have Flutter installed, you can use it to install FVM:
```bash  
flutter pub global activate fvm
```

### Verifying Installation

After installation, verify that FVM is correctly installed by running:

```bash  
fvm --version
```

This should display the installed FVM version.

### Troubleshooting

If you encounter any issues during installation:
- Ensure your system meets the prerequisites for FVM.
- Check your system's PATH to make sure it includes the directory where FVM is installed.
- Consult the [FVM GitHub issues page](https://github.com/leoafarias/fvm/issues) for known problems and solutions.

- **Set Up FVM:**

Use FVM to install the required Flutter version:

```sh  
fvm install 3.27.1
fvm use 3.27.1
```

## Project Setup

### 2. Clone the Repository

- Clone the project:

```sh  
git clone https://github.com/mawaqit/android-tv-app```  
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

## Running the App

- Run the app with environment variables:

```sh  
flutter run --dart-define=mawaqit.api.key=your_api_key --dart-define=mawaqit.sentry.dns=your_sentry_dns
```

### Note:

Replace `your_api_key` and `your_sentry_dns` with your actual values.
  
---

## Development Section

This section is for developers who need to perform additional tasks for development purposes.

### Asset Generation

#### 1. Install Asset Generator

If you need to generate assets, first install the asset generator:

```bash  
dart pub global activate flutter_asset_generator
```

#### 2. Generate Asset File

To generate the asset file, run:

```bash  
fgen  
```
