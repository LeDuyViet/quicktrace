# 🚀 QuickTrace for Swift

A lightweight, colorful tracing library for Swift with cross-platform safe colors and smart filtering capabilities. Perfect for iOS, macOS, tvOS, and watchOS applications.

![QuickTrace Demo](../StyleColorful.png)

*Example showing StyleColorful output with performance analysis*

## 📦 Installation

### Swift Package Manager

Add QuickTrace to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/LeDuyViet/quicktrace-swift.git", from: "1.0.0")
]
```

Or add it through Xcode:
1. File → Add Package Dependencies
2. Enter the repository URL
3. Select version and add to your target

### Platform Requirements

- **iOS** 13.0+
- **macOS** 10.15+
- **tvOS** 13.0+
- **watchOS** 6.0+
- **Swift** 5.7+

## 🚀 Quick Start

```swift
import QuickTrace

func apiCall() {
    let tracer = QuickTrace(name: "API Call")
        .with(style: .colorful)
    
    tracer.span("Database query")
    Thread.sleep(forTimeInterval: 0.050) // 50ms
    
    tracer.span("Process data")
    Thread.sleep(forTimeInterval: 0.020) // 20ms
    
    tracer.span("Send response")
    Thread.sleep(forTimeInterval: 0.010) // 10ms
    
    tracer.end() // Automatically prints colorful output
}
```

## ⚙️ Configuration Options

```swift
let tracer = QuickTrace(name: "Complex Operation")
    // Only show operations slower than 100ms
    .with(option: .showSlowOnly(0.100))
    
    // Hide operations faster than 1ms
    .with(option: .hideUltraFast(0.001))
    
    // Group similar duration operations
    .with(option: .groupSimilar(0.010))
    
    // Custom output style
    .with(style: .detailed)
    
    // Only print if total duration >= 50ms
    .with(option: .minTotalDuration(0.050))
    
    // Silent mode (collect data but don't print)
    .with(option: .silent(true))
    
    // Disable tracing completely
    .with(option: .enabled(false))
```

## 🎨 Output Styles

QuickTrace supports 6 different output styles:

- **`.default`** - Simple table format
- **`.colorful`** - Modern with Unicode borders  
- **`.minimal`** - Compact tree view
- **`.detailed`** - Full analysis with statistics
- **`.table`** - Clean table format
- **`.json`** - Structured JSON output

### Style Examples

```swift
// Colorful style with smart filtering
let tracer = QuickTrace.colorful("API Processing")
    .with(option: .hideUltraFast(0.001))

// Detailed analysis
let tracer = QuickTrace.detailed("Performance Analysis")

// Minimal output
let tracer = QuickTrace.minimal("Quick Check")

// JSON for logging systems
let tracer = QuickTrace.json("Structured Logging")
```

## 🔍 Smart Filtering

QuickTrace includes intelligent filtering to reduce noise and focus on important operations:

### Individual Filters

```swift
// Show only slow operations
.with(option: .showSlowOnly(0.100)) // >= 100ms

// Hide ultra-fast operations  
.with(option: .hideUltraFast(0.001)) // < 1ms

// Group similar operations
.with(option: .groupSimilar(0.010)) // ±10ms
```

### Combined Smart Filter

```swift
let smartFilter = SmartFilter(
    slowThreshold: 0.050,      // Show >= 50ms
    ultraFastThreshold: 0.002, // Hide < 2ms
    similarThreshold: 0.015    // Group ±15ms
)

let tracer = QuickTrace(name: "Smart Analysis")
    .with(style: .detailed)
    .with(smartFilter: smartFilter)
```

### Convenience Method

```swift
// Pre-configured smart filtering
let tracer = QuickTrace.smartFiltered("Performance Analysis",
    slowThreshold: 0.050,
    hideUltraFast: 0.001,
    groupSimilar: 0.010
)
```

## 📊 Runtime Control

```swift
// Enable/disable tracing
tracer.setEnabled(false)

// Silent mode (collect data but don't print)
tracer.setSilent(true)

// Change style at runtime
tracer.setOutputStyle(.json)

// Custom print condition
tracer.setPrintCondition { tracer in
    return tracer.getTotalDuration() > 0.100
}

