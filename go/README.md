# 🚀 QuickTrace for Go

A lightweight, colorful tracing library for Go with cross-platform safe colors and smart filtering capabilities.

![QuickTrace Demo](../StyleColorful.png)

*Example showing StyleColorful output with performance analysis*

## 📦 Installation

```bash
go get github.com/LeDuyViet/quicktrace/go
```

## 🚀 Quick Start

```go
//go:build ignore
// +build ignore

package main

import (
    "time"
    "github.com/LeDuyViet/quicktrace/go"
)

func main() {
    tracer := tracing.NewSimpleTracer("API Call", 
        tracing.WithOutputStyle(tracing.StyleColorful))
    
    tracer.Span("Database query")
    time.Sleep(50 * time.Millisecond)
    
    tracer.Span("Process data")
    time.Sleep(20 * time.Millisecond)
    
    tracer.Span("Send response")
    time.Sleep(10 * time.Millisecond)
    
    tracer.End() // Automatically prints colorful output
}
```

## ⚙️ Configuration Options

```go
tracer := tracing.NewSimpleTracer("Complex Operation",
    // Only show operations slower than 100ms
    tracing.WithShowSlowOnly(100 * time.Millisecond),
    
    // Hide operations faster than 1ms
    tracing.WithHideUltraFast(1 * time.Millisecond),
    
    // Group similar duration operations
    tracing.WithGroupSimilar(10 * time.Millisecond),
    
    // Custom output style
    tracing.WithOutputStyle(tracing.StyleDetailed),
    
    // Only print if total duration >= 50ms
    tracing.WithMinTotalDuration(50 * time.Millisecond),
    
    // Silent mode (collect data but don't print)
    tracing.WithSilent(true),
    
    // Disable tracing completely
    tracing.WithEnabled(false),
)
```

## 🎨 Output Styles

- `StyleDefault` - Simple table format
- `StyleColorful` - Modern with Unicode borders  
- `StyleMinimal` - Compact tree view
- `StyleDetailed` - Full analysis with statistics
- `StyleTable` - Clean table format
- `StyleJSON` - Structured JSON output

## 📊 Runtime Control

```go
// Enable/disable tracing
tracer.SetEnabled(false)

// Silent mode (collect data but don't print)
tracer.SetSilent(true)

// Change style at runtime
tracer.SetOutputStyle(tracing.StyleJSON)

// Custom print condition
tracer.SetPrintCondition(func(t *tracing.Tracer) bool {
    return t.GetTotalDuration() > 100*time.Millisecond
})

// Get measurements programmatically
measurements := tracer.GetMeasurements()
totalDuration := tracer.GetTotalDuration()
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
| > 3s | Red Bold | Very Slow |
| 1s - 3s | Red | Slow |
| 500ms - 1s | Yellow | Medium-Slow |
| 200ms - 500ms | Bright Blue | Medium |
| 100ms - 200ms | Cyan | Normal |
| 50ms - 100ms | Green | Fast |
| 10ms - 50ms | Bright Green | Very Fast |
| < 10ms | Bright Black | Ultra Fast |

## 📍 Caller Information

QuickTrace automatically captures file and line information where the tracer was created:

```go
tracer := tracing.NewSimpleTracer("My Function") 
// Will show: my_file.go:123 in output
```

## 📝 License

MIT License - see [LICENSE](../LICENSE) file for details. 