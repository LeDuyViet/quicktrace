import Foundation
import QuickTrace

func doSomeWork(_ tracer: QuickTrace, label: String) {
    Thread.sleep(forTimeInterval: 0.020) // 20ms
    tracer.span("Step 1: \(label)")

    Thread.sleep(forTimeInterval: 0.030) // 30ms
    tracer.span("Step 2: \(label)")

    Thread.sleep(forTimeInterval: 0.015) // 15ms
    tracer.span("Step 3: \(label)")
}

func main() {
    print("🔧 Runtime Control Examples")
    print("============================")
    
    // Example 1: Enable/Disable tracing
    print("\n1️⃣ Enable/Disable Tracing")
    print("--------------------------")
    
    let tracer1 = QuickTrace(name: "Runtime Control Demo")
    
    print("✅ Tracing enabled:")
    doSomeWork(tracer1, label: "Enabled")
    tracer1.end()
    
    print("\n❌ Tracing disabled:")
    tracer1.setEnabled(false)
    doSomeWork(tracer1, label: "Disabled") // Won't collect data
    tracer1.end() // Won't print anything
    
    // Example 2: Silent mode
    print("\n2️⃣ Silent Mode (Data Collection Only)")
    print("--------------------------------------")
    
    let tracer2 = QuickTrace(name: "Silent Mode Demo")
        .with(style: .colorful)
    
    tracer2.setSilent(true) // Collect data but don't print
    
    print("🔇 Silent mode - collecting data...")
    doSomeWork(tracer2, label: "Silent")
    tracer2.end() // Won't print
    
    // Access collected data programmatically
    let measurements = tracer2.getMeasurements()
    let totalDuration = tracer2.getTotalDuration()
    
    print("📊 Collected \(measurements.count) measurements")
    print("⏱️  Total duration: \(String(format: "%.3f", totalDuration))s")
    
    for (i, measurement) in measurements.enumerated() {
        print("   \(i + 1). \(measurement.statement): \(String(format: "%.3f", measurement.duration))s")
    }
    
    // Example 3: Dynamic style changes
    print("\n3️⃣ Dynamic Style Changes")
    print("-------------------------")
    
    var tracer3 = QuickTrace(name: "Style Change Demo")
    
    print("🎨 Starting with default style:")
    doSomeWork(tracer3, label: "Default Style")
    tracer3.end()
    
    // Change to colorful style
    tracer3 = QuickTrace(name: "Style Change Demo")
        .with(style: .colorful)
    
    print("\n🌈 Changed to colorful style:")
    doSomeWork(tracer3, label: "Colorful Style")
    tracer3.end()
    
    // Change to minimal style
    tracer3 = QuickTrace(name: "Style Change Demo")
    tracer3.setOutputStyle(.minimal)
    
    print("\n📝 Changed to minimal style:")
    doSomeWork(tracer3, label: "Minimal Style")
    tracer3.end()
    
    // Example 4: Custom print conditions
    print("\n4️⃣ Custom Print Conditions")
    print("---------------------------")
    
    let tracer4 = QuickTrace(name: "Conditional Printing")
    
    // Set custom condition: only print if total > 50ms
    tracer4.setPrintCondition { tracer in
        return tracer.getTotalDuration() > 0.050 // 50ms
    }
    
    print("⚡ Fast execution (won't print):")
    Thread.sleep(forTimeInterval: 0.010) // 10ms
    tracer4.span("Quick task")
    tracer4.end() // Won't print because < 50ms
    
    print("🐌 Slow execution (will print):")
    let tracer5 = QuickTrace(name: "Conditional Printing")
    tracer5.setPrintCondition { tracer in
        return tracer.getTotalDuration() > 0.050 // 50ms
    }
    
    doSomeWork(tracer5, label: "Slow enough") // Will print because > 50ms
    tracer5.end()
    
    // Example 5: Inspection without printing
    print("\n5️⃣ Data Inspection")
    print("-------------------")
    
    let tracer6 = QuickTrace(name: "Data Inspection")
        .with(option: .silent(true)) // Silent to avoid printing
    
    Thread.sleep(forTimeInterval: 0.025) // 25ms
    tracer6.span("Database connection")

    Thread.sleep(forTimeInterval: 0.075) // 75ms
    tracer6.span("Query execution")

    Thread.sleep(forTimeInterval: 0.040) // 40ms
    tracer6.span("Result processing")
    
    tracer6.end()
    
    // Inspect collected data
    print("📈 Total measurements: \(tracer6.getAllMeasurements().count)")
    print("⏱️  Total execution time: \(String(format: "%.3f", tracer6.getTotalDuration()))s")
    print("🔧 Tracer enabled: \(tracer6.getEnabled())")
    print("🔇 Tracer silent: \(tracer6.getSilent())")
    print("🎨 Output style: \(tracer6.getOutputStyle())")
}

main()

