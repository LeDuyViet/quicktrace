package com.leduy.quicktrace;

import java.time.Duration;
import java.util.*;

/**
 * Xử lý rendering output cho các style khác nhau
 */
public class OutputRenderer {
    
    /**
     * Render default style output
     */
    public static String renderDefault(Tracer tracer) {
        StringBuilder sb = new StringBuilder();
        Duration totalDuration = tracer.getTotalDuration();
        List<Measurement> measurements = tracer.getMeasurements();
        
        String separator = "=".repeat(70);
        String thinSeparator = "-".repeat(70);
        
        sb.append(ColorRules.colorizeWithStyle(separator, ColorRules.CYAN, ColorRules.BOLD)).append("\n");
        sb.append(ColorRules.colorizeWithStyle(String.format("| %-66s |", tracer.getName()), 
                ColorRules.YELLOW, ColorRules.BOLD)).append("\n");
        sb.append(ColorRules.colorizeWithStyle(separator, ColorRules.CYAN, ColorRules.BOLD)).append("\n");
        sb.append(ColorRules.colorizeWithStyle(String.format("| %-20s | ", "Total time"), 
                ColorRules.GREEN, ColorRules.BOLD));
        sb.append(ColorRules.colorize(String.format("%-45s |", totalDuration), ColorRules.GREEN)).append("\n");
        sb.append(ColorRules.colorize(thinSeparator, ColorRules.CYAN)).append("\n");
        sb.append(ColorRules.colorizeWithStyle(String.format("| %-45s | %-20s |", "Span", "Execution time"), 
                ColorRules.MAGENTA, ColorRules.BOLD)).append("\n");
        sb.append(ColorRules.colorize(thinSeparator, ColorRules.CYAN)).append("\n");
        
        // Exclude "End" measurement
        for (int i = 0; i < measurements.size() - 1; i++) {
            Measurement m = measurements.get(i);
            String spanColor = ColorRules.getSpanColor(m.getDuration());
            sb.append("| ");
            sb.append(ColorRules.colorize(String.format("%-45s", m.getStatement()), spanColor));
            sb.append(" | ");
            sb.append(ColorRules.colorize(String.format("%-20s", m.getDuration()), spanColor));
            sb.append(" |\n");
        }
        
        sb.append(ColorRules.colorizeWithStyle(separator, ColorRules.CYAN, ColorRules.BOLD)).append("\n");
        return sb.toString();
    }
    
