package com.leduy.quicktrace;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

import java.time.Duration;

/**
 * Unit tests cho ColorRules class
 */
public class ColorRulesTest {
    
    @Test
    void testGetSpanColorForDifferentDurations() {
        // Test very slow (> 3s)
        String color = ColorRules.getSpanColor(Duration.ofSeconds(5));
        assertEquals(ColorRules.RED + ColorRules.BOLD, color);
        
        // Test slow (1s-3s)
        color = ColorRules.getSpanColor(Duration.ofSeconds(2));
        assertEquals(ColorRules.RED, color);
        
        // Test medium-slow (500ms-1s)
        color = ColorRules.getSpanColor(Duration.ofMillis(750));
        assertEquals(ColorRules.YELLOW, color);
        
        // Test medium (200ms-500ms)
        color = ColorRules.getSpanColor(Duration.ofMillis(300));
        assertEquals(ColorRules.BRIGHT_BLUE, color);
        
        // Test normal (100ms-200ms)
        color = ColorRules.getSpanColor(Duration.ofMillis(150));
        assertEquals(ColorRules.CYAN, color);
        
        // Test fast (50ms-100ms)
        color = ColorRules.getSpanColor(Duration.ofMillis(75));
        assertEquals(ColorRules.GREEN, color);
        
        // Test very fast (10ms-50ms)
        color = ColorRules.getSpanColor(Duration.ofMillis(25));
        assertEquals(ColorRules.BRIGHT_GREEN, color);
        
        // Test ultra fast (< 10ms)
        color = ColorRules.getSpanColor(Duration.ofMillis(5));
        assertEquals(ColorRules.BRIGHT_BLACK, color);
    }
    
    @Test
    void testGetProgressBarColorForDifferentPercentages() {
        // Test critical (> 75%)
        String color = ColorRules.getProgressBarColor(80.0);
        assertEquals(ColorRules.RED + ColorRules.BOLD, color);
        
        // Test high (50-75%)
        color = ColorRules.getProgressBarColor(60.0);
        assertEquals(ColorRules.RED, color);
        
        // Test medium (25-50%)
        color = ColorRules.getProgressBarColor(35.0);
        assertEquals(ColorRules.MAGENTA, color);
        
        // Test low (10-25%)
        color = ColorRules.getProgressBarColor(15.0);
        assertEquals(ColorRules.BLUE, color);
        
        // Test very low (5-10%)
        color = ColorRules.getProgressBarColor(7.0);
        assertEquals(ColorRules.GREEN, color);
        
        // Test minimal (< 5%)
        color = ColorRules.getProgressBarColor(2.0);
        assertEquals(ColorRules.CYAN, color);
    }
    
    @Test
    void testGetDurationColorName() {
        assertEquals("Very Slow", ColorRules.getDurationColorName(Duration.ofSeconds(5)));
        assertEquals("Slow", ColorRules.getDurationColorName(Duration.ofSeconds(2)));
        assertEquals("Medium-Slow", ColorRules.getDurationColorName(Duration.ofMillis(750)));
        assertEquals("Medium", ColorRules.getDurationColorName(Duration.ofMillis(300)));
        assertEquals("Normal", ColorRules.getDurationColorName(Duration.ofMillis(150)));
        assertEquals("Fast", ColorRules.getDurationColorName(Duration.ofMillis(75)));
        assertEquals("Very Fast", ColorRules.getDurationColorName(Duration.ofMillis(25)));
        assertEquals("Ultra Fast", ColorRules.getDurationColorName(Duration.ofMillis(5)));
    }
    
    @Test
    void testGetProgressColorName() {
        assertEquals("Critical", ColorRules.getProgressColorName(80.0));
        assertEquals("High", ColorRules.getProgressColorName(60.0));
        assertEquals("Medium", ColorRules.getProgressColorName(35.0));
        assertEquals("Low", ColorRules.getProgressColorName(15.0));
        assertEquals("Very Low", ColorRules.getProgressColorName(7.0));
        assertEquals("Minimal", ColorRules.getProgressColorName(2.0));
    }
    
    @Test
    void testColorize() {
        String colorizedText = ColorRules.colorize("Hello", ColorRules.RED);
        assertEquals(ColorRules.RED + "Hello" + ColorRules.RESET, colorizedText);
    }
    
    @Test
    void testColorizeWithStyle() {
        String colorizedText = ColorRules.colorizeWithStyle("Hello", ColorRules.RED, ColorRules.BOLD);
        assertEquals(ColorRules.BOLD + ColorRules.RED + "Hello" + ColorRules.RESET, colorizedText);
    }
    
    @Test
    void testAnsiConstants() {
        // Test some key ANSI constants
        assertEquals("\033[0m", ColorRules.RESET);
        assertEquals("\033[31m", ColorRules.RED);
        assertEquals("\033[32m", ColorRules.GREEN);
        assertEquals("\033[1m", ColorRules.BOLD);
        assertEquals("\033[91m", ColorRules.BRIGHT_RED);
    }
    
    @Test
    void testBoundaryValues() {
        // Test exact boundary values
        assertEquals("Medium", ColorRules.getDurationColorName(Duration.ofMillis(200))); // Exactly 200ms
        assertEquals("Normal", ColorRules.getDurationColorName(Duration.ofMillis(100))); // Exactly 100ms
        assertEquals("Fast", ColorRules.getDurationColorName(Duration.ofMillis(50)));   // Exactly 50ms
        assertEquals("Very Fast", ColorRules.getDurationColorName(Duration.ofMillis(10))); // Exactly 10ms
        assertEquals("Ultra Fast", ColorRules.getDurationColorName(Duration.ofMillis(0))); // Zero duration
    }
}
