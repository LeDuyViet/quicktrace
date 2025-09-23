package com.leduy.quicktrace.examples;

import com.leduy.quicktrace.OutputStyle;
import com.leduy.quicktrace.Tracer;
import java.time.Duration;

/**
 * Smart Filtering Examples
 */
public class FilteringExample {
    
    private static void simulateVariousOperations(Tracer tracer) throws InterruptedException {
        // Ultra fast operations
        Thread.sleep(1);
        tracer.span("Ultra fast operation 1");

        Thread.sleep(1);
        tracer.span("Ultra fast operation 2");

        // Fast operations
        Thread.sleep(5);
        tracer.span("Fast validation");

        Thread.sleep(8);
        tracer.span("Quick lookup");

        // Medium operations
        Thread.sleep(45);
        tracer.span("Medium processing");

        Thread.sleep(48); // Similar to above
        tracer.span("Similar processing");

        Thread.sleep(44); // Also similar
        tracer.span("Another similar task");

        // Slow operations
        Thread.sleep(150);
        tracer.span("Slow database query");

        Thread.sleep(200);
        tracer.span("Complex computation");

        // Very slow operation
        Thread.sleep(800);
        tracer.span("Very slow external API call");
    }
    
    public static void main(String[] args) throws InterruptedException {
        System.out.println("🎯 Smart Filtering Examples");
        System.out.println("===========================");
        
        // Example 1: No filtering (show all)
        System.out.println("\n1️⃣ No Filtering (Show All Operations)");
        System.out.println("-------------------------------------");
        Tracer tracer1 = Tracer.builder("Complete Trace")
                .outputStyle(OutputStyle.DETAILED)
                .build();
        simulateVariousOperations(tracer1);
        tracer1.end();
        
        Thread.sleep(1000);
        
        // Example 2: Hide ultra fast operations
        System.out.println("\n2️⃣ Hide Ultra Fast Operations (< 2ms)");
        System.out.println("--------------------------------------");
        Tracer tracer2 = Tracer.builder("Filtered - No Ultra Fast")
                .outputStyle(OutputStyle.DETAILED)
                .hideUltraFast(Duration.ofMillis(2))
                .build();
        simulateVariousOperations(tracer2);
        tracer2.end();
        
        Thread.sleep(1000);
        
        // Example 3: Show only slow operations
        System.out.println("\n3️⃣ Show Only Slow Operations (>= 100ms)");
        System.out.println("----------------------------------------");
        Tracer tracer3 = Tracer.builder("Slow Operations Only")
                .outputStyle(OutputStyle.DETAILED)
                .showSlowOnly(Duration.ofMillis(100))
                .build();
        simulateVariousOperations(tracer3);
        tracer3.end();
        
        Thread.sleep(1000);
        
        // Example 4: Group similar operations
        System.out.println("\n4️⃣ Group Similar Operations (±10ms threshold)");
        System.out.println("----------------------------------------------");
        Tracer tracer4 = Tracer.builder("Grouped Similar")
                .outputStyle(OutputStyle.DETAILED)
                .groupSimilar(Duration.ofMillis(10))
                .build();
        simulateVariousOperations(tracer4);
        tracer4.end();
        
        Thread.sleep(1000);
        
        // Example 5: Combined smart filtering
        System.out.println("\n5️⃣ Combined Smart Filtering");
        System.out.println("----------------------------");
        Tracer tracer5 = Tracer.builder("Smart Filtered")
                .outputStyle(OutputStyle.DETAILED)
                .smartFilter(
                    Duration.ofMillis(50),  // Show slow >= 50ms
                    Duration.ofMillis(2),   // Hide ultra fast < 2ms
                    Duration.ofMillis(15))  // Group similar ±15ms
                .build();
        simulateVariousOperations(tracer5);
        tracer5.end();
    }
}
