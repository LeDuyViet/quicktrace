import Foundation
import QuickTrace

func simulateWork(_ tracer: QuickTrace) {
    Thread.sleep(forTimeInterval: 0.025) // 25ms
    tracer.span("Load configuration")

    Thread.sleep(forTimeInterval: 0.075) // 75ms
    tracer.span("Connect to database")

    Thread.sleep(forTimeInterval: 0.120) // 120ms
    tracer.span("Execute complex query")

    Thread.sleep(forTimeInterval: 0.045) // 45ms
    tracer.span("Process results")

    Thread.sleep(forTimeInterval: 0.015) // 15ms
    tracer.span("Cache data")

    Thread.sleep(forTimeInterval: 0.008) // 8ms
    tracer.span("Generate response")
}

func main() {
    let styles: [(String, OutputStyle)] = [
        ("Default", .default),
        ("Colorful", .colorful),
        ("Minimal", .minimal),
        ("Detailed", .detailed),
        ("Table", .table),
        ("JSON", .json)
    ]
    
    for (name, style) in styles {
        print("\n\u{001B}[1;36m=================== \(name.uppercased()) STYLE ===================\u{001B}[0m")
        
        let tracer = QuickTrace(name: "API Processing - \(name) Style")
            .with(style: style)
        
        simulateWork(tracer)
        tracer.end()
        
        Thread.sleep(forTimeInterval: 0.5) // Brief pause between styles
    }
}

main()

