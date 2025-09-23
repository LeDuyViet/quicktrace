# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-12-23

### Added
- Initial release of QuickTrace for Dart & Flutter
- Core tracing functionality with `QuickTracer` class
- 6 output styles: Default, Colorful, Minimal, Detailed, Table, JSON
- Smart filtering capabilities:
  - Show slow operations only
  - Hide ultra-fast operations
  - Group similar duration operations
- Cross-platform ANSI color support
- Runtime control features:
  - Enable/disable tracing
  - Silent mode for data collection
  - Dynamic style switching
  - Custom print conditions
- Automatic caller information capture
- Duration-based color coding with 8 categories
- Comprehensive examples covering all features
- Full documentation with best practices
- Support for Dart CLI, Flutter mobile, web, and desktop platforms

### Features
- ✅ Basic span tracing with automatic timing
- ✅ Multiple beautiful output formats
- ✅ Intelligent filtering to reduce noise
- ✅ Programmatic access to measurements
- ✅ Zero external dependencies
- ✅ Cross-platform compatibility
- ✅ Flutter integration examples
- ✅ Performance monitoring utilities

### Examples Included
- Basic usage example
- Advanced filtering demonstration
- All output styles showcase
- Runtime control features
- Real-world API server simulation
- Flutter integration patterns
