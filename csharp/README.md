# 🚀 QuickTrace for C#

A lightweight, colorful tracing library for .NET with cross-platform safe colors and smart filtering capabilities.

![QuickTrace Demo](../StyleColorful.png)

*Example showing StyleColorful output with performance analysis*

## 📦 Installation

### NuGet Package (khi publish)
```bash
dotnet add package QuickTrace
```

### Local Development
```bash
git clone https://github.com/LeDuyViet/quicktrace
cd quicktrace/csharp
dotnet build
```

## 🚀 Quick Start

```csharp
using QuickTrace;

var tracer = Tracer.NewSimpleTracer("API Call", 
    TracerOptions.WithOutputStyle(OutputStyle.Colorful));

tracer.Span("Database query");
await Task.Delay(50);

tracer.Span("Process data");
await Task.Delay(20);

tracer.Span("Send response");
await Task.Delay(10);

tracer.End(); // Automatically prints colorful output
```

## ⚙️ Configuration Options

```csharp
var tracer = Tracer.NewSimpleTracer("Complex Operation",
    // Only show operations slower than 100ms
    TracerOptions.WithShowSlowOnly(TimeSpan.FromMilliseconds(100)),
    
    // Hide operations faster than 1ms
    TracerOptions.WithHideUltraFast(TimeSpan.FromMilliseconds(1)),
    
    // Group similar duration operations
    TracerOptions.WithGroupSimilar(TimeSpan.FromMilliseconds(10)),
    
    // Custom output style
    TracerOptions.WithOutputStyle(OutputStyle.Detailed),
    
    // Only print if total duration >= 50ms
    TracerOptions.WithMinTotalDuration(TimeSpan.FromMilliseconds(50)),
    
    // Silent mode (collect data but don't print)
    TracerOptions.WithSilent(true),
    
    // Disable tracing completely
    TracerOptions.WithEnabled(false)
);
```

## 🎨 Output Styles

- `OutputStyle.Default` - Simple table format
- `OutputStyle.Colorful` - Modern with Unicode borders  
- `OutputStyle.Minimal` - Compact tree view
- `OutputStyle.Detailed` - Full analysis with statistics
- `OutputStyle.Table` - Clean table format
- `OutputStyle.Json` - Structured JSON output

## 📊 Runtime Control

```csharp
// Enable/disable tracing
tracer.Enabled = false;

// Silent mode (collect data but don't print)
tracer.Silent = true;

// Change style at runtime
tracer.OutputStyle = OutputStyle.Json;

// Custom print condition
tracer.PrintCondition = t => t.GetTotalDuration() > TimeSpan.FromMilliseconds(100);

// Get measurements programmatically
var measurements = tracer.GetMeasurements();
var totalDuration = tracer.GetTotalDuration();
```

## 🔍 Smart Filtering

QuickTrace includes intelligent filtering to reduce noise:

- **Show Slow Only**: `WithShowSlowOnly(threshold)` - Only display operations slower than threshold
- **Hide Ultra Fast**: `WithHideUltraFast(threshold)` - Hide operations faster than threshold  
- **Group Similar**: `WithGroupSimilar(threshold)` - Group operations with similar durations
- **Smart Filter**: `WithSmartFilter(slow, ultraFast, similar)` - Combine all filters

## 🎯 Color Rules

| Duration | Color | Category |
|----------|-------|----------|
| > 3s | Red | Very Slow |
| 1s - 3s | Dark Red | Slow |
| 500ms - 1s | Yellow | Medium-Slow |
| 200ms - 500ms | Blue | Medium |
| 100ms - 200ms | Cyan | Normal |
| 50ms - 100ms | Green | Fast |
| 10ms - 50ms | Dark Green | Very Fast |
| < 10ms | Dark Gray | Ultra Fast |

## 📍 Caller Information

QuickTrace automatically captures file and line information where the tracer was created:

```csharp
var tracer = Tracer.NewSimpleTracer("My Function"); 
// Will show: MyFile.cs:123 in output
```

## 🏃‍♂️ Running Examples

```bash
# Build the solution
dotnet build

# Run specific example
cd Examples
dotnet run basic
dotnet run advanced
dotnet run styles
dotnet run filtering
dotnet run runtime
dotnet run realworld

# Run all examples
dotnet run all
```

## 💻 Cross-Platform Support

- ✅ Windows (Console, Terminal, PowerShell)
- ✅ Linux (Terminal)
- ✅ macOS (Terminal)
- ✅ Docker containers
- ✅ Cloud environments (Azure, AWS, GCP)

## 📝 License

MIT License - see [LICENSE](../LICENSE) file for details.

## 🔗 Related

- [Go version](../go/) - Original Go implementation
- [Swift version](../swift/) - Swift implementation
