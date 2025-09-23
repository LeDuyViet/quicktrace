import Foundation
import QuickTrace

func simulateVariousOperations(_ tracer: QuickTrace) {
    // Ultra fast operations
    Thread.sleep(forTimeInterval: 0.0005) // 0.5ms
    tracer.span("Ultra fast operation 1")

    Thread.sleep(forTimeInterval: 0.0008) // 0.8ms
    tracer.span("Ultra fast operation 2")

    // Fast operations
    Thread.sleep(forTimeInterval: 0.005) // 5ms
    tracer.span("Fast validation")

    Thread.sleep(forTimeInterval: 0.008) // 8ms
    tracer.span("Quick lookup")

    // Medium operations
    Thread.sleep(forTimeInterval: 0.045) // 45ms
    tracer.span("Medium processing")

    Thread.sleep(forTimeInterval: 0.048) // 48ms - Similar to above
    tracer.span("Similar processing")

    Thread.sleep(forTimeInterval: 0.044) // 44ms - Also similar
    tracer.span("Another similar task")

    // Slow operations
    Thread.sleep(forTimeInterval: 0.150) // 150ms
    tracer.span("Slow database query")

    Thread.sleep(forTimeInterval: 0.200) // 200ms
    tracer.span("Complex computation")

    // Very slow operation
    Thread.sleep(forTimeInterval: 0.800) // 800ms
    tracer.span("Very slow external API call")
}

func main() {
    print("🎯 Smart Filtering Examples")
    print("===========================")
    
    // Example 1: No filtering (show all)
    print("\n1️⃣ No Filtering (Show All Operations)")
    print("-------------------------------------")
    let tracer1 = QuickTrace(name: "Complete Trace")
        .with(style: .detailed)
    simulateVariousOperations(tracer1)
    tracer1.end()
    
    Thread.sleep(forTimeInterval: 1.0)
    
    // Example 2: Hide ultra fast operations
    print("\n2️⃣ Hide Ultra Fast Operations (< 2ms)")
    print("--------------------------------------")
    let tracer2 = QuickTrace(name: "Filtered - No Ultra Fast")
        .with(style: .detailed)
        .with(option: .hideUltraFast(0.002)) // < 2ms
    simulateVariousOperations(tracer2)
    tracer2.end()
    
    Thread.sleep(forTimeInterval: 1.0)
    
    // Example 3: Show only slow operations
    print("\n3️⃣ Show Only Slow Operations (>= 100ms)")
    print("----------------------------------------")
    let tracer3 = QuickTrace(name: "Slow Operations Only")
        .with(style: .detailed)
        .with(option: .showSlowOnly(0.100)) // >= 100ms
    simulateVariousOperations(tracer3)
    tracer3.end()
    
    Thread.sleep(forTimeInterval: 1.0)
    
    // Example 4: Group similar operations
    print("\n4️⃣ Group Similar Operations (±10ms threshold)")
    print("----------------------------------------------")
    let tracer4 = QuickTrace(name: "Grouped Similar")
        .with(style: .detailed)
        .with(option: .groupSimilar(0.010)) // ±10ms
    simulateVariousOperations(tracer4)
    tracer4.end()
    
    Thread.sleep(forTimeInterval: 1.0)
    
    // Example 5: Combined smart filtering
    print("\n5️⃣ Combined Smart Filtering")
    print("----------------------------")
    let smartFilter = SmartFilter(
        slowThreshold: 0.050,    // Show slow >= 50ms
        ultraFastThreshold: 0.002, // Hide ultra fast < 2ms
        similarThreshold: 0.015    // Group similar ±15ms
    )
    let tracer5 = QuickTrace(name: "Smart Filtered")
        .with(style: .detailed)
        .with(smartFilter: smartFilter)
    simulateVariousOperations(tracer5)
    tracer5.end()
}

main()