    /**
     * Render colorful style output
     */
    public static String renderColorful(Tracer tracer) {
        StringBuilder sb = new StringBuilder();
        Duration totalDuration = tracer.getTotalDuration();
        List<Measurement> measurements = tracer.getMeasurements();
        
        final int nameWidth = 35;
        final int durationWidth = 25;
        final int totalTableWidth = nameWidth + durationWidth + 4;
        
        String topBorder = "┌" + "─".repeat(totalTableWidth - 2) + "┐";
        String separator = "├" + "─".repeat(totalTableWidth - 2) + "┤";
        String bottomBorder = "└" + "─".repeat(totalTableWidth - 2) + "┘";
        
        // Header
        sb.append(ColorRules.colorizeWithStyle(topBorder, ColorRules.CYAN, ColorRules.BOLD)).append("\n");
        
        // Title row
        String titleText = "🚀 " + tracer.getName();
        int titlePadding = Math.max(1, (totalTableWidth - titleText.length() - 2) / 2);
        int remainingPadding = Math.max(1, totalTableWidth - titleText.length() - titlePadding - 2);
        
        String titleStr = String.format("│%s%s%s│",
                " ".repeat(titlePadding), titleText, " ".repeat(remainingPadding));
        sb.append(ColorRules.colorizeWithStyle(titleStr, ColorRules.YELLOW, ColorRules.BOLD)).append("\n");
        
        // Caller info if available
        if (!tracer.getCallerInfo().equals("Unknown:0")) {
            String callerInfo = String.format("📍 File: %s", tracer.getCallerInfo());
            int callerPadding = Math.max(1, (totalTableWidth - callerInfo.length() - 2) / 2);
            int remainingCallerPadding = Math.max(1, totalTableWidth - callerInfo.length() - callerPadding - 2);
            
            String callerStr = String.format("│%s%s%s│",
                    " ".repeat(callerPadding), callerInfo, " ".repeat(remainingCallerPadding));
            sb.append(ColorRules.colorize(callerStr, ColorRules.BRIGHT_BLACK)).append("\n");
        }
        
        sb.append(ColorRules.colorizeWithStyle(separator, ColorRules.CYAN, ColorRules.BOLD)).append("\n");
        
        // Total time row
        String totalLine = String.format("│ ⏱️  Total Time: %-" + (nameWidth - 16) + "s │ %s",
                "", totalDuration);
        sb.append(ColorRules.colorizeWithStyle(totalLine, ColorRules.GREEN, ColorRules.BOLD)).append("\n");
        
        sb.append(ColorRules.colorize(separator, ColorRules.CYAN)).append("\n");
        
        // Column headers
        String headerLine = String.format("│ %-" + nameWidth + "s │ %s", "📋 Span", "⏰ Duration");
        sb.append(ColorRules.colorizeWithStyle(headerLine, ColorRules.MAGENTA, ColorRules.BOLD)).append("\n");
        
        sb.append(ColorRules.colorize(separator, ColorRules.CYAN)).append("\n");
        
        // Spans với colorful formatting
        for (int i = 0; i < measurements.size() - 1; i++) {
            Measurement m = measurements.get(i);
            String spanColor = ColorRules.getSpanColor(m.getDuration());
            
            String spanName = m.getStatement();
            if (spanName.length() > nameWidth) {
                spanName = spanName.substring(0, nameWidth - 3) + "...";
            }
            
            sb.append("│ ");
            sb.append(ColorRules.colorize(String.format("%-" + nameWidth + "s", spanName), spanColor));
            sb.append(" │ ");
            sb.append(ColorRules.colorize(m.getDuration().toString(), spanColor));
            sb.append("\n");
        }
        
        sb.append(ColorRules.colorizeWithStyle(bottomBorder, ColorRules.CYAN, ColorRules.BOLD)).append("\n");
        return sb.toString();
    }
    
    /**
     * Render minimal style output
     */
    public static String renderMinimal(Tracer tracer) {
        StringBuilder sb = new StringBuilder();
        Duration totalDuration = tracer.getTotalDuration();
        List<Measurement> measurements = tracer.getMeasurements();
        
        final int nameWidth = 35;
        final int durationWidth = 25;
        final int totalWidth = nameWidth + durationWidth + 4;
        
        String topBorder = "┌" + "─".repeat(totalWidth - 2) + "┐";
        String separator = "├" + "─".repeat(totalWidth - 2) + "┤";
        String bottomBorder = "└" + "─".repeat(totalWidth - 2) + "┘";
        
        sb.append(ColorRules.colorizeWithStyle(topBorder, ColorRules.CYAN, ColorRules.BOLD)).append("\n");
        
        // Title and total time
        String titleText = "⚡ " + tracer.getName();
        if (titleText.length() > nameWidth) {
            titleText = titleText.substring(0, nameWidth - 3) + "...";
        }
        
        String titleLine = String.format("│ %-" + nameWidth + "s │ %s", titleText, totalDuration);
        sb.append(ColorRules.colorizeWithStyle(titleLine, ColorRules.CYAN, ColorRules.BOLD)).append("\n");
        
        // Caller info if available
        if (!tracer.getCallerInfo().equals("Unknown:0")) {
            String callerInfo = String.format("📍 File: %s", tracer.getCallerInfo());
            if (callerInfo.length() > nameWidth) {
                callerInfo = callerInfo.substring(0, nameWidth - 3) + "...";
            }
            
            String callerLine = String.format("│ %-" + nameWidth + "s │ %s", callerInfo, "");
            sb.append(ColorRules.colorize(callerLine, ColorRules.BRIGHT_BLACK)).append("\n");
        }
        
        sb.append(ColorRules.colorize(separator, ColorRules.CYAN)).append("\n");
        
        // Minimal span listing
        for (int i = 0; i < measurements.size() - 1; i++) {
            Measurement m = measurements.get(i);
            String spanColor = ColorRules.getSpanColor(m.getDuration());
            
            String spanName = "  └─ " + m.getStatement();
            if (spanName.length() > nameWidth) {
                spanName = spanName.substring(0, nameWidth - 3) + "...";
            }
            
            sb.append("│ ");
            sb.append(ColorRules.colorize(String.format("%-" + nameWidth + "s", spanName), spanColor));
            sb.append(" │ ");
            sb.append(ColorRules.colorize(m.getDuration().toString(), spanColor));
            sb.append("\n");
        }
        
        sb.append(ColorRules.colorizeWithStyle(bottomBorder, ColorRules.CYAN, ColorRules.BOLD)).append("\n");
        return sb.toString();
    }
    
