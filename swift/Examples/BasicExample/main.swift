import Foundation
import QuickTrace

func main() {
    // Basic usage với default style
    let tracer = QuickTrace(name: "Basic Example")
    
    Thread.sleep(forTimeInterval: 0.030) // 30ms
    tracer.span("Initialize database")

    Thread.sleep(forTimeInterval: 0.050) // 50ms
    tracer.span("Load user data")

    Thread.sleep(forTimeInterval: 0.020) // 20ms
    tracer.span("Process data")

    Thread.sleep(forTimeInterval: 0.010) // 10ms
    tracer.span("Generate response")
    
    tracer.end()
}

main()