// Get measurements programmatically
let measurements = tracer.getMeasurements()
let totalDuration = tracer.getTotalDuration()
```

## 🎯 Color Rules

QuickTrace uses intelligent color coding based on operation duration:

| Duration | Color | Category |
|----------|-------|----------|
| > 3s | Red Bold | Very Slow |
| 1s - 3s | Red | Slow |
| 500ms - 1s | Yellow | Medium-Slow |
| 200ms - 500ms | Bright Blue | Medium |
| 100ms - 200ms | Cyan | Normal |
| 50ms - 100ms | Green | Fast |
| 10ms - 50ms | Bright Green | Very Fast |
| < 10ms | Bright Black | Ultra Fast |

### Cross-Platform Compatibility

Colors are automatically adjusted for:
- Xcode console
- Terminal.app
- iOS Simulator
- Device debugging
- CI/CD environments

## 📍 Caller Information

QuickTrace automatically captures file and line information:

```swift
let tracer = QuickTrace(name: "My Function") 
// Will show: MyFile.swift:123 in output
```

You can also pass custom caller info:

```swift
let tracer = QuickTrace(
    name: "Custom Trace",
    callerInfo: CallerInfo(file: #file, line: #line, function: #function)
)
```

## 🔧 Advanced Usage

### Conditional Tracing

```swift
// Only trace in debug builds
#if DEBUG
let tracer = QuickTrace.detailed("Debug Analysis")
#else
let tracer = QuickTrace.disabled("Production")
#endif
```

### Data Analysis

```swift
let tracer = QuickTrace.silent("Background Analysis")

// ... perform operations ...

tracer.end()

// Analyze collected data
let measurements = tracer.getMeasurements()
let slowOperations = measurements.filter { $0.duration > 0.100 }
let totalTime = tracer.getTotalDuration()

print("Found \(slowOperations.count) slow operations")
print("Total execution time: \(totalTime)s")
```

### Integration with Logging

```swift
import os.log

let tracer = QuickTrace.json("API Request")
    .with(option: .silent(true))

// ... perform operations ...

tracer.end()

// Log as structured data
let measurements = tracer.getMeasurements()
os_log("API completed with %d operations in %fs", 
       measurements.count, tracer.getTotalDuration())
```

## 📱 iOS/macOS Integration

### SwiftUI Integration

```swift
import SwiftUI
import QuickTrace

struct ContentView: View {
    var body: some View {
        Button("Analyze Performance") {
            analyzePerformance()
        }
    }
    
    func analyzePerformance() {
        let tracer = QuickTrace.colorful("UI Performance")
        
        tracer.span("Data loading")
        // Simulate data loading
        Thread.sleep(forTimeInterval: 0.050)
        
        tracer.span("UI update")
        DispatchQueue.main.async {
            // UI updates
            tracer.end()
        }
    }
}
```

### Combine Integration

```swift
import Combine
import QuickTrace

class APIService {
    func fetchData() -> AnyPublisher<Data, Error> {
        let tracer = QuickTrace.detailed("API Fetch")
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .handleEvents(
                receiveSubscription: { _ in
                    tracer.span("Network request started")
                },
                receiveOutput: { _ in
                    tracer.span("Data received")
                },
                receiveCompletion: { _ in
                    tracer.end()
                }
            )
            .map(\.data)
            .eraseToAnyPublisher()
    }
}
```

## 🧪 Testing

QuickTrace is perfect for performance testing:

```swift
import XCTest
import QuickTrace

class PerformanceTests: XCTestCase {
    
    func testAPIPerformance() {
        let tracer = QuickTrace.silent("Performance Test")
        
        // ... perform operations ...
        
        tracer.end()
        
        let totalTime = tracer.getTotalDuration()
        XCTAssertLessThan(totalTime, 1.0, "API should complete within 1 second")
        
        let slowOperations = tracer.getMeasurements().filter { $0.duration > 0.100 }
        XCTAssertTrue(slowOperations.isEmpty, "No operations should take longer than 100ms")
    }
}
```

## 🔧 Building and Running Examples

### Command Line

```bash
# Navigate to swift directory
cd swift/

# Run basic example
swift run BasicExample

# Run advanced filtering example
swift run FilteringExample

# Run all styles demonstration
swift run StylesExample

# Run runtime control examples
swift run RuntimeControlExample

# Run real-world simulation
swift run RealWorldExample
```

### Xcode

1. Open `Package.swift` in Xcode
2. Select example target from scheme selector
3. Run (⌘+R)

## 📝 Examples

The package includes comprehensive examples:

- **BasicExample** - Simple usage patterns
- **AdvancedExample** - Smart filtering and configuration
- **FilteringExample** - All filtering capabilities
- **StylesExample** - Visual comparison of all styles
- **RuntimeControlExample** - Dynamic control features
- **RealWorldExample** - HTTP API server simulation

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](../LICENSE) file for details.

## 🔗 Related Projects

- [QuickTrace for Go](../go/) - Original Go implementation
- [QuickTrace for Dart](../dart/) - Dart/Flutter version
- [QuickTrace for Java](../java/) - Java implementation
- [QuickTrace for JavaScript](../js/) - JavaScript/Node.js version

