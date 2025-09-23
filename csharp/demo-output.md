# 🚀 QuickTrace C# - Demo Output

## Basic Example
```
╔══════════════════════════════════════════════════════════════════════════════╗
║                          🎯 TRACE: Basic Example                             ║
║                        📍 File: BasicExample.cs:15                           ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ 📊 SUMMARY                                                                   ║
║ • Total Execution Time: 110.234ms                                           ║
║ • Number of Spans: 4                                                        ║
║ • Slowest Operation: Load user data                                         ║
║ • Slowest Duration: 50.123ms                                                ║
║ • File: BasicExample.cs:15                                                  ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ 🔍 DETAILED BREAKDOWN                                                        ║
╟──────────────────────────────────────────────────────────────────────────────╢
║   # │ Operation                     │       Duration │ Percent │ Progress     ║
╟──────────────────────────────────────────────────────────────────────────────╢
║   1 │ Initialize database           │       30.045ms │  27.3% │ ███░░░░░░░░  ║
║   2 │ Load user data                │       50.123ms │  45.5% │ █████░░░░░░  ║
║   3 │ Process data                  │       20.034ms │  18.2% │ ██░░░░░░░░░  ║
║   4 │ Generate response             │       10.032ms │   9.1% │ █░░░░░░░░░░  ║
╚══════════════════════════════════════════════════════════════════════════════╝
```

## Colorful Style Example
```
┌─────────────────────────────────────────────────────────────┐
│               🚀 API Processing - Colorful Style            │
│               📍 File: StylesExample.cs:25                  │
├─────────────────────────────────────────────────────────────┤
│ ⏱️  Total Time:                       │ 288.567ms          │
├─────────────────────────────────────────────────────────────┤
│ 📋 Span                               │ ⏰ Duration         │
├─────────────────────────────────────────────────────────────┤
│ Load configuration                    │ 25.123ms           │
│ Connect to database                   │ 75.456ms           │
│ Execute complex query                 │ 120.789ms          │
│ Process results                       │ 45.234ms           │
│ Cache data                            │ 15.123ms           │
│ Generate response                     │ 6.842ms            │
└─────────────────────────────────────────────────────────────┘
```

## Minimal Style Example
```
┌─────────────────────────────────────────────────────────────┐
│ ⚡ API Processing - Minimal Style      │ 288.567ms          │
│ 📍 File: StylesExample.cs:86          │                    │
├─────────────────────────────────────────────────────────────┤
│   └─ Load configuration               │ 25.123ms           │
│   └─ Connect to database              │ 75.456ms           │
│   └─ Execute complex query            │ 120.789ms          │
│   └─ Process results                  │ 45.234ms           │
│   └─ Cache data                       │ 15.123ms           │
│   └─ Generate response                │ 6.842ms            │
└─────────────────────────────────────────────────────────────┘
```

## JSON Output Example
```json
📄 JSON Output:
{
  "tracer_name": "API Processing - JSON Style",
  "total_duration": "288.567ms",
  "total_ms": 288.567,
  "total_ns": 288567000,
  "caller_info": {
    "file": "StylesExample.cs:96",
    "full_path": "C:\\path\\to\\StylesExample.cs",
    "line": 96
  },
  "spans": [
    {
      "name": "Load configuration",
      "duration": "25.123ms", 
      "ms": 25.123,
      "ns": 25123000,
      "percent": 8.7,
      "color_class": "fast"
    },
    {
      "name": "Connect to database",
      "duration": "75.456ms",
      "ms": 75.456, 
      "ns": 75456000,
      "percent": 26.2,
      "color_class": "medium"
    },
    {
      "name": "Execute complex query",
      "duration": "120.789ms",
      "ms": 120.789,
      "ns": 120789000,
      "percent": 41.9,
      "color_class": "medium"
    }
  ]
}
```

## Smart Filtering Example
```
╔══════════════════════════════════════════════════════════════════════════════╗
║                       🎯 TRACE: Smart Filtered                              ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ 📊 SUMMARY                                                                   ║
║ • Total Execution Time: 1.425s                                              ║
║ • Number of Spans: 3                                                        ║
║ • Slowest Operation: Very slow external API call                           ║
║ • Slowest Duration: 800.123ms                                               ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ 🔍 DETAILED BREAKDOWN                                                        ║
╟──────────────────────────────────────────────────────────────────────────────╢
║   # │ Operation                     │       Duration │ Percent │ Progress     ║
╟──────────────────────────────────────────────────────────────────────────────╢
║   1 │ 📦 Medium processing + 2 others │       46.5ms │   3.3% │ ░░░░░░░░░░░  ║
║   2 │ Slow database query           │      150.234ms │  10.5% │ █░░░░░░░░░░  ║
║   3 │ Complex computation           │      200.456ms │  14.1% │ █░░░░░░░░░░  ║
║   4 │ Very slow external API call   │      800.123ms │  56.1% │ ██████░░░░░  ║
╟──────────────────────────────────────────────────────────────────────────────╢
║ 🔍 Filtered: 4/10 spans | Active: slow>50ms, hide<2ms, group±15ms          ║
╚══════════════════════════════════════════════════════════════════════════════╝
```

## Color Classes Reference

| Duration    | Color        | Class      | Description  |
|-------------|------------- |------------|--------------|
| > 3s        | Red          | Very Slow  | Critical     |
| 1s - 3s     | Dark Red     | Slow       | Needs optimization |
| 500ms - 1s  | Yellow       | Medium-Slow| Monitor      |
| 200ms - 500ms| Blue        | Medium     | Acceptable   |
| 100ms - 200ms| Cyan        | Normal     | Good         |
| 50ms - 100ms| Green        | Fast       | Excellent    |
| 10ms - 50ms | Dark Green   | Very Fast  | Optimal      |
| < 10ms      | Dark Gray    | Ultra Fast | Perfect      |

## Features Demonstrated

✅ **Multiple Output Styles** - Colorful, Minimal, Detailed, Table, JSON  
✅ **Smart Filtering** - Show slow only, hide ultra fast, group similar  
✅ **Runtime Control** - Enable/disable, silent mode, custom conditions  
✅ **Cross-Platform Colors** - Safe colors for Windows/Linux/macOS  
✅ **Caller Information** - Automatic file and line capture  
✅ **Performance Analysis** - Duration classification and progress bars  
✅ **Realistic Timing** - Actual async Task.Delay() calls  
✅ **Extensible Design** - Easy to integrate with existing applications  
