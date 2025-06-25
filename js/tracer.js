// ANSI Color Constants - cross-platform safe colors
const Colors = {
    Reset: '\x1b[0m',
    Red: '\x1b[31m',
    Green: '\x1b[32m',
    Yellow: '\x1b[33m',
    Blue: '\x1b[34m',
    Magenta: '\x1b[35m',
    Cyan: '\x1b[36m',
    White: '\x1b[37m',
    BrightBlack: '\x1b[90m',
    Bold: '\x1b[1m'
};

// Output Styles
const OutputStyle = {
    Default: 0,
    Colorful: 1,
    Minimal: 2,
    Detailed: 3,
    Table: 4,
    JSON: 5
};

// Cross-platform safe colors - compatible with both Windows and Linux terminals
const DurationColorRules = [
    { threshold: 5000, color: Colors.Red + Colors.Bold, name: 'Very Slow' },      // > 5s - đỏ đậm
    { threshold: 1000, color: Colors.Red, name: 'Slow' },                         // 1s-5s - đỏ
    { threshold: 500, color: Colors.Magenta, name: 'Medium-Slow' },               // 500ms-1s - tím
    { threshold: 100, color: Colors.Blue, name: 'Medium' },                       // 100ms-500ms - xanh dương
    { threshold: 50, color: Colors.Green, name: 'Fast' },                         // 50ms-100ms - xanh lá
    { threshold: 10, color: Colors.Cyan, name: 'Very Fast' },                     // 10ms-50ms - cyan
    { threshold: 0, color: Colors.White, name: 'Ultra Fast' }                     // < 10ms - trắng
];

class Measurement {
    constructor(statement, duration) {
        this.statement = statement;
        this.duration = duration;
    }
}

class Tracer {
    constructor(name, options = {}) {
        this.name = name;
        this.measurements = [];
        this.lastTime = performance.now();
        this.totalTime = performance.now();
        this.enabled = options.enabled !== undefined ? options.enabled : true;
        this.silent = options.silent !== undefined ? options.silent : false;
        this.outputStyle = options.outputStyle || OutputStyle.Default;
        this.printCondition = options.printCondition || ((tracer) => {
            return tracer.getTotalDuration() >= 100; // Default 100ms minimum
        });
        
        // Caller info
        this.callerInfo = this.getCallerInfo();
        
        // Smart filtering options (tương tự Go version)
        this.showSlowOnly = options.showSlowOnly || false;
        this.slowThreshold = options.slowThreshold || 0;
        this.hideUltraFast = options.hideUltraFast || false;
        this.ultraFastThreshold = options.ultraFastThreshold || 0;
        this.groupSimilar = options.groupSimilar || false;
        this.similarThreshold = options.similarThreshold || 0;
    }
    
    getCallerInfo() {
        try {
            const stack = new Error().stack;
            const lines = stack.split('\n');
            
            // Tìm caller thực sự (bỏ qua tracer internal calls)
            for (let i = 2; i < lines.length; i++) {
                const line = lines[i].trim();
                
                // Bỏ qua internal tracer calls
                if (line.includes('tracer.js') || 
                    line.includes('getCallerInfo') || 
                    line.includes('Tracer.') ||
                    line.includes('createTracer')) {
                    continue;
                }
                
                // Extract thông tin từ stack trace
                // Pattern 1: at function (file:line:column)
                let match = line.match(/at.*\((.*):(\d+):(\d+)\)/);
                if (!match) {
                    // Pattern 2: at file:line:column
                    match = line.match(/at (.*):(\d+):(\d+)/);
                }
                if (!match) {
                    // Pattern 3: at function (file) - no line number
                    match = line.match(/at.*\((.*)\)/);
                    if (match) {
                        match = [match[0], match[1], '?', '?'];
                    }
                }
                if (!match) {
                    // Pattern 4: at file - minimal info
                    match = line.match(/at (.*)/);
                    if (match) {
                        match = [match[0], match[1], '?', '?'];
                    }
                }
                             
                if (match) {
                    const fullPath = match[1] || '';
                    const lineNumber = match[2] || '?';
                    const columnNumber = match[3] || '?';
                    
                    // Lấy tên file từ full path
                    const fileName = fullPath.split('/').pop().split('\\').pop() || 'unknown';
                    
                    // Tạo relative path (2-3 folder cuối)
                    const pathParts = fullPath.split(/[/\\]/);
                    let relativePath = fileName;
                    
                    if (pathParts.length > 1) {
                        // Lấy 2-3 folder cuối để có context đủ
                        const relevantParts = pathParts.slice(-3);
                        if (relevantParts.length > 1) {
                            relativePath = relevantParts.join('/');
                        }
                    }
                    
                    // Format full path với line number
                    const fullPathWithLine = lineNumber !== '?' ? `${fullPath}:${lineNumber}` : fullPath;
                    
                    // Trả về thông tin chi tiết
                    return {
                        shortPath: `${fileName}:${lineNumber}`,
                        fullPath: fullPathWithLine,
                        relativePath: `${relativePath}:${lineNumber}:${columnNumber}`,
                        fileName: fileName,
                        lineNumber: lineNumber,
                        columnNumber: columnNumber
                    };
                }
            }
        } catch (e) {
            // Ignore errors in getting caller info
        }
        
        return {
            shortPath: '',
            fullPath: '',
            relativePath: '',
            fileName: '',
            lineNumber: '',
            columnNumber: ''
        };
    }
    
