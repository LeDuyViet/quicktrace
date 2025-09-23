package com.leduy.quicktrace.examples;

import com.leduy.quicktrace.OutputStyle;
import com.leduy.quicktrace.Tracer;
import java.time.Duration;

/**
 * Advanced usage với smart filtering
 */
public class AdvancedExample {
    
    public static void main(String[] args) throws InterruptedException {
        // Advanced usage với smart filtering
        Tracer tracer = Tracer.builder("Advanced Example")
                .outputStyle(OutputStyle.DETAILED)
                .hideUltraFast(Duration.ofMillis(1))
                .showSlowOnly(Duration.ofMillis(10))
                .groupSimilar(Duration.ofMillis(5))
                .build();
        
        // Simulate database operations
        tracer.span("Connect to database");
        Thread.sleep(100);
        
        tracer.span("Execute query 1");
        Thread.sleep(45);
        
        tracer.span("Execute query 2");
        Thread.sleep(50); // Similar to query 1
        
        tracer.span("Cache result");
        Thread.sleep(5);
        
        tracer.span("Ultra fast operation");
        Thread.sleep(1); // Will be hidden
        
        tracer.span("Process business logic");
        Thread.sleep(200);
        
        tracer.span("Send notification");
        Thread.sleep(30);
        
        tracer.end();
    }
}
