# 🚀 QuickTrace

[![Go Version](https://img.shields.io/badge/go-%3E%3D1.19-blue.svg)](https://golang.org/)
[![Node Version](https://img.shields.io/badge/node-%3E%3D12.0.0-green.svg)](https://nodejs.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A lightweight, colorful tracing library for **Go** and **JavaScript** with cross-platform safe colors and smart filtering capabilities.

**QuickTrace** giúp bạn debug và monitor performance một cách dễ dàng với output đẹp mắt và nhiều style khác nhau.

![QuickTrace Demo](StyleColorful.png)

*Example of StyleColorful output showing performance tracing with color-coded timing*

## ✨ Features

- 🎨 **Cross-platform safe colors** - hoạt động tốt trên Windows, Linux, macOS
- 📊 **Multiple output styles** - Default, Colorful, Minimal, Detailed, Table, JSON
- 🔍 **Smart filtering** - Hide ultra-fast operations, show slow-only, group similar
- 📍 **Caller info** - Automatically capture file and line information  
- ⚡ **Zero-config** - Works out of the box with sensible defaults
- 🌍 **Multi-language** - Go và JavaScript implementations

## 📦 Installation

### Go
```bash
go get github.com/LeDuyViet/quicktrace/go
```

### JavaScript
```bash
npm install quicktrace-js
```

## 🚀 Quick Start

### Go Example
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

### JavaScript Example
```javascript
const { Tracer } = require('quicktrace-js');

const tracer = new Tracer('API Call', { style: 'colorful' });

tracer.span('Database query');
await new Promise(resolve => setTimeout(resolve, 50));

tracer.span('Process data');  
await new Promise(resolve => setTimeout(resolve, 20));

tracer.span('Send response');
await new Promise(resolve => setTimeout(resolve, 10));

tracer.end(); // Automatically prints colorful output
```

## 🎨 Output Styles

QuickTrace hỗ trợ 6 styles khác nhau:

| Style | Description | Use Case | Preview |
|-------|-------------|----------|---------|
| `StyleDefault` | Simple table format | General purpose | - |
| `StyleColorful` | Modern with Unicode borders | Development/Debug | ![Colorful Style](StyleColorful.png) |
| `StyleMinimal` | Compact tree view | CI/CD logs | ![Minimal Style](StyleMinimal.png) |
| `StyleDetailed` | Full analysis with stats | Performance analysis | ![Detailed Style](StyleDetailed.png) |
| `StyleTable` | Clean table format | Reports | ![Table Style](StyleTable.png) |
| `StyleJSON` | Structured JSON output | Integration/Parsing | ![JSON Style](StyleJSON.png) |

## ⚙️ Advanced Configuration

### Go
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
)
```

### JavaScript
```javascript
const tracer = new Tracer('Complex Operation', {
    style: 'detailed',
    showSlowOnly: 100,        // ms
    hideUltraFast: 1,         // ms  
    groupSimilar: 10,         // ms
    minTotalDuration: 50      // ms
});
```

## 🔍 Smart Filtering

QuickTrace có các tính năng filtering thông minh:

- **Show Slow Only**: Chỉ hiển thị operations chậm hơn threshold
- **Hide Ultra Fast**: Ẩn operations quá nhanh (< 1ms)
- **Group Similar**: Nhóm operations có duration tương tự
- **Min Duration**: Chỉ print khi tổng thời gian >= threshold

## 🎯 Color Rules

QuickTrace sử dụng color rules thông minh:

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

## 📊 Runtime Control

### Go
```go
// Enable/disable tracing
tracer.SetEnabled(false)

// Silent mode (collect data but don't print)
tracer.SetSilent(true)

// Change style at runtime
tracer.SetOutputStyle(tracing.StyleJSON)

// Get measurements programmatically
measurements := tracer.GetMeasurements()
totalDuration := tracer.GetTotalDuration()
```

### JavaScript
```javascript
// Enable/disable tracing
tracer.setEnabled(false);

// Silent mode
tracer.setSilent(true);

// Change style at runtime  
tracer.setOutputStyle('json');

// Get data programmatically
const measurements = tracer.getMeasurements();
const totalDuration = tracer.getTotalDuration();
```

## 🌍 Language Support

| Feature | Go | JavaScript |
|---------|----|-----------| 
| Basic Tracing | ✅ | ✅ |
| Color Output | ✅ | ✅ |
| Multiple Styles | ✅ | ✅ |
| Smart Filtering | ✅ | ✅ |
| Caller Info | ✅ | ✅ |
| Runtime Control | ✅ | ✅ |
| JSON Export | ✅ | ✅ |

## 📁 Examples

Xem thêm examples trong thư mục:
- `go/examples/` - Go examples
- `js/examples/` - JavaScript examples

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -am 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Inspired by modern development tools
- Built with cross-platform compatibility in mind
- Community feedback and contributions

---

**Made with ❤️ for developers who love beautiful, functional tracing tools.** 