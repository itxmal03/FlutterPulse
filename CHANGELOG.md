# Changelog

All notable changes to FlutterPulse will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.0.0] - 22 - June -2026

### Added
- **Core Pipeline System**
  - One-click build automation (Clean → Get → Plugins → Build)
  - Support for multiple build targets: APK, Linux, Windows, Web, and DEB
  - Live console with real-time build output
  - Color-coded logs for better readability
  - Copy All logs functionality
  - Visual progress tracking with animated step chips

- **Plugin Architecture**
  - Extensible plugin system for custom pipeline steps
  - Test Plugin – Runs `flutter test` before build
  - Lint Plugin – Runs `flutter analyze` (warnings don't fail build)
  - Format Plugin – Runs `dart format .` to format code
  - Notify Plugin – Sends desktop notification on build completion
  - Plugin enable/disable via UI and JSON config file
  - Plugin management interface in Plugins tab

- **Build History & Artifacts**
  - Persistent build history with metadata
  - Stores every build with status, duration, and timestamp
  - Versioned artifact storage in `~/.flutter_pulse/artifacts/`
  - One-click artifact folder opening from history
  - Delete individual build records or clear all history
  - Build output exported to user-accessible directory

- **User Interface**
  - Professional dark theme optimized for developer workflows
  - Sidebar navigation with app icon and branding
  - SDK information display (Flutter & Dart versions)
  - Project selection with validation
  - Target validation (prevents invalid platform combinations)
  - Responsive layout for different screen sizes
  - Professional typography and color scheme

- **Architecture & Code Quality**
  - MVVM architecture with Provider state management
  - Clean separation of concerns (UI, Models, Services, ViewModels)
  - Extensible plugin interface with clear contract
  - JSON-based configuration system
  - Cross-platform support (Linux, Windows, macOS)
  - Modular service-oriented design

### Fixed
- Fixed empty pipeline crash on initial startup
- Fixed plugin configuration loading with proper fallback handling
- Fixed Format plugin to use correct `dart format` command
- Fixed target selection validation (Windows builds on Linux now show friendly error)
- Fixed console output color rendering in different terminal contexts
- Fixed artifact storage directory creation on first build

### Security
- No hardcoded credentials or sensitive data
- User data stored in secure home directory (`~/.flutter_pulse/`)
- Build artifacts stored with proper file permissions

### Technical Details
- Built with Flutter 3.22+
- Dart SDK 3.4+
- Process management for reliable build execution
- JSON serialization for configuration and history
- Desktop platform support (Linux, Windows, macOS)

---

## [Unreleased]

### Planned Features
- **Backup Plugin** – Automatic project backup before builds
- **Git Integration** – Pull latest code before build
- **Analytics Dashboard** – Step duration analysis, success rate metrics
- **Parallel Execution** – Run compatible steps simultaneously
- **Advanced Notifications** – Email & Slack integration
- **Custom Scripts** – User-defined pipeline steps
- **iOS/macOS Support** – Extended platform coverage
- **Build Scheduling** – Automated builds on schedule
- **Artifact Management** – Advanced storage and cleanup policies

---

## Installation & Downloads

Latest stable release: **v1.0.0**
- [GitHub Releases](https://github.com/itxmal03/FlutterPulse/releases)
- Supported platforms: Linux, Windows, macOS

---

## How to Report Bugs

Found an issue? Please report it at [Issues](https://github.com/itxmal03/FlutterPulse/issues) with:
- Steps to reproduce
- Expected vs actual behavior
- Screenshots or logs
- Your OS and Flutter version

---

Made with ❤️ by Muhammad Aftab Liaqat & Al-Najaf IT Solutions