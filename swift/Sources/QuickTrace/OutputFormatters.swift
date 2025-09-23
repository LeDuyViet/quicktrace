import Foundation

// MARK: - Output Formatters Extension

extension QuickTrace {
    
    // MARK: - Default Style
    
    internal func generateDefaultOutput() -> String {
        let totalDuration = getTotalDuration()
        let displayMeasurements = getMeasurements()
        
        var output = ""
        
        let separator = String(repeating: "=", count: 70)
        output += separator.colored(with: .cyan, style: .bold) + "\n"
        output += String(format: "| %-66s |\n", name).colored(with: .yellow, style: .bold)
        output += separator.colored(with: .cyan, style: .bold) + "\n"
        output += String(format: "| %-20s | %-45s |\n", "Total time", String(format: "%.3fs", totalDuration)).colored(with: .green, style: .bold)
        output += String(repeating: "-", count: 70).colored(with: .cyan) + "\n"
        output += String(format: "| %-45s | %-20s |\n", "Span", "Execution time").colored(with: .magenta, style: .bold)
        output += String(repeating: "-", count: 70).colored(with: .cyan) + "\n"
        
        for measurement in displayMeasurements {
            let color = ColorRules.colorForDuration(measurement.duration)
            let spanText = String(format: "%-45s", measurement.statement).colored(with: color)
            let durationText = String(format: "%-20s", String(format: "%.3fs", measurement.duration)).colored(with: color)
            output += "| \(spanText) | \(durationText) |\n"
        }
        
        output += separator.colored(with: .cyan, style: .bold) + "\n"
        
        return output
    }
    
    // MARK: - Colorful Style
    
    internal func generateColorfulOutput() -> String {
        let totalDuration = getTotalDuration()
        let displayMeasurements = getMeasurements()
        
        let nameWidth = 35
        let durationWidth = 25
        let totalTableWidth = nameWidth + durationWidth + 4
        
        var output = ""
        
        // Modern Unicode borders
        let topBorder = "┌" + String(repeating: "─", count: totalTableWidth - 2) + "┐"
        let separator = "├" + String(repeating: "─", count: totalTableWidth - 2) + "┤"
        let bottomBorder = "└" + String(repeating: "─", count: totalTableWidth - 2) + "┘"
        
        // Header
        output += topBorder.colored(with: .cyan, style: .bold) + "\n"
        
        // Title row
        let titleText = "🚀 " + name
        let titlePadding = max(1, (totalTableWidth - titleText.count - 2) / 2)
        let remainingPadding = max(1, totalTableWidth - titleText.count - titlePadding - 2)
        
        let titleStr = String(format: "│%@%@%@│",
                             String(repeating: " ", count: titlePadding),
                             titleText,
                             String(repeating: " ", count: remainingPadding))
        output += titleStr.colored(with: .yellow, style: .bold) + "\n"
        
        // Caller info if available
        if let caller = callerInfo {
            let callerText = "📍 File: \(caller.shortDescription)"
            let callerPadding = max(1, (totalTableWidth - callerText.count - 2) / 2)
            let remainingCallerPadding = max(1, totalTableWidth - callerText.count - callerPadding - 2)
            
            let callerStr = String(format: "│%@%@%@│",
                                  String(repeating: " ", count: callerPadding),
                                  callerText,
                                  String(repeating: " ", count: remainingCallerPadding))
            output += callerStr.colored(with: .brightBlack) + "\n"
        }
        
        output += separator.colored(with: .cyan, style: .bold) + "\n"
        
        // Total time row
        let totalLine = String(format: "│ ⏱️  Total Time: %@│ %@",
                              String(repeating: " ", count: nameWidth - 16),
                              String(format: "%.3fs", totalDuration))
        output += totalLine.colored(with: .green, style: .bold) + "\n"
        
        output += separator.colored(with: .cyan) + "\n"
        
        // Column headers
        let headerLine = String(format: "│ %-*s │ %s",
                               nameWidth, "📋 Span",
                               "⏰ Duration")
        output += headerLine.colored(with: .magenta, style: .bold) + "\n"
        
        output += separator.colored(with: .cyan) + "\n"
        
        // Spans
        for measurement in displayMeasurements {
            let color = ColorRules.colorForDuration(measurement.duration)
            
            var spanName = measurement.statement
            if spanName.count > nameWidth {
                spanName = String(spanName.prefix(nameWidth - 3)) + "..."
            }
            
            output += String(format: "│ %-*s │ %s\n",
                           nameWidth, spanName.colored(with: color),
                           String(format: "%.3fs", measurement.duration).colored(with: color))
        }
        
        output += bottomBorder.colored(with: .cyan, style: .bold) + "\n"
        
        return output
    }
    
