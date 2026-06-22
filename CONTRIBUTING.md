# Contributing to FlutterPulse

First off, thank you for considering contributing to FlutterPulse! 

Following these guidelines helps maintain a professional and welcoming community.

---

## 📋 Table of Contents
- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
  - [Reporting Bugs](#reporting-bugs)
  - [Suggesting Enhancements](#suggesting-enhancements)
  - [Your First Contribution](#your-first-contribution)
  - [Pull Requests](#pull-requests)
- [Development Setup](#development-setup)
- [Code Style](#code-style)
- [Testing](#testing)

---

## Code of Conduct

By participating, you agree to abide by our [Code of Conduct](CODE_OF_CONDUCT.md).

---

## How Can I Contribute?

### Reporting Bugs

**Before submitting a bug report:**
- Check if the issue already exists in [Issues](https://github.com/itxmal03/FlutterPulse/issues)
- Make sure you're using the latest version
- Test with the latest commit if possible

**When submitting a bug report, include:**
- Clear, descriptive title
- Steps to reproduce the bug
- Expected vs actual behavior
- Screenshots or error logs
- Your OS (Linux/Windows/macOS) and Flutter version
- Example: `flutter --version` output

### Suggesting Enhancements

- Use a clear, descriptive title
- Provide a detailed description of the enhancement
- List specific examples of how it would work
- Explain why this enhancement would be useful
- Include mockups or sketches if possible

### Your First Contribution

Look for issues labeled:
- `good first issue` – beginner-friendly tasks
- `help wanted` – needs community help
- `documentation` – docs improvements

### Pull Requests

1. **Fork the repository** and create your feature branch
```bash
   git checkout -b feature/amazing-feature
```

2. **Make your changes** with clear, focused commits
```bash
   git commit -m "Add amazing feature for X"
```

3. **Test your changes**
```bash
   flutter analyze
   dart format .
   flutter test
```

4. **Push to your fork**
```bash
   git push origin feature/amazing-feature
```

5. **Open a Pull Request** against the `main` branch

**Pull Request Guidelines:**
- One PR per feature/fix (keep focused)
- Include screenshots for UI changes
- Update documentation if needed
- Reference issue numbers in the PR description: `Closes #123`
- Write clear commit messages
- Follow the code style guide below

---

## Development Setup

### Prerequisites
- **Flutter 3.22+** – [Installation Guide](https://docs.flutter.dev/get-started/install)
- **Git** – version control
- **Code Editor** – VS Code or Android Studio recommended
- **Linux/Windows/macOS** – choose your target platform

### Clone and Run

```bash
# Clone the repository
git clone https://github.com/itxmal03/FlutterPulse
cd FlutterPulse

# Install dependencies
flutter pub get

# Run the app
flutter run -d linux   # or windows, macos
```

### Build Release Version

```bash
flutter build linux    # or windows, macos
```

The executable will be in `build/linux/x64/release/bundle/`

---

## Code Style

We follow the official [Flutter style guide](https://docs.flutter.dev/reference/flutter-style-guide).

### Before Every Commit:

```bash
# Format all code
dart format .

# Run lint analysis
flutter analyze
```

**Style Notes:**
- Use meaningful variable names
- Add comments for complex logic
- Keep methods small and focused
- Follow MVVM pattern (like existing code)

---

## Testing

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/path/to/test.dart

# Run with coverage
flutter test --coverage
```

---

## 📁 Project Structure

flutter_pulse/

├── lib/

│   ├── core/              # Constants, utilities, plugins

│   ├── models/            # Data models

│   ├── plugins/           # Pipeline plugins

│   ├── service/           # Business logic

│   ├── ui/                # UI screens & widgets

│   └── viewModels/        # State management

├── test/                  # Unit & widget tests

├── assets/

│   ├── config/            # JSON configurations

│   ├── logos/             # App branding

│   └── screenshots/       # Documentation images

└── pubspec.yaml           # Dependencies 

---

## Common Issues & Solutions

**Issue:** `flutter pub get` fails
- **Solution:** Delete `pubspec.lock` and try again

**Issue:** Build fails on Linux
- **Solution:** Install dependencies: `sudo apt install libgtk-3-dev ninja-build`

**Issue:** Analyzer complains about formatting
- **Solution:** Run `dart format .` before committing

---

## Questions?

- **GitHub Issues** – Report bugs or request features
- **GitHub Discussions** – Ask questions and discuss ideas
- **Email** – najafdevs@gmail.com

---

**Thank you for contributing to FlutterPulse! ❤️**

Made with ❤️ by Muhammad Aftab Liaqat & Al-Najaf IT Solutions