    span(statement) {
        if (!this.enabled) return;
        
        const now = performance.now();
        const duration = now - this.lastTime;
        this.measurements.push(new Measurement(statement, duration));
        this.lastTime = now;
    }
    
    end() {
        if (!this.enabled) return;
        
        this.span('End');
        
        if (this.silent) return;
        
        if (this.printCondition && !this.printCondition(this)) {
            return;
        }
        
        switch (this.outputStyle) {
            case OutputStyle.Colorful:
                this.printColorful();
                break;
            case OutputStyle.Minimal:
                this.printMinimal();
                break;
            case OutputStyle.Detailed:
                this.printDetailed();
                break;
            case OutputStyle.Table:
                this.printTable();
                break;
            case OutputStyle.JSON:
                this.printJSON();
                break;
            default:
                this.printDetailed();
                break;
        }
    }
    
    // Smart filtering methods
    getFilteredMeasurements() {
        let filtered = this.measurements.slice(0, -1); // Remove 'End' measurement
        
        // Show slow only
        if (this.showSlowOnly && this.slowThreshold > 0) {
            filtered = filtered.filter(m => m.duration >= this.slowThreshold);
        }
        
        // Hide ultra fast
        if (this.hideUltraFast && this.ultraFastThreshold > 0) {
            filtered = filtered.filter(m => m.duration >= this.ultraFastThreshold);
        }
        
        // Group similar (basic implementation)
        if (this.groupSimilar) {
            const grouped = new Map();
            filtered.forEach(m => {
                const key = m.statement;
                if (grouped.has(key)) {
                    const existing = grouped.get(key);
                    existing.count++;
                    existing.totalDuration += m.duration;
                    existing.avgDuration = existing.totalDuration / existing.count;
                    existing.minDuration = Math.min(existing.minDuration, m.duration);
                    existing.maxDuration = Math.max(existing.maxDuration, m.duration);
                } else {
                    grouped.set(key, {
                        statement: m.statement,
                        duration: m.duration,
                        totalDuration: m.duration,
                        avgDuration: m.duration,
                        minDuration: m.duration,
                        maxDuration: m.duration,
                        count: 1
                    });
                }
            });
            
            // Convert back to measurements array
            filtered = Array.from(grouped.values()).map(g => {
                if (g.count > 1) {
                    return new Measurement(
                        `${g.statement} (×${g.count})`,
                        g.avgDuration
                    );
                }
                return new Measurement(g.statement, g.duration);
            });
        }
        
        return filtered;
    }
    
    getTotalDuration() {
        return performance.now() - this.totalTime;
    }
    
    getSpanColor(duration) {
        for (const rule of DurationColorRules) {
            if (duration >= rule.threshold) {
                return rule.color;
            }
        }
        return '';
    }
    
    colorize(text, colorCode) {
        return colorCode + text + Colors.Reset;
    }
    
    colorizeWithStyle(text, colorCode, styleCode) {
        return styleCode + colorCode + text + Colors.Reset;
    }
    