    // MARK: - Minimal Style
    
    internal func generateMinimalOutput() -> String {
        let totalDuration = getTotalDuration()
        let displayMeasurements = getMeasurements()
        
        let nameWidth = 35
        let durationWidth = 25
        let totalWidth = nameWidth + durationWidth + 4
        
        var output = ""
        
        let topBorder = "┌" + String(repeating: "─", count: totalWidth - 2) + "┐"
        let separator = "├" + String(repeating: "─", count: totalWidth - 2) + "┤"
        let bottomBorder = "└" + String(repeating: "─", count: totalWidth - 2) + "┘"
        
        output += topBorder.colored(with: .cyan, style: .bold) + "\n"
        
        // Title and total time
        var titleText = "⚡ " + name
        if titleText.count > nameWidth {
            titleText = String(titleText.prefix(nameWidth - 3)) + "..."
        }
        
        let totalTimeStr = String(format: "%.3fs", totalDuration)
        let titleLine = String(format: "│ %-*s │ %s",
                              nameWidth, titleText, totalTimeStr)
        output += titleLine.colored(with: .cyan, style: .bold) + "\n"
        
        // Caller info if available
        if let caller = callerInfo {
            let callerText = "📍 File: \(caller.shortDescription)"
            var callerInfo = callerText
            if callerInfo.count > nameWidth {
                callerInfo = String(callerInfo.prefix(nameWidth - 3)) + "..."
            }
            
            let callerLine = String(format: "│ %-*s │ %s",
                                   nameWidth, callerInfo, "")
            output += callerLine.colored(with: .brightBlack) + "\n"
        }
        
        output += separator.colored(with: .cyan) + "\n"
        
        // Minimal span listing
        for measurement in displayMeasurements {
            let color = ColorRules.colorForDuration(measurement.duration)
            
            var spanName = "  └─ " + measurement.statement
            if spanName.count > nameWidth {
                spanName = String(spanName.prefix(nameWidth - 3)) + "..."
            }
            
            output += String(format: "│ %-*s │ %s\n",
                           nameWidth, spanName.colored(with: color),
                           String(format: "%.3fs", measurement.duration).colored(with: color))
        }
        
        output += bottomBorder.colored(with: .cyan, style: .bold) + "\n"
        
        return output
    }
    
    // MARK: - Detailed Style
    
