package com.leduy.quicktrace.examples;

import com.leduy.quicktrace.Measurement;
import com.leduy.quicktrace.OutputStyle;
import com.leduy.quicktrace.Tracer;
import java.time.Duration;
import java.util.List;

/**
 * Runtime Control Examples
 */
public class RuntimeControlExample {
    
    private static void doSomeWork(Tracer tracer, String label) throws InterruptedException {
        tracer.span("Step 1: " + label);
        Thread.sleep(20);
        
        tracer.span("Step 2: " + label);
        Thread.sleep(30);
        
        tracer.span("Step 3: " + label);
        Thread.sleep(15);
    }
    
    public static void main(String[] args) throws InterruptedException {
        System.out.println("🔧 Runtime Control Examples");
        System.out.println("============================");
        
        // Example 1: Enable/Disable tracing
        System.out.println("\n1️⃣ Enable/Disable Tracing");
        System.out.println("--------------------------");
        
        Tracer tracer1 = Tracer.newSimpleTracer("Runtime Control Demo");
        
        System.out.println("✅ Tracing enabled:");
        doSomeWork(tracer1, "Enabled");
        tracer1.end();
        
        System.out.println("\n❌ Tracing disabled:");
        tracer1.setEnabled(false);
        doSomeWork(tracer1, "Disabled"); // Won't collect data
        tracer1.end(); // Won't print anything
        
        // Example 2: Silent mode
        System.out.println("\n2️⃣ Silent Mode (Data Collection Only)");
        System.out.println("--------------------------------------");
        
        Tracer tracer2 = Tracer.builder("Silent Mode Demo")
                .outputStyle(OutputStyle.COLORFUL)
                .build();
        
        tracer2.setSilent(true); // Collect data but don't print
        
        System.out.println("🔇 Silent mode - collecting data...");
        doSomeWork(tracer2, "Silent");
        tracer2.end(); // Won't print
        
        // Access collected data programmatically
        List<Measurement> measurements = tracer2.getMeasurements();
        Duration totalDuration = tracer2.getTotalDuration();
        
        System.out.printf("📊 Collected %d measurements\n", measurements.size());
        System.out.printf("⏱️  Total duration: %s\n", totalDuration);
        
        for (int i = 0; i < measurements.size() - 1; i++) { // Exclude "End"
            Measurement m = measurements.get(i);
            System.out.printf("   %d. %s: %s\n", i + 1, m.getStatement(), m.getDuration());
        }
        
        // Example 3: Dynamic style changes
        System.out.println("\n3️⃣ Dynamic Style Changes");
        System.out.println("-------------------------");
        
        Tracer tracer3 = Tracer.newSimpleTracer("Style Change Demo");
        
        System.out.println("🎨 Starting with default style:");
        doSomeWork(tracer3, "Default Style");
        tracer3.end();
        
        // Change to colorful style
        tracer3 = Tracer.builder("Style Change Demo")
                .outputStyle(OutputStyle.COLORFUL)
                .build();
        
        System.out.println("\n🌈 Changed to colorful style:");
        doSomeWork(tracer3, "Colorful Style");
        tracer3.end();
        
        // Change to minimal style
        tracer3 = Tracer.newSimpleTracer("Style Change Demo");
        tracer3.setOutputStyle(OutputStyle.MINIMAL);
        
        System.out.println("\n📝 Changed to minimal style:");
        doSomeWork(tracer3, "Minimal Style");
        tracer3.end();
        
        // Example 4: Custom print conditions
        System.out.println("\n4️⃣ Custom Print Conditions");
        System.out.println("---------------------------");
        
        Tracer tracer4 = Tracer.newSimpleTracer("Conditional Printing");
        
        // Set custom condition: only print if total > 50ms
        tracer4.setPrintCondition(t -> t.getTotalDuration().compareTo(Duration.ofMillis(50)) > 0);
        
        System.out.println("⚡ Fast execution (won't print):");
        tracer4.span("Quick task");
        Thread.sleep(10);
        tracer4.end(); // Won't print because < 50ms
        
        System.out.println("🐌 Slow execution (will print):");
        Tracer tracer5 = Tracer.newSimpleTracer("Conditional Printing");
        tracer5.setPrintCondition(t -> t.getTotalDuration().compareTo(Duration.ofMillis(50)) > 0);
        
        doSomeWork(tracer5, "Slow enough"); // Will print because > 50ms
        tracer5.end();
        
        // Example 5: Inspection without printing
        System.out.println("\n5️⃣ Data Inspection");
        System.out.println("-------------------");
        
        Tracer tracer6 = Tracer.builder("Data Inspection")
                .silent(true) // Silent to avoid printing
                .build();
        
        tracer6.span("Database connection");
        Thread.sleep(25);
        
        tracer6.span("Query execution");
        Thread.sleep(75);
        
        tracer6.span("Result processing");
        Thread.sleep(40);
        
        tracer6.end();
        
        // Inspect collected data
        System.out.printf("📈 Total measurements: %d\n", tracer6.getMeasurements().size());
        System.out.printf("⏱️  Total execution time: %s\n", tracer6.getTotalDuration());
        System.out.printf("🔧 Tracer enabled: %s\n", tracer6.isEnabled());
        System.out.printf("🔇 Tracer silent: %s\n", tracer6.isSilent());
        System.out.printf("🎨 Output style: %s\n", tracer6.getOutputStyle());
    }
}