    printColorful() {
        const totalDuration = this.getTotalDuration();
        const nameWidth = 35;
        const durationWidth = 25;
        const totalTableWidth = nameWidth + durationWidth + 4;
        
        const topBorder = '┌' + '─'.repeat(totalTableWidth - 2) + '┐';
        const separator = '├' + '─'.repeat(totalTableWidth - 2) + '┤';
        const bottomBorder = '└' + '─'.repeat(totalTableWidth - 2) + '┘';
        
        console.log(this.colorizeWithStyle(topBorder, Colors.Blue, Colors.Bold));
        
        const titleText = '🚀 ' + this.name;
        const titlePadding = Math.max(1, Math.floor((totalTableWidth - titleText.length - 2) / 2));
        const remainingPadding = Math.max(1, totalTableWidth - titleText.length - titlePadding - 2);
        
        const titleStr = `│${' '.repeat(titlePadding)}${titleText}${' '.repeat(remainingPadding)}│`;
        console.log(this.colorizeWithStyle(titleStr, Colors.Magenta, Colors.Bold));
        
        if (this.callerInfo && this.callerInfo.relativePath) {
            const callerInfo = `📍 File: ${this.callerInfo.relativePath}`;
            const callerPadding = Math.max(1, Math.floor((totalTableWidth - callerInfo.length - 2) / 2));
            const remainingCallerPadding = Math.max(1, totalTableWidth - callerInfo.length - callerPadding - 2);
            
            const callerStr = `│${' '.repeat(callerPadding)}${callerInfo}${' '.repeat(remainingCallerPadding)}│`;
            console.log(this.colorize(callerStr, Colors.BrightBlack));
        }
        
        console.log(this.colorizeWithStyle(separator, Colors.Blue, Colors.Bold));
        
        const totalTimeStr = this.formatDuration(totalDuration);
        const totalLine = `│ ⏱️  Total Time: ${' '.repeat(nameWidth - 16)} │ ${totalTimeStr}`;
        console.log(this.colorizeWithStyle(totalLine, Colors.Green, Colors.Bold));
        
        console.log(this.colorize(separator, Colors.Blue));
        
        const headerLine = `│ ${'📋 Span'.padEnd(nameWidth)} │ ⏰ Duration`;
        console.log(this.colorizeWithStyle(headerLine, Colors.Magenta, Colors.Bold));
        
        console.log(this.colorize(separator, Colors.Blue));
        
        const filteredMeasurements = this.getFilteredMeasurements();
        for (const measurement of filteredMeasurements) {
            const spanColor = this.getSpanColor(measurement.duration);
            const spanName = measurement.statement.length > nameWidth ? 
                           measurement.statement.substring(0, nameWidth - 3) + '...' : 
                           measurement.statement;
            
            console.log(`│ ${this.colorize(spanName.padEnd(nameWidth), spanColor)} │ ${this.colorize(this.formatDuration(measurement.duration), spanColor)}`);
        }
        
        console.log(this.colorizeWithStyle(bottomBorder, Colors.Blue, Colors.Bold));
    }
    
    printMinimal() {
        const totalDuration = this.getTotalDuration();
        const filteredMeasurements = this.getFilteredMeasurements();
        
        console.log(`⚡ ${this.colorizeWithStyle(this.name, Colors.Blue, Colors.Bold)}: ${this.colorizeWithStyle(this.formatDuration(totalDuration), Colors.Green, Colors.Bold)} (${filteredMeasurements.length} spans)`);
        
        if (this.callerInfo && this.callerInfo.shortPath) {
            console.log(`   📍 ${this.colorize(this.callerInfo.shortPath, Colors.BrightBlack)}`);
        }
    }
    
    printTable() {
        // Alias to detailed for now
        this.printDetailed();
    }
    
