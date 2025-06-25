# 🚀 QuickTrace for JavaScript

A lightweight, colorful tracing library for JavaScript with cross-platform safe colors and smart filtering capabilities.

![QuickTrace Demo](../StyleColorful.png)

*Example showing StyleColorful output with performance analysis*

## 📦 Installation

```bash
npm install quicktrace-js
```

## 🚀 Quick Start

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

## ⚙️ Configuration Options

```javascript
const tracer = new Tracer('Complex Operation', {
    style: 'detailed',              // Output style
    showSlowOnly: 100,             // Only show operations >= 100ms
    hideUltraFast: 1,              // Hide operations < 1ms  
    groupSimilar: 10,              // Group similar operations ±10ms
    minTotalDuration: 50,          // Only print if total >= 50ms
    silent: false,                 // Silent mode (collect data only)
    enabled: true                  // Enable/disable tracing
});
```

## 🎨 Output Styles

- `'default'` - Simple table format
- `'colorful'` - Modern with Unicode borders  
- `'minimal'` - Compact tree view
- `'detailed'` - Full analysis with statistics
- `'table' - Clean table format
- `'json'` - Structured JSON output

## 📊 Runtime Control

```javascript
// Enable/disable tracing
tracer.setEnabled(false);

// Silent mode (collect data but don't print)
tracer.setSilent(true);

// Change style at runtime  
tracer.setOutputStyle('json');

// Get data programmatically
const measurements = tracer.getMeasurements();
const totalDuration = tracer.getTotalDuration();
```

## 📁 Examples

Check out the examples in the `examples/` directory:
- `basic.js` - Simple usage example
- `advanced.js` - Advanced filtering options
- `styles.js` - All output styles demonstration
- `filtering.js` - Smart filtering capabilities
- `runtime_control.js` - Runtime configuration
- `real_world.js` - Express.js-style API server example

## 📖 Full Documentation

For complete documentation with more examples and advanced usage, see the main [README](../README.md).

## 📝 License

MIT License - see [LICENSE](../LICENSE) file for details. 