# Changelog

All notable changes to QuickTrace for Swift will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-01-XX

### Added
- Initial release of QuickTrace for Swift
- Support for iOS 13.0+, macOS 10.15+, tvOS 13.0+, watchOS 6.0+
- Swift 5.7+ compatibility
- Multiple output styles: Default, Colorful, Minimal, Detailed, Table, JSON
- Smart filtering capabilities:
  - Show slow operations only
  - Hide ultra-fast operations
  - Group similar operations
- Cross-platform ANSI color support with terminal detection
- Runtime control features:
  - Enable/disable tracing
  - Silent mode for data collection
  - Dynamic style changes
  - Custom print conditions
- Automatic caller information capture
- Builder pattern API for easy configuration
- Comprehensive examples demonstrating all features
- Full documentation and README
- Swift Package Manager support

### Features
- **Core Tracing**: Simple span tracking with automatic timing
- **Output Styles**: 6 different visualization styles for various use cases
- **Smart Filtering**: Intelligent noise reduction for production use
- **Color Coding**: Duration-based color rules for quick visual analysis
- **Cross-Platform**: Works on all Apple platforms with proper terminal detection
- **Performance**: Lightweight with minimal overhead when disabled
- **Extensible**: Protocol-oriented design for custom extensions

### Examples Included
- BasicExample: Simple usage patterns
- AdvancedExample: Smart filtering and configuration
- FilteringExample: All filtering capabilities
- StylesExample: Visual comparison of all styles
- RuntimeControlExample: Dynamic control features
- RealWorldExample: HTTP API server simulation

### Compatibility
- Swift 5.7+
- iOS 13.0+
- macOS 10.15+
- tvOS 13.0+
- watchOS 6.0+
- Xcode 14.0+
- Swift Package Manager
