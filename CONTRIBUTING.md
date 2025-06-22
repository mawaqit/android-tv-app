# Contributing to MAWAQIT Smart Display

Thank you for your interest in contributing to MAWAQIT Smart Display! This document provides guidelines and instructions for contributing to the project.

## Prerequisites

Before you begin, ensure you have the following installed:
- Flutter SDK
- Git
- Android Studio or VS Code (recommended)

**Note**: The scripts in this project (`build.sh`, `format.sh`, `install_apk.sh`, `setup.sh`) are designed for Unix-based environments (Linux, macOS, WSL). Windows users should use WSL (Windows Subsystem for Linux) or Git Bash to run these scripts.

## Development Setup

1. Fork and clone the repository:
   ```bash
   git clone https://github.com/YOUR_USERNAME/android-tv.git
   cd android-tv
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Set up development tools:
   ```bash
   ./scripts/setup.sh
   ```
   This script will:
   - Configure git hooks to automatically run build_runner after checkouts
   - Set up the necessary permissions

## Development Workflow

### Code Generation
The project uses `build_runner` for code generation. There are two ways to handle this:

1. **Automatic Generation**: The git hooks are configured to automatically run `build_runner` after branch checkouts to handle any conflicts. This is set up by the `setup.sh` script.

2. **Manual Generation**: If you need to regenerate code manually:
   ```bash
   ./scripts/build.sh
   ```
   This script runs `build_runner` with the `--delete-conflicting-outputs` flag to handle any conflicts.

### Code Formatting

To ensure consistent code style across the project, you can use the formatting script:

```bash
./scripts/format.sh
```

This script will format your code according to the project's standards and run the build_runner if needed. It's recommended to run this before submitting a pull request.

### Making Changes

1. Create a new branch for your feature/fix:
   ```bash
   git checkout -b feat/your-feature-name
   # or
   git checkout -b fix/your-fix-name
   ```

2. Make your changes and commit them:
   ```bash
   git add .
   git commit -m "Description of your changes"
   ```

3. Push your changes:
   ```bash
   git push origin feat/your-feature-name
   ```

4. Create a Pull Request from your branch to the main repository.

## Testing and Deployment

### Installing APK on Android TV Box

To install the APK specifically for user 0 (primary user) on an Android TV Box:

```bash
./scripts/install_apk.sh /path/to/your-app.apk
```

This script will:
- Verify ADB is installed and a device is connected
- Install the APK specifically for user 0 (primary user)
- Display the users on the device

**Additional Notes for APK Installation**:

- To list all users and their corresponding IDs on your device:
  ```bash
  adb shell pm list users
  ```

- For system apps that were previously uninstalled for a specific user:
  ```bash
  adb shell cmd package install-existing com.example.app
  ```

## Code Style

- Follow the existing code style in the project
- Use meaningful variable and function names
- Add comments for complex logic
- Keep your commits focused and atomic

## Testing

Before submitting a pull request:
1. Run the tests:
   ```bash
   flutter test
   ```
2. Ensure all tests pass
3. Test your changes on different devices/screens if applicable

## Getting Help

If you need help or have questions:
- Open an issue
- Join our community discussions
- Check the [MAWAQIT Volunteer](https://volunteer.mawaqit.net)

## License

By contributing, you agree that your contributions will be licensed under the project's [Attribution-NonCommercial-ShareAlike 4.0 International License](http://creativecommons.org/licenses/by-nc-sa/4.0/).

Thank you for contributing to MAWAQIT Smart Display! 
