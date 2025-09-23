package com.leduy.quicktrace;

import java.time.Duration;
import java.util.Arrays;
import java.util.List;

/**
 * Định nghĩa màu sắc và quy tắc ANSI cho cross-platform compatibility
 */
public class ColorRules {
    
    // ANSI color codes constants
    public static final String RESET = "\033[0m";
    
    // Regular colors
    public static final String BLACK = "\033[30m";
    public static final String RED = "\033[31m";
    public static final String GREEN = "\033[32m";
    public static final String YELLOW = "\033[33m";
    public static final String BLUE = "\033[34m";
    public static final String MAGENTA = "\033[35m";
    public static final String CYAN = "\033[36m";
    public static final String WHITE = "\033[37m";
    
    // Bright colors
    public static final String BRIGHT_BLACK = "\033[90m";
    public static final String BRIGHT_RED = "\033[91m";
    public static final String BRIGHT_GREEN = "\033[92m";
    public static final String BRIGHT_YELLOW = "\033[93m";
    public static final String BRIGHT_BLUE = "\033[94m";
    public static final String BRIGHT_MAGENTA = "\033[95m";
    public static final String BRIGHT_CYAN = "\033[96m";
    public static final String BRIGHT_WHITE = "\033[97m";
    
    // Styles
    public static final String BOLD = "\033[1m";
    public static final String DIM = "\033[2m";
    public static final String ITALIC = "\033[3m";
    public static final String UNDERLINE = "\033[4m";
    
    /**
     * Quy tắc màu cho các khoảng thời gian
     */
    public static class ColorRule {
        private final Duration threshold;
        private final String color;
        private final String name;
        
        public ColorRule(Duration threshold, String color, String name) {
            this.threshold = threshold;
            this.color = color;
            this.name = name;
        }
        
        public Duration getThreshold() { return threshold; }
        public String getColor() { return color; }
        public String getName() { return name; }
    }
    
    /**
     * Quy tắc màu cho phần trăm
     */
    public static class PercentageColorRule {
        private final double threshold;
        private final String color;
        private final String name;
        
        public PercentageColorRule(double threshold, String color, String name) {
            this.threshold = threshold;
            this.color = color;
            this.name = name;
        }
        
        public double getThreshold() { return threshold; }
        public String getColor() { return color; }
        public String getName() { return name; }
    }
    
    // Cross-platform safe colors - optimized cho cả Windows và Linux
    public static final List<ColorRule> DURATION_COLOR_RULES = Arrays.asList(
        new ColorRule(Duration.ofSeconds(3), RED + BOLD, "Very Slow"),        // > 3s
        new ColorRule(Duration.ofSeconds(1), RED, "Slow"),                    // 1s-3s
        new ColorRule(Duration.ofMillis(500), YELLOW, "Medium-Slow"),         // 500ms-1s
        new ColorRule(Duration.ofMillis(200), BRIGHT_BLUE, "Medium"),         // 200ms-500ms
        new ColorRule(Duration.ofMillis(100), CYAN, "Normal"),                // 100ms-200ms
        new ColorRule(Duration.ofMillis(50), GREEN, "Fast"),                  // 50ms-100ms
        new ColorRule(Duration.ofMillis(10), BRIGHT_GREEN, "Very Fast"),      // 10ms-50ms
        new ColorRule(Duration.ZERO, BRIGHT_BLACK, "Ultra Fast")              // < 10ms
    );
    
    // Progress bar color rules for percentages
    public static final List<PercentageColorRule> PROGRESS_COLOR_RULES = Arrays.asList(
        new PercentageColorRule(75, RED + BOLD, "Critical"),  // > 75%
        new PercentageColorRule(50, RED, "High"),            // 50-75%
        new PercentageColorRule(25, MAGENTA, "Medium"),      // 25-50%
        new PercentageColorRule(10, BLUE, "Low"),            // 10-25%
        new PercentageColorRule(5, GREEN, "Very Low"),       // 5-10%
        new PercentageColorRule(0, CYAN, "Minimal")          // < 5%
    );
    
    /**
     * Tìm màu cho duration dựa trên rules
     */
    public static String getSpanColor(Duration duration) {
        for (ColorRule rule : DURATION_COLOR_RULES) {
            if (duration.compareTo(rule.getThreshold()) >= 0) {
                return rule.getColor();
            }
        }
        return WHITE; // Fallback
    }
    
    /**
     * Tìm màu cho percentage dựa trên rules
     */
    public static String getProgressBarColor(double percentage) {
        for (PercentageColorRule rule : PROGRESS_COLOR_RULES) {
            if (percentage >= rule.getThreshold()) {
                return rule.getColor();
            }
        }
        return WHITE; // Fallback
    }
    
    /**
     * Lấy tên mô tả màu cho duration
     */
    public static String getDurationColorName(Duration duration) {
        for (ColorRule rule : DURATION_COLOR_RULES) {
            if (duration.compareTo(rule.getThreshold()) >= 0) {
                return rule.getName();
            }
        }
        return "Unknown";
    }
    
    /**
     * Lấy tên mô tả màu cho percentage
     */
    public static String getProgressColorName(double percentage) {
        for (PercentageColorRule rule : PROGRESS_COLOR_RULES) {
            if (percentage >= rule.getThreshold()) {
                return rule.getName();
            }
        }
        return "Unknown";
    }
    
    /**
     * Áp dụng màu ANSI cho text
     */
    public static String colorize(String text, String colorCode) {
        return colorCode + text + RESET;
    }
    
    /**
     * Áp dụng màu ANSI với style cho text
     */
    public static String colorizeWithStyle(String text, String colorCode, String styleCode) {
        return styleCode + colorCode + text + RESET;
    }
}
