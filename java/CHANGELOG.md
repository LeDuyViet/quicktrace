# Changelog

Tất cả các thay đổi quan trọng cho QuickTrace Java sẽ được documented trong file này.

## [1.0.0] - 2024-12-23

### Added
- 🎉 **Initial release** của QuickTrace for Java
- ✨ **Core Features**:
  - Lightweight tracing với minimal overhead
  - Cross-platform ANSI color support
  - 6 output styles: Default, Colorful, Minimal, Detailed, Table, JSON
  - Smart filtering capabilities
  - Runtime control và configuration
  - Automatic caller information capture

- 🎨 **Output Styles**:
  - `OutputStyle.DEFAULT` - Simple table format
  - `OutputStyle.COLORFUL` - Modern với Unicode borders
  - `OutputStyle.MINIMAL` - Compact tree view
  - `OutputStyle.DETAILED` - Full analysis với statistics
  - `OutputStyle.TABLE` - Clean table format
  - `OutputStyle.JSON` - Structured JSON output

- 🔍 **Smart Filtering**:
  - `showSlowOnly(threshold)` - Chỉ hiển thị operations chậm
  - `hideUltraFast(threshold)` - Ẩn operations rất nhanh
  - `groupSimilar(threshold)` - Nhóm operations có duration tương tự
  - `smartFilter()` - Combine tất cả filters

- ⚙️ **Configuration Options**:
  - Builder pattern cho flexible configuration
  - Runtime enable/disable tracing
  - Silent mode cho data collection only
  - Custom print conditions
  - Minimum duration thresholds

- 🎯 **Color Rules**:
  - 8-tier color system từ Ultra Fast đến Very Slow
  - Cross-platform safe colors
  - Automatic categorization based on duration
  - Progress bar colors cho percentages

- 📊 **Runtime Control**:
  - Enable/disable tracing at runtime
  - Change output styles dynamically
  - Silent mode toggle
  - Custom print conditions
  - Programmatic access to measurements

- 🛠️ **Developer Experience**:
  - Comprehensive examples cho all features
  - Unit tests với JUnit 5
  - Maven build system
  - Cross-platform build scripts
  - Detailed documentation

- 📚 **Examples**:
  - `BasicExample` - Simple usage
  - `AdvancedExample` - Smart filtering
  - `StylesExample` - All output styles
  - `FilteringExample` - Filtering capabilities
  - `RuntimeControlExample` - Runtime control features

- 🧪 **Testing**:
  - Unit tests cho core functionality
  - Color rules testing
  - Builder pattern testing
  - Smart filtering testing

### Technical Details
- **Minimum Java Version**: Java 11
- **Dependencies**: 
  - Jackson Core for JSON output
  - JUnit 5 for testing
- **Build System**: Maven 3.6+
- **Package Structure**: `com.leduy.quicktrace`

### Platform Support
- ✅ Windows (Command Prompt, PowerShell)
- ✅ Linux (Terminal)
- ✅ macOS (Terminal)
- ✅ IDE Consoles (IntelliJ IDEA, Eclipse, VS Code)

### Performance
- Minimal overhead khi disabled
- Efficient string building
- Memory-efficient measurement collection
- Fast color rule lookup

### Documentation
- Comprehensive README với examples
- Javadoc documentation
- Build instructions
- Usage guidelines
- Contributing guide

---

## Links
- [Repository](https://github.com/LeDuyViet/quicktrace)
- [Java Documentation](README.md)
- [Go Version](../go/)
- [Dart Version](../dart/)
- [JavaScript Version](../js/)
