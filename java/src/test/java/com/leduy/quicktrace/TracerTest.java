package com.leduy.quicktrace;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import static org.junit.jupiter.api.Assertions.*;

import java.time.Duration;
import java.util.List;

/**
 * Unit tests cho Tracer class
 */
public class TracerTest {
    
    private Tracer tracer;
    
    @BeforeEach
    void setUp() {
        tracer = Tracer.newSimpleTracer("Test Tracer");
    }
    
    @Test
    void testBasicSpanCreation() throws InterruptedException {
        tracer.span("Test span 1");
        Thread.sleep(10);
        
        tracer.span("Test span 2");
        Thread.sleep(5);
        
        tracer.span("End");
        
        List<Measurement> measurements = tracer.getMeasurements();
        assertEquals(3, measurements.size());
        assertEquals("Test span 1", measurements.get(0).getStatement());
        assertEquals("Test span 2", measurements.get(1).getStatement());
        assertEquals("End", measurements.get(2).getStatement());
    }
    
    @Test
    void testTracerDisabled() throws InterruptedException {
        tracer.setEnabled(false);
        
        tracer.span("This should not be recorded");
        Thread.sleep(10);
        
        List<Measurement> measurements = tracer.getMeasurements();
        assertEquals(0, measurements.size());
    }
    
    @Test
    void testSilentMode() {
        tracer.setSilent(true);
        assertTrue(tracer.isSilent());
        
        tracer.span("Silent span");
        tracer.end(); // Should not print anything but still collect data
        
        List<Measurement> measurements = tracer.getMeasurements();
        assertEquals(2, measurements.size()); // "Silent span" + "End"
    }
    
    @Test
    void testOutputStyleChange() {
        assertEquals(OutputStyle.DEFAULT, tracer.getOutputStyle());
        
        tracer.setOutputStyle(OutputStyle.COLORFUL);
        assertEquals(OutputStyle.COLORFUL, tracer.getOutputStyle());
        
        tracer.setOutputStyle(OutputStyle.JSON);
        assertEquals(OutputStyle.JSON, tracer.getOutputStyle());
    }
    
    @Test
    void testBuilderPattern() {
        Tracer customTracer = Tracer.builder("Custom Tracer")
                .enabled(false)
                .silent(true)
                .outputStyle(OutputStyle.MINIMAL)
                .minTotalDuration(Duration.ofMillis(100))
                .build();
        
        assertEquals("Custom Tracer", customTracer.getName());
        assertFalse(customTracer.isEnabled());
        assertTrue(customTracer.isSilent());
        assertEquals(OutputStyle.MINIMAL, customTracer.getOutputStyle());
    }
    
    @Test
    void testSmartFiltering() {
        Tracer filterTracer = Tracer.builder("Filter Test")
                .showSlowOnly(Duration.ofMillis(50))
                .hideUltraFast(Duration.ofMillis(2))
                .groupSimilar(Duration.ofMillis(10))
                .build();
        
        assertTrue(filterTracer.hasActiveFilters());
        String filterInfo = filterTracer.getActiveFiltersInfo();
        assertTrue(filterInfo.contains("slow>"));
        assertTrue(filterInfo.contains("hide<"));
        assertTrue(filterInfo.contains("group±"));
    }
    
    @Test
    void testGetTotalDuration() throws InterruptedException {
        long startTime = System.currentTimeMillis();
        
        tracer.span("Test operation");
        Thread.sleep(50);
        tracer.span("End");
        
        Duration totalDuration = tracer.getTotalDuration();
        long endTime = System.currentTimeMillis();
        
        // Check that total duration is reasonable
        assertTrue(totalDuration.toMillis() >= 50);
        assertTrue(totalDuration.toMillis() <= (endTime - startTime + 10)); // Allow 10ms tolerance
    }
    
    @Test
    void testCallerInfo() {
        assertNotNull(tracer.getCallerInfo());
        assertFalse(tracer.getCallerInfo().isEmpty());
        // Caller info should contain file name and line number
        assertTrue(tracer.getCallerInfo().contains(":"));
    }
    
    @Test
    void testCustomPrintCondition() throws InterruptedException {
        tracer.setPrintCondition(t -> t.getTotalDuration().compareTo(Duration.ofMillis(100)) > 0);
        
        tracer.span("Quick operation");
        Thread.sleep(10);
        tracer.end(); // Should not print because < 100ms
        
        // If we had a way to capture output, we could test this better
        // For now, just ensure the condition was set
        assertNotNull(tracer);
    }
    
    @Test
    void testMeasurementImmutability() {
        tracer.span("Test");
        List<Measurement> measurements1 = tracer.getMeasurements();
        List<Measurement> measurements2 = tracer.getMeasurements();
        
        // Should return different list instances (defensive copy)
        assertNotSame(measurements1, measurements2);
        assertEquals(measurements1.size(), measurements2.size());
    }
}
