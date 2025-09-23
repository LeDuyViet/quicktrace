import Foundation
import QuickTrace

func main() {
    // Advanced usage với smart filtering
    let tracer = QuickTrace(name: "Advanced Example")
        .with(style: .detailed)
        .with(option: .hideUltraFast(0.001)) // Hide < 1ms
        .with(option: .showSlowOnly(0.01))   // Show >= 10ms
        .with(option: .groupSimilar(0.005))  // Group similar ±5ms
    
    // Simulate database operations
    Thread.sleep(forTimeInterval: 0.100) // 100ms
    tracer.span("Connect to database")

    Thread.sleep(forTimeInterval: 0.045) // 45ms
    tracer.span("Execute query 1")

    Thread.sleep(forTimeInterval: 0.050) // 50ms - Similar to query 1
    tracer.span("Execute query 2")

    Thread.sleep(forTimeInterval: 0.005) // 5ms
    tracer.span("Cache result")

    Thread.sleep(forTimeInterval: 0.0005) // 0.5ms - Will be hidden
    tracer.span("Ultra fast operation")

    Thread.sleep(forTimeInterval: 0.200) // 200ms
    tracer.span("Process business logic")

    Thread.sleep(forTimeInterval: 0.030) // 30ms
    tracer.span("Send notification")
    
    tracer.end()
}

main()