    internal func generateDetailedOutput() -> String {
        let totalDuration = getTotalDuration()
        let originalMeasurements = getMeasurements()
        
        // Apply smart filtering
        let filteredData = applySmartFiltering(to: originalMeasurements)
        
        let indexWidth = 3
        let nameWidth = 30
        let durationWidth = 15
        let percentWidth = 8
        let barWidth = 12
        
        let totalWidth = indexWidth + nameWidth + durationWidth + percentWidth + barWidth + 12
        
        var output = ""
        
        // Modern Unicode borders
        let topBorder = "╔" + String(repeating: "═", count: totalWidth - 2) + "╗"
        let separator = "╠" + String(repeating: "═", count: totalWidth - 2) + "╣"
        let thinSeparator = "╟" + String(repeating: "─", count: totalWidth - 2) + "╢"
        let bottomBorder = "╚" + String(repeating: "═", count: totalWidth - 2) + "╝"
        
        // Header
        output += topBorder.colored(with: .blue, style: .bold) + "\n"
        
        // Title row
        let titleText = "🎯 TRACE: " + name
        let titlePadding = max(1, (totalWidth - titleText.count - 2) / 2)
        let remainingPadding = max(1, totalWidth - titleText.count - titlePadding - 2)
        
        let titleStr = String(format: "║%@%@%@║",
                             String(repeating: " ", count: titlePadding),
                             titleText,
                             String(repeating: " ", count: remainingPadding))
        output += titleStr.colored(with: .magenta, style: .bold) + "\n"
        
        output += separator.colored(with: .blue, style: .bold) + "\n"
        
        // Summary section
        output += String(format: "║ 📊 SUMMARY%@║\n", String(repeating: " ", count: totalWidth - 13)).colored(with: .green, style: .bold)
        
        // Total execution time
        let totalTimeStr = String(format: "%.3fs", totalDuration)
        let prefix1 = "║ • Total Execution Time: "
        let paddingRight1 = max(0, totalWidth - prefix1.count - totalTimeStr.count - 1)
        output += prefix1 + totalTimeStr.colored(with: .green, style: .bold) + String(repeating: " ", count: paddingRight1) + "║\n"
        
        // Number of spans
        let spanCount = originalMeasurements.count
        let spanCountStr = "\(spanCount)"
        let prefix2 = "║ • Number of Spans: "
        let paddingRight2 = max(0, totalWidth - prefix2.count - spanCountStr.count - 1)
        output += prefix2 + spanCountStr.colored(with: .blue, style: .bold) + String(repeating: " ", count: paddingRight2) + "║\n"
        
        // Find slowest operation
        if let slowest = originalMeasurements.max(by: { $0.duration < $1.duration }) {
            var slowestName = slowest.statement
            if slowestName.count > 25 {
                slowestName = String(slowestName.prefix(22)) + "..."
            }
            
            let prefix3 = "║ • Slowest Operation: "
            let paddingRight3 = max(0, totalWidth - prefix3.count - slowestName.count - 1)
            output += prefix3 + slowestName.colored(with: .red, style: .bold) + String(repeating: " ", count: paddingRight3) + "║\n"
            
            let slowestDurStr = String(format: "%.3fs", slowest.duration)
            let prefix4 = "║ • Slowest Duration: "
            let paddingRight4 = max(0, totalWidth - prefix4.count - slowestDurStr.count - 1)
            output += prefix4 + slowestDurStr.colored(with: .red, style: .bold) + String(repeating: " ", count: paddingRight4) + "║\n"
        }
        
        // Caller info if available
        if let caller = callerInfo {
            let callerInfoStr = caller.shortDescription
            let prefix5 = "║ • File: "
            output += prefix5 + callerInfoStr.colored(with: .brightBlack, style: .bold) + "\n"
        }
        
        output += separator.colored(with: .blue, style: .bold) + "\n"
        
        // Detailed breakdown header
        output += String(format: "║ 🔍 DETAILED BREAKDOWN%@║\n", String(repeating: " ", count: totalWidth - 23)).colored(with: .magenta, style: .bold)
        output += thinSeparator.colored(with: .blue, style: .bold) + "\n"
        
        // Column headers
        output += String(format: "║ %*s │ %-*s │ %*s │ %*s │ %-*s ║\n",
                        indexWidth, "#".colored(with: .magenta, style: .bold),
                        nameWidth - 1, "Operation".colored(with: .magenta, style: .bold),
                        durationWidth - 1, "Duration".colored(with: .magenta, style: .bold),
                        percentWidth - 1, "Percent".colored(with: .magenta, style: .bold),
                        barWidth - 1, "Progress".colored(with: .magenta, style: .bold))
        
        output += thinSeparator.colored(with: .cyan) + "\n"
        
        // Data rows
        for (i, item) in filteredData.enumerated() {
            let operationName: String
            let duration: TimeInterval
            let isGrouped: Bool
            
            if let measurement = item as? Measurement {
                operationName = measurement.statement
                duration = measurement.duration
                isGrouped = false
            } else if let grouped = item as? GroupedMeasurement {
                operationName = grouped.name
                duration = grouped.avgTime
                isGrouped = true
            } else {
                continue
            }
            
            let percentage = (duration / totalDuration) * 100
            
            // Progress bar
            let barLength = min(barWidth - 1, max(0, Int(percentage / 8)))
            let progressBar = String(repeating: "█", count: barLength) + 
                             String(repeating: "░", count: (barWidth - 1) - barLength)
            
            // Truncate operation name if too long
            var displayName = operationName
            if displayName.count > nameWidth - 1 {
                displayName = String(displayName.prefix(nameWidth - 4)) + "..."
            }
            
            // Add icon for grouped items
            if isGrouped {
                displayName = "📦 " + displayName
            }
            
            let percentStr = String(format: "%.1f%%", percentage)
            let color = ColorRules.colorForDuration(duration)
            let progressColor = ANSIColor.blue
            
            output += String(format: "║ %*d │ %-*s │ %*s │ %*s │ %-*s ║\n",
                           indexWidth, i + 1,
                           nameWidth - 1, displayName.colored(with: color),
                           durationWidth - 2, String(format: "%.3fs", duration).colored(with: color),
                           percentWidth - 2, percentStr.colored(with: color),
                           barWidth - 1, progressBar.colored(with: progressColor))
        }
        
        // Show filtering summary if any filters are applied
        if hasActiveFilters() {
            output += thinSeparator.colored(with: .cyan) + "\n"
            
            let originalCount = originalMeasurements.count
            let filteredCount = filteredData.count
            let activeFilters = getActiveFilters()
            
            let filterInfo = String(format: "🔍 Filtered: %d/%d spans | Active: %s",
                                   filteredCount, originalCount, activeFilters.joined(separator: ", "))
            
            output += String(format: "║ %-*s ║\n",
                           totalWidth - 4, filterInfo.colored(with: .brightBlack))
        }
        
        output += bottomBorder.colored(with: .blue, style: .bold) + "\n"
        
        return output
    }
    