    /**
     * Render detailed style output with smart filtering
     */
    public static String renderDetailed(Tracer tracer) {
        StringBuilder sb = new StringBuilder();
        Duration totalDuration = tracer.getTotalDuration();
        List<Measurement> measurements = tracer.getMeasurements();
        
        final int indexWidth = 3;
        final int nameWidth = 30;
        final int durationWidth = 15;
        final int percentWidth = 8;
        final int barWidth = 12;
        final int totalWidth = indexWidth + nameWidth + durationWidth + percentWidth + barWidth + 12;
        
        // Unicode borders
        String topBorder = "╔" + "═".repeat(totalWidth - 2) + "╗";
        String separator = "╠" + "═".repeat(totalWidth - 2) + "╣";
        String thinSeparator = "╟" + "─".repeat(totalWidth - 2) + "╢";
        String bottomBorder = "╚" + "═".repeat(totalWidth - 2) + "╝";
        
        // Header
        sb.append(ColorRules.colorizeWithStyle(topBorder, ColorRules.BLUE, ColorRules.BOLD)).append("\n");
        
        // Title row
        String titleText = "🎯 TRACE: " + tracer.getName();
        int titlePadding = Math.max(1, (totalWidth - titleText.length() - 2) / 2);
        int remainingPadding = Math.max(1, totalWidth - titleText.length() - titlePadding - 2);
        
        String titleStr = String.format("║%s%s%s║",
                " ".repeat(titlePadding), titleText, " ".repeat(remainingPadding));
        sb.append(ColorRules.colorizeWithStyle(titleStr, ColorRules.MAGENTA, ColorRules.BOLD)).append("\n");
        
        sb.append(ColorRules.colorizeWithStyle(separator, ColorRules.BLUE, ColorRules.BOLD)).append("\n");
        
        // Summary section
        sb.append(ColorRules.colorizeWithStyle("║ 📊 SUMMARY" + " ".repeat(totalWidth - 13) + "║\n", 
                ColorRules.GREEN, ColorRules.BOLD));
        
        // Total execution time
        String totalTimeStr = totalDuration.toString();
        String prefix = "║ • Total Execution Time: ";
        int usedWidth = prefix.length() + totalTimeStr.length();
        int paddingRight = Math.max(0, totalWidth - usedWidth - 1);
        
        sb.append(prefix);
        sb.append(ColorRules.colorizeWithStyle(totalTimeStr, ColorRules.GREEN, ColorRules.BOLD));
        sb.append(" ".repeat(paddingRight)).append("║\n");
        
        // Number of spans
        int spanCount = measurements.size() - 1;
        String spanCountStr = String.valueOf(spanCount);
        prefix = "║ • Number of Spans: ";
        usedWidth = prefix.length() + spanCountStr.length();
        paddingRight = Math.max(0, totalWidth - usedWidth - 1);
        
        sb.append(prefix);
        sb.append(ColorRules.colorizeWithStyle(spanCountStr, ColorRules.BLUE, ColorRules.BOLD));
        sb.append(" ".repeat(paddingRight)).append("║\n");
        
        // Find slowest operation
        Measurement slowest = measurements.stream()
                .limit(measurements.size() - 1)
                .max(Comparator.comparing(Measurement::getDuration))
                .orElse(new Measurement("None", Duration.ZERO));
        
        String slowestName = slowest.getStatement();
        if (slowestName.length() > 25) {
            slowestName = slowestName.substring(0, 22) + "...";
        }
        
        prefix = "║ • Slowest Operation: ";
        usedWidth = prefix.length() + slowestName.length();
        paddingRight = Math.max(0, totalWidth - usedWidth - 1);
        
        sb.append(prefix);
        sb.append(ColorRules.colorizeWithStyle(slowestName, ColorRules.RED, ColorRules.BOLD));
        sb.append(" ".repeat(paddingRight)).append("║\n");
        
        String slowestDurStr = slowest.getDuration().toString();
        prefix = "║ • Slowest Duration: ";
        usedWidth = prefix.length() + slowestDurStr.length();
        paddingRight = Math.max(0, totalWidth - usedWidth - 1);
        
        sb.append(prefix);
        sb.append(ColorRules.colorizeWithStyle(slowestDurStr, ColorRules.RED, ColorRules.BOLD));
        sb.append(" ".repeat(paddingRight)).append("║\n");
        
        // Caller info if available
        if (!tracer.getCallerInfo().equals("Unknown:0")) {
            String callerInfoStr = tracer.getCallerInfo();
            prefix = "║ • File: ";
            sb.append(prefix);
            sb.append(ColorRules.colorizeWithStyle(callerInfoStr, ColorRules.BRIGHT_BLACK, ColorRules.BOLD));
            sb.append("║\n");
        }
        
        sb.append(ColorRules.colorizeWithStyle(separator, ColorRules.BLUE, ColorRules.BOLD)).append("\n");
        
        // Detailed breakdown header
        sb.append(ColorRules.colorizeWithStyle("║ 🔍 DETAILED BREAKDOWN" + " ".repeat(totalWidth - 23) + "║\n", 
                ColorRules.MAGENTA, ColorRules.BOLD));
        sb.append(ColorRules.colorizeWithStyle(thinSeparator, ColorRules.BLUE, ColorRules.BOLD)).append("\n");
        
        // Column headers
        sb.append("║");
        sb.append(ColorRules.colorizeWithStyle(String.format(" %" + indexWidth + "s", "#"), ColorRules.MAGENTA, ColorRules.BOLD));
        sb.append(" │");
        sb.append(ColorRules.colorizeWithStyle(String.format(" %-" + (nameWidth - 1) + "s", "Operation"), ColorRules.MAGENTA, ColorRules.BOLD));
        sb.append(" │");
        sb.append(ColorRules.colorizeWithStyle(String.format(" %" + (durationWidth - 1) + "s", "Duration"), ColorRules.MAGENTA, ColorRules.BOLD));
        sb.append(" │");
        sb.append(ColorRules.colorizeWithStyle(String.format(" %" + (percentWidth - 1) + "s", "Percent"), ColorRules.MAGENTA, ColorRules.BOLD));
        sb.append(" │");
        sb.append(ColorRules.colorizeWithStyle(String.format(" %-" + (barWidth - 1) + "s", "Progress"), ColorRules.MAGENTA, ColorRules.BOLD));
        sb.append(" ║\n");
        
        sb.append(ColorRules.colorize(thinSeparator, ColorRules.CYAN)).append("\n");
        
        // Apply smart filtering to measurements  
        List<Object> filteredData = tracer.applySmartFiltering(measurements.subList(0, measurements.size() - 1));
        
        // Data rows với smart filtering
        for (int i = 0; i < filteredData.size(); i++) {
            Object item = filteredData.get(i);
            String operationName;
            Duration duration;
            boolean isGrouped = false;
            
            // Check if it's a grouped measurement or regular measurement
            if (item instanceof GroupedMeasurement) {
                GroupedMeasurement group = (GroupedMeasurement) item;
                operationName = group.getName();
                duration = group.getAvgTime();
                isGrouped = true;
            } else {
                Measurement m = (Measurement) item;
                operationName = m.getStatement();
                duration = m.getDuration();
            }
            
            double percentage = (double) duration.toNanos() / totalDuration.toNanos() * 100;
            
            // Progress bar
            int barLength = Math.min(barWidth - 1, Math.max(0, (int) (percentage / 8)));
            String progressBar = "█".repeat(barLength) + "░".repeat((barWidth - 1) - barLength);
            
            // Add icon for grouped items  
            String displayName = operationName;
            if (isGrouped) {
                displayName = "📦 " + operationName;
            }
            
            // Truncate operation name if too long
            if (displayName.length() > nameWidth - 1) {
                displayName = displayName.substring(0, nameWidth - 4) + "...";
            }
            
            String percentStr = String.format("%.1f%%", percentage);
            String spanColor = ColorRules.getSpanColor(duration);
            String progressColor = ColorRules.BLUE + ColorRules.BOLD;
            
            sb.append("║");
            sb.append(String.format(" %" + indexWidth + "d", i + 1));
            sb.append(" │ ");
            sb.append(ColorRules.colorize(String.format("%-" + (nameWidth - 1) + "s", displayName), spanColor));
            sb.append(" │ ");
            sb.append(ColorRules.colorize(String.format("%" + (durationWidth - 2) + "s", duration), spanColor));
            sb.append(" │ ");
            sb.append(ColorRules.colorize(String.format("%" + (percentWidth - 2) + "s", percentStr), spanColor));
            sb.append(" │ ");
            sb.append(ColorRules.colorize(String.format("%-" + (barWidth - 1) + "s", progressBar), progressColor));
            sb.append(" ║\n");
        }
        
        // Show filtering summary if any filters are applied
        if (tracer.hasActiveFilters()) {
            sb.append(ColorRules.colorize(thinSeparator, ColorRules.CYAN)).append("\n");
            
            int originalCount = measurements.size() - 1;
            int filteredCount = filteredData.size();
            
            String filterInfo = String.format("🔍 Filtered: %d/%d spans | Active: %s",
                    filteredCount, originalCount, tracer.getActiveFiltersInfo());
            
            sb.append("║ ");
            sb.append(ColorRules.colorize(String.format("%-" + (totalWidth - 4) + "s", filterInfo), ColorRules.BRIGHT_BLACK));
            sb.append(" ║\n");
        }
        
        sb.append(ColorRules.colorizeWithStyle(bottomBorder, ColorRules.BLUE, ColorRules.BOLD)).append("\n");
        return sb.toString();
    }
    