    printDetailed() {
        const totalDuration = this.getTotalDuration();
        const indexWidth = 3;
        const nameWidth = 30;
        const durationWidth = 15;
        const percentWidth = 8;
        const barWidth = 12;
        const totalWidth = indexWidth + nameWidth + durationWidth + percentWidth + barWidth + 12;
        
        const topBorder = '╔' + '═'.repeat(totalWidth - 2) + '╗';
        const separator = '╠' + '═'.repeat(totalWidth - 2) + '╣';
        const thinSeparator = '╟' + '─'.repeat(totalWidth - 2) + '╢';
        const bottomBorder = '╚' + '═'.repeat(totalWidth - 2) + '╝';
        
        console.log(this.colorizeWithStyle(topBorder, Colors.Blue, Colors.Bold));
        
        const titleText = '🎯 TRACE: ' + this.name;
        const titlePadding = Math.max(1, Math.floor((totalWidth - titleText.length - 2) / 2));
        const remainingPadding = Math.max(1, totalWidth - titleText.length - titlePadding - 2);
        
        const titleStr = `║${' '.repeat(titlePadding)}${titleText}${' '.repeat(remainingPadding)}║`;
        console.log(this.colorizeWithStyle(titleStr, Colors.Magenta, Colors.Bold));
        
        console.log(this.colorizeWithStyle(separator, Colors.Blue, Colors.Bold));
        
        console.log(this.colorizeWithStyle(`║ 📊 SUMMARY${' '.repeat(totalWidth - 13)}║`, Colors.Green, Colors.Bold));
        
        const totalTimeStr = this.formatDuration(totalDuration);
        console.log(`║ • Total Execution Time: ${this.colorizeWithStyle(totalTimeStr, Colors.Green, Colors.Bold)}${' '.repeat(Math.max(0, totalWidth - 27 - totalTimeStr.length))}║`);
        
        const filteredMeasurements = this.getFilteredMeasurements();
        const spanCount = filteredMeasurements.length;
        console.log(`║ • Number of Spans: ${this.colorizeWithStyle(spanCount.toString(), Colors.Blue, Colors.Bold)}${' '.repeat(Math.max(0, totalWidth - 21 - spanCount.toString().length))}║`);
        
        if (this.callerInfo && this.callerInfo.relativePath) {
            const fileInfo = this.callerInfo.relativePath;
            console.log(`║ • File: ${this.colorizeWithStyle(fileInfo, Colors.BrightBlack, Colors.Bold)}${' '.repeat(Math.max(0, totalWidth - 10 - fileInfo.length))}║`);
            
            // Luôn hiển thị full path nếu có
            if (this.callerInfo.fullPath && this.callerInfo.fullPath.trim() !== '') {
                const basePath = this.callerInfo.fullPath.split(':')[0]; // Lấy phần path không có line number
                const relativeBasePath = this.callerInfo.relativePath.split(':')[0]; // Lấy phần path của relative
                
                // Hiển thị full path nếu khác với relative path base
                if (basePath !== relativeBasePath) {
                    const fullPathInfo = `• Full Path: ${this.callerInfo.fullPath}`;
                    console.log(`║ ${this.colorize(fullPathInfo, Colors.BrightBlack)}${' '.repeat(Math.max(0, totalWidth - fullPathInfo.length - 3))}║`);
                }
            }
        }
        
        console.log(this.colorizeWithStyle(separator, Colors.Blue, Colors.Bold));
        
        console.log(this.colorizeWithStyle(`║ 🔍 DETAILED BREAKDOWN${' '.repeat(totalWidth - 23)}║`, Colors.Magenta, Colors.Bold));
        console.log(this.colorizeWithStyle(thinSeparator, Colors.Blue, Colors.Bold));
        
        console.log(`║${this.colorizeWithStyle(' #'.padStart(indexWidth), Colors.Magenta, Colors.Bold)} │${this.colorizeWithStyle(' Operation'.padEnd(nameWidth), Colors.Magenta, Colors.Bold)} │${this.colorizeWithStyle(' Duration'.padStart(durationWidth), Colors.Magenta, Colors.Bold)} │${this.colorizeWithStyle(' Percent'.padStart(percentWidth), Colors.Magenta, Colors.Bold)} │${this.colorizeWithStyle(' Progress'.padEnd(barWidth), Colors.Magenta, Colors.Bold)} ║`);
        
        console.log(this.colorize(thinSeparator, Colors.Blue));
        
        for (let i = 0; i < filteredMeasurements.length; i++) {
            const m = filteredMeasurements[i];
            const percentage = totalDuration > 0 ? (m.duration / totalDuration) * 100 : 0;
            
            const barLength = Math.min(Math.max(0, Math.floor(percentage / 8)), barWidth - 1);
            const progressBar = ('█'.repeat(barLength) + '░'.repeat(Math.max(0, barWidth - 1 - barLength))).substring(0, barWidth - 1);
            
            const operationName = m.statement.length > nameWidth - 1 ? 
                                 m.statement.substring(0, nameWidth - 4) + '...' : 
                                 m.statement;
            
            const percentStr = percentage.toFixed(1) + '%';
            const spanColor = this.getSpanColor(m.duration);
            const progressColor = Colors.Blue + Colors.Bold;
            
            console.log(`║ ${(i + 1).toString().padStart(indexWidth - 1)} │ ${this.colorize(operationName.padEnd(nameWidth - 1), spanColor)} │ ${this.colorize(this.formatDuration(m.duration).padStart(durationWidth - 2), spanColor)} │ ${this.colorize(percentStr.padStart(percentWidth - 2), spanColor)} │ ${this.colorize(progressBar.padEnd(barWidth - 1), progressColor)} ║`);
        }
        
        console.log(this.colorizeWithStyle(bottomBorder, Colors.Blue, Colors.Bold));
    }
    