    // MARK: - Table Style
    
    internal func generateTableOutput() -> String {
        let totalDuration = getTotalDuration()
        let displayMeasurements = getMeasurements()
        
        let indexWidth = 4
        let nameWidth = 45
        let durationWidth = 20
        
        let totalTableWidth = indexWidth + nameWidth + durationWidth + 3
        
        var output = ""
        
        let topBorder = "┌" + String(repeating: "─", count: indexWidth) + "┬" + 
                       String(repeating: "─", count: nameWidth) + "┬" + 
                       String(repeating: "─", count: durationWidth) + "┐"
        let headerSeparator = "├" + String(repeating: "─", count: indexWidth) + "┼" + 
                             String(repeating: "─", count: nameWidth) + "┼" + 
                             String(repeating: "─", count: durationWidth) + "┤"
        let bottomBorder = "└" + String(repeating: "─", count: indexWidth) + "┴" + 
                          String(repeating: "─", count: nameWidth) + "┴" + 
                          String(repeating: "─", count: durationWidth) + "┘"
        
        // Header
        output += topBorder.colored(with: .blue, style: .bold) + "\n"
        
        // Table title
        let titlePadding = max(1, (totalTableWidth - name.count - 4) / 2)
        let remainingPadding = max(1, totalTableWidth - name.count - titlePadding - 4)
        
        let titleStr = String(format: "│%@🚀 %@%@│",
                             String(repeating: " ", count: titlePadding),
                             name,
                             String(repeating: " ", count: remainingPadding))
        output += titleStr.colored(with: .magenta, style: .bold) + "\n"
        
        // Caller info if available
        if let caller = callerInfo {
            let callerText = "📍 File: \(caller.shortDescription)"
            let callerPadding = max(1, (totalTableWidth - callerText.count - 2) / 2)
            let remainingCallerPadding = max(1, totalTableWidth - callerText.count - callerPadding - 2)
            
            let callerStr = String(format: "│%@%@%@│",
                                  String(repeating: " ", count: callerPadding),
                                  callerText,
                                  String(repeating: " ", count: remainingCallerPadding))
            output += callerStr.colored(with: .brightBlack) + "\n"
        }
        
        output += headerSeparator.colored(with: .blue, style: .bold) + "\n"
        
        // Column headers
        output += String(format: "│ %-2s │ %-*s│ %s│\n",
                        "No".colored(with: .magenta, style: .bold),
                        nameWidth - 1, "Span Name".colored(with: .magenta, style: .bold),
                        "Duration".colored(with: .magenta, style: .bold))
        
        output += headerSeparator.colored(with: .cyan) + "\n"
        
        // Total time row
        output += String(format: "│ %-2s │ %-*s│ %s│\n",
                        "".colored(with: .green, style: .bold),
                        nameWidth - 1, "📊 TOTAL EXECUTION TIME".colored(with: .green, style: .bold),
                        String(format: "%.3fs", totalDuration).colored(with: ColorRules.colorForDuration(totalDuration)))
        
        output += headerSeparator.colored(with: .cyan) + "\n"
        
        // Data rows
        for (i, measurement) in displayMeasurements.enumerated() {
            let color = ColorRules.colorForDuration(measurement.duration)
            
            var spanName = measurement.statement
            if spanName.count > nameWidth - 2 {
                spanName = String(spanName.prefix(nameWidth - 5)) + "..."
            }
            
            output += String(format: "│ %*d │ %-*s│ %s│\n",
                           indexWidth - 2, i + 1,
                           nameWidth - 1, spanName.colored(with: color),
                           String(format: "%.3fs", measurement.duration).colored(with: color))
        }
        
        output += bottomBorder.colored(with: .blue, style: .bold) + "\n"
        
        // Summary statistics
        output += "\n"
        output += String(format: "%@ | ", "📈 Spans: \(displayMeasurements.count)".colored(with: .brightBlack))
        
        if let slowest = displayMeasurements.max(by: { $0.duration < $1.duration }) {
            output += String(format: "%@", "🐌 Slowest: \(slowest.statement) (\(String(format: "%.3fs", slowest.duration)))".colored(with: .brightBlack))
        }
        output += "\n"
        
        return output
    }
    