    /**
     * Render table style output
     */
    public static String renderTable(Tracer tracer) {
        StringBuilder sb = new StringBuilder();
        Duration totalDuration = tracer.getTotalDuration();
        List<Measurement> measurements = tracer.getMeasurements();
        
        final int indexWidth = 4;
        final int nameWidth = 45;
        final int durationWidth = 20;
        final int totalTableWidth = indexWidth + nameWidth + durationWidth + 3;
        
        String topBorder = "┌" + "─".repeat(indexWidth) + "┬" + "─".repeat(nameWidth) + "┬" + "─".repeat(durationWidth) + "┐";
        String headerSeparator = "├" + "─".repeat(indexWidth) + "┼" + "─".repeat(nameWidth) + "┼" + "─".repeat(durationWidth) + "┤";
        String bottomBorder = "└" + "─".repeat(indexWidth) + "┴" + "─".repeat(nameWidth) + "┴" + "─".repeat(durationWidth) + "┘";
        
        // Header
        sb.append(ColorRules.colorizeWithStyle(topBorder, ColorRules.BLUE, ColorRules.BOLD)).append("\n");
        
        // Table title
        int titlePadding = Math.max(1, (totalTableWidth - tracer.getName().length() - 4) / 2);
        int remainingPadding = Math.max(1, totalTableWidth - tracer.getName().length() - titlePadding - 4);
        
        String titleStr = String.format("│%s🚀 %s%s│",
                " ".repeat(titlePadding), tracer.getName(), " ".repeat(remainingPadding));
        sb.append(ColorRules.colorizeWithStyle(titleStr, ColorRules.MAGENTA, ColorRules.BOLD)).append("\n");
        
        // Caller info if available
        if (!tracer.getCallerInfo().equals("Unknown:0")) {
            String callerInfo = String.format("📍 File: %s", tracer.getCallerInfo());
            int callerPadding = Math.max(1, (totalTableWidth - callerInfo.length() - 2) / 2);
            int remainingCallerPadding = Math.max(1, totalTableWidth - callerInfo.length() - callerPadding - 2);
            
            String callerStr = String.format("│%s%s%s│",
                    " ".repeat(callerPadding), callerInfo, " ".repeat(remainingCallerPadding));
            sb.append(ColorRules.colorize(callerStr, ColorRules.BRIGHT_BLACK)).append("\n");
        }
        
        sb.append(ColorRules.colorizeWithStyle(headerSeparator, ColorRules.BLUE, ColorRules.BOLD)).append("\n");
        
        // Column headers
        sb.append("│");
        sb.append(ColorRules.colorizeWithStyle(String.format(" %-2s ", "No"), ColorRules.MAGENTA, ColorRules.BOLD));
        sb.append("│");
        sb.append(ColorRules.colorizeWithStyle(String.format(" %-" + (nameWidth - 1) + "s", "Span Name"), ColorRules.MAGENTA, ColorRules.BOLD));
        sb.append("│");
        sb.append(ColorRules.colorizeWithStyle(" Duration", ColorRules.MAGENTA, ColorRules.BOLD));
        sb.append("│\n");
        
        sb.append(ColorRules.colorize(headerSeparator, ColorRules.CYAN)).append("\n");
        
        // Summary row với total duration
        sb.append("│");
        sb.append(ColorRules.colorizeWithStyle(String.format(" %-2s ", ""), ColorRules.GREEN, ColorRules.BOLD));
        sb.append("│");
        sb.append(ColorRules.colorizeWithStyle(String.format(" %-" + (nameWidth - 1) + "s", "📊 TOTAL EXECUTION TIME"), 
                ColorRules.GREEN, ColorRules.BOLD));
        sb.append("│ ");
        
        String totalColor = ColorRules.getSpanColor(totalDuration);
        sb.append(ColorRules.colorize(totalDuration.toString(), totalColor));
        sb.append("│\n");
        
        sb.append(ColorRules.colorize(headerSeparator, ColorRules.CYAN)).append("\n");
        
        // Data rows với spans
        for (int i = 0; i < measurements.size() - 1; i++) {
            Measurement m = measurements.get(i);
            String spanColor = ColorRules.getSpanColor(m.getDuration());
            
            sb.append("│");
            sb.append(String.format(" %" + (indexWidth - 2) + "d ", i + 1));
            sb.append("│ ");
            
            String spanName = m.getStatement();
            if (spanName.length() > nameWidth - 2) {
                spanName = spanName.substring(0, nameWidth - 5) + "...";
            }
            sb.append(ColorRules.colorize(String.format("%-" + (nameWidth - 1) + "s", spanName), spanColor));
            sb.append("│ ");
            
            sb.append(ColorRules.colorize(m.getDuration().toString(), spanColor));
            sb.append("│\n");
        }
        
        sb.append(ColorRules.colorizeWithStyle(bottomBorder, ColorRules.BLUE, ColorRules.BOLD)).append("\n");
        
        // Summary statistics
        sb.append("\n");
        sb.append(ColorRules.colorize(String.format("📈 Spans: %d | ", measurements.size() - 1), ColorRules.BRIGHT_BLACK));
        
        Measurement slowest = measurements.stream()
                .limit(measurements.size() - 1)
                .max(Comparator.comparing(Measurement::getDuration))
                .orElse(new Measurement("None", Duration.ZERO));
        sb.append(ColorRules.colorize(String.format("🐌 Slowest: %s (%s)", slowest.getStatement(), slowest.getDuration()), 
                ColorRules.BRIGHT_BLACK));
        sb.append("\n");
        
        return sb.toString();
    }
}