    printJSON() {
        const totalDuration = this.getTotalDuration();
        
        console.log(this.colorizeWithStyle('📄 JSON Output:', Colors.Magenta, Colors.Bold));
        
        const data = {
            tracer_name: this.name,
            total_duration: this.formatDuration(totalDuration),
            total_ms: totalDuration,
            caller_info: this.callerInfo && this.callerInfo.relativePath ? {
                short_path: this.callerInfo.shortPath,
                relative_path: this.callerInfo.relativePath,
                full_path: this.callerInfo.fullPath,
                file_name: this.callerInfo.fileName,
                line: this.callerInfo.lineNumber,
                column: this.callerInfo.columnNumber
            } : null,
            spans: this.getFilteredMeasurements().map(m => {
                let colorClass = 'ultra_fast';
                if (m.duration >= 5000) colorClass = 'very_slow';
                else if (m.duration >= 1000) colorClass = 'slow';
                else if (m.duration >= 500) colorClass = 'medium_slow';
                else if (m.duration >= 100) colorClass = 'medium';
                else if (m.duration >= 50) colorClass = 'fast';
                else if (m.duration >= 10) colorClass = 'very_fast';
                
                return {
                    name: m.statement,
                    duration: this.formatDuration(m.duration),
                    ms: m.duration,
                    percent: totalDuration > 0 ? ((m.duration / totalDuration) * 100).toFixed(2) : '0.00',
                    color_class: colorClass
                };
            })
        };
        
        console.log(JSON.stringify(data, null, 2));
    }
    
    formatDuration(ms) {
        if (ms >= 1000) {
            return (ms / 1000).toFixed(2) + 's';
        } else if (ms >= 1) {
            return ms.toFixed(2) + 'ms';
        } else {
            return (ms * 1000).toFixed(2) + 'μs';
        }
    }
}

// Utility functions for options (tương tự Go version)
const TracerOptions = {
    // Basic options
    withEnabled: (enabled) => ({ enabled }),
    withSilent: (silent) => ({ silent }),
    withOutputStyle: (style) => ({ outputStyle: style }),
    
    // Threshold options
    withMinTotalDuration: (minDuration) => ({
        printCondition: (tracer) => tracer.getTotalDuration() >= minDuration
    }),
    withCustomCondition: (conditionFunc) => ({
        printCondition: conditionFunc
    }),
    
    // Filtering options
    withShowSlowOnly: (threshold) => ({
        showSlowOnly: true,
        slowThreshold: threshold
    }),
    withHideUltraFast: (threshold) => ({
        hideUltraFast: true,
        ultraFastThreshold: threshold
    }),
    withGroupSimilar: (enabled = true) => ({
        groupSimilar: enabled
    }),
    
    // Combined presets
    withPerformanceMode: () => ({
        showSlowOnly: true,
        slowThreshold: 100,
        hideUltraFast: true,
        ultraFastThreshold: 1,
        outputStyle: OutputStyle.Detailed
    }),
    withDebugMode: () => ({
        enabled: true,
        silent: false,
        outputStyle: OutputStyle.Detailed,
        printCondition: () => true // Always print
    }),
    withProductionMode: () => ({
        enabled: true,
        silent: false,
        showSlowOnly: true,
        slowThreshold: 500,
        outputStyle: OutputStyle.Minimal,
        printCondition: (tracer) => tracer.getTotalDuration() >= 1000
    }),
    withDevelopmentMode: () => ({
        enabled: true,
        silent: false,
        outputStyle: OutputStyle.Colorful,
        printCondition: (tracer) => tracer.getTotalDuration() >= 50
    })
};

function createTracer(name, ...optionFunctions) {
    const options = Object.assign({}, ...optionFunctions);
    return new Tracer(name, options);
}

// Export for different environments
if (typeof module !== 'undefined' && module.exports) {
    module.exports = { Tracer, TracerOptions, OutputStyle, Colors, DurationColorRules, createTracer };
} else if (typeof window !== 'undefined') {
    window.TracingLibrary = { Tracer, TracerOptions, OutputStyle, Colors, DurationColorRules, createTracer };
} 