    // MARK: - JSON Style
    
    internal func generateJSONOutput() -> String {
        let totalDuration = getTotalDuration()
        let displayMeasurements = getMeasurements()
        
        var output = ""
        output += "📄 JSON Output:".colored(with: .magenta, style: .bold) + "\n"
        
        // Create structured data
        var data: [String: Any] = [
            "tracer_name": name,
            "total_duration": String(format: "%.6f", totalDuration),
            "total_ns": Int(totalDuration * 1_000_000_000),
            "spans": []
        ]
        
        // Add caller info if available
        if let caller = callerInfo {
            data["caller_info"] = [
                "file": caller.shortDescription,
                "full_path": caller.file,
                "line": caller.line,
                "function": caller.function
            ]
        }
        
        var spans: [[String: Any]] = []
        for measurement in displayMeasurements {
            let colorClass: String
            if measurement.duration > 1.0 {
                colorClass = "slow"
            } else if measurement.duration > 0.1 {
                colorClass = "medium"
            } else if measurement.duration > 0.01 {
                colorClass = "fast"
            } else {
                colorClass = "very_fast"
            }
            
            let span: [String: Any] = [
                "name": measurement.statement,
                "duration": String(format: "%.6f", measurement.duration),
                "ns": Int(measurement.duration * 1_000_000_000),
                "percent": (measurement.duration / totalDuration) * 100,
                "color_class": colorClass
            ]
            spans.append(span)
        }
        data["spans"] = spans
        
        // Pretty print JSON
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data, options: [.prettyPrinted, .sortedKeys])
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                output += jsonString + "\n"
            }
        } catch {
            output += "Error generating JSON: \(error)\n"
        }
        
        return output
    }
}

