# 🚀 Getting Started with QuickTrace

## Quick Setup (< 2 minutes)

### 1. Add Dependency
```yaml
# pubspec.yaml
dependencies:
  quicktrace: ^1.0.0
```

### 2. Install
```bash
dart pub get
# or
flutter pub get
```

### 3. Basic Usage
```dart
import 'package:quicktrace/quicktrace.dart';

void main() async {
  final tracer = QuickTracer('My Operation');
  
  tracer.span('Step 1');
  await Future.delayed(Duration(milliseconds: 50));
  
  tracer.span('Step 2');
  await Future.delayed(Duration(milliseconds: 100));
  
  tracer.end(); // 🎨 Beautiful output!
}
```

## 🎯 Try Examples

```bash
# Get the examples
git clone https://github.com/LeDuyViet/quicktrace.git
cd quicktrace/dart

# Install and run
dart pub get
dart run example/demo.dart
```

## ⚡ Common Patterns

### Development Debugging
```dart
final tracer = QuickTracer('Debug Session',
  outputStyle: OutputStyle.styleColorful);
```

### Performance Analysis
```dart
final tracer = QuickTracer('Performance Check',
  outputStyle: OutputStyle.styleDetailed,
  showSlowOnly: Duration(milliseconds: 100));
```

### Production Monitoring
```dart
final tracer = QuickTracer('Production Task',
  silent: true); // No console output
  
// ... do work ...

if (tracer.totalDuration > Duration(seconds: 2)) {
  logger.warn('Slow operation: ${tracer.totalDuration}');
}
```

### Flutter Integration
```dart
class MyWidget extends StatelessWidget {
  Future<String> _loadData() async {
    final tracer = QuickTracer('Load Data', silent: !kDebugMode);
    
    tracer.span('Fetch API');
    final data = await api.fetchData();
    
    tracer.span('Parse JSON');
    final parsed = json.decode(data);
    
    tracer.end();
    return parsed['result'];
  }
}
```

## 🎨 Output Styles

| Style | Best For | Example |
|-------|----------|---------|
| `styleColorful` | Development | `dart run example/styles_example.dart` |
| `styleDetailed` | Performance Analysis | Progress bars + percentages |
| `styleMinimal` | CI/CD Logs | Compact tree view |
| `styleTable` | Reports | Clean tables |
| `styleJson` | Integrations | Structured data |

## 🔍 Smart Filtering

```dart
// Hide noise, show only important operations
final tracer = QuickTracer('Filtered',
  hideUltraFast: Duration(milliseconds: 1),   // Hide < 1ms
  showSlowOnly: Duration(milliseconds: 50),   // Only show >= 50ms
  groupSimilar: Duration(milliseconds: 10));  // Group similar
```

## 📚 Next Steps

1. **Explore Examples**: `dart run example/styles_example.dart`
2. **Read Full Docs**: [README.md](README.md)  
3. **Check API Reference**: [pub.dev/packages/quicktrace](https://pub.dev/packages/quicktrace)
4. **See Advanced Usage**: [example/real_world_example.dart](example/real_world_example.dart)

---

**Need help?** Check the [examples/](example/) directory for comprehensive demos! 🎯
