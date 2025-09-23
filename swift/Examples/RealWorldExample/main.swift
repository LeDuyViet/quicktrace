import Foundation
import QuickTrace

// Simulate different types of operations with realistic timing
func simulateDatabase(_ tracer: QuickTrace, query: String) -> [String: Any] {
    tracer.span("Database: \(query)")
    
    // Simulate database query time (realistic variability)
    let baseTime = 0.050 + Double.random(in: 0...0.100) // 50-150ms
    Thread.sleep(forTimeInterval: baseTime)
    
    return [
        "query": query,
        "results": Int.random(in: 0...100),
        "time": baseTime * 1000 // Convert to ms for display
    ]
}

func simulateCache(_ tracer: QuickTrace, key: String) -> Bool {
    tracer.span("Cache lookup: \(key)")
    
    // Cache operations are usually very fast
    let cacheTime = 0.001 + Double.random(in: 0...0.004) // 1-5ms
    Thread.sleep(forTimeInterval: cacheTime)
    
    // 70% cache hit rate
    return Double.random(in: 0...1) < 0.7
}

func simulateExternalAPI(_ tracer: QuickTrace, service: String) -> [String: Any] {
    tracer.span("External API: \(service)")
    
    // External APIs can be slow and variable
    let baseTime = 0.200 + Double.random(in: 0...0.800) // 200ms-1s
    Thread.sleep(forTimeInterval: baseTime)
    
    return [
        "service": service,
        "status": "success",
        "latency": baseTime * 1000 // Convert to ms for display
    ]
}

func simulateBusinessLogic(_ tracer: QuickTrace, complexity: String) {
    tracer.span("Business logic: \(complexity)")
    
    let duration: TimeInterval
    switch complexity {
    case "simple":
        duration = 0.005 + Double.random(in: 0...0.015) // 5-20ms
    case "medium":
        duration = 0.020 + Double.random(in: 0...0.050) // 20-70ms
    case "complex":
        duration = 0.100 + Double.random(in: 0...0.200) // 100-300ms
    default:
        duration = 0.010
    }
    
    Thread.sleep(forTimeInterval: duration)
}

// HTTP Handler simulations
func userProfileHandler(userID: String = "12345") {
    let tracer = QuickTrace(name: "GET /api/user/profile")
        .with(style: .detailed)
        .with(option: .hideUltraFast(0.002)) // Hide < 2ms
    
    // Check cache first
    let cacheHit = simulateCache(tracer, key: "user:\(userID)")
    
    var userData: [String: Any]
    if !cacheHit {
        // Cache miss - query database
        userData = simulateDatabase(tracer, query: "SELECT * FROM users WHERE id = \(userID)")
        
        // Cache the result
        tracer.span("Cache store")
        Thread.sleep(forTimeInterval: 0.002) // 2ms
    } else {
        tracer.span("Cache hit")
        Thread.sleep(forTimeInterval: 0.001) // 1ms
        userData = [
            "id": userID,
            "name": "John Doe",
            "cached": true
        ]
    }
    
    // Process business logic
    simulateBusinessLogic(tracer, complexity: "medium")
    
    // Enrich with additional data
    let enrichData = simulateExternalAPI(tracer, service: "user-enrichment-service")
    
    // Final response preparation
    tracer.span("Response serialization")
    Thread.sleep(forTimeInterval: 0.003) // 3ms
    
    let response = [
        "user": userData,
        "enrichment": enrichData,
        "timestamp": Int(Date().timeIntervalSince1970)
    ] as [String : Any]
    
    tracer.end()
}

func analyticsHandler() {
    let tracer = QuickTrace(name: "POST /api/analytics")
        .with(style: .colorful)
        .with(option: .showSlowOnly(0.050)) // Show >= 50ms
        .with(option: .groupSimilar(0.020)) // Group similar ±20ms
    
    // Validate request
    tracer.span("Request validation")
    Thread.sleep(forTimeInterval: 0.005) // 5ms
    
    // Multiple database queries for analytics
    for i in 1...3 {
        let _ = simulateDatabase(tracer, query: "analytics_query_\(i)")
    }
    
    // Complex data processing
    simulateBusinessLogic(tracer, complexity: "complex")
    
    // Generate multiple reports
    for i in 1...4 {
        tracer.span("Generate report \(i)")
        let reportTime = 0.030 + Double.random(in: 0...0.040) // 30-70ms
        Thread.sleep(forTimeInterval: reportTime)
    }
    
    // Store results
    let _ = simulateDatabase(tracer, query: "INSERT INTO analytics_results")
    
    let response = [
        "status": "completed",
        "reports_generated": 4,
        "timestamp": Int(Date().timeIntervalSince1970)
    ]
    
    tracer.end()
}

func healthCheckHandler() {
    let tracer = QuickTrace(name: "GET /health")
        .with(style: .minimal)
        .with(option: .minTotalDuration(0.010)) // Only show if > 10ms
    
    // Quick database ping
    tracer.span("Database ping")
    let dbPing = 0.002 + Double.random(in: 0...0.008) // 2-10ms
    Thread.sleep(forTimeInterval: dbPing)
    
    // Quick cache ping
    tracer.span("Cache ping")
    let cachePing = 0.001 + Double.random(in: 0...0.003) // 1-4ms
    Thread.sleep(forTimeInterval: cachePing)
    
    // External service check
    tracer.span("External service check")
    let serviceCheck = 0.005 + Double.random(in: 0...0.015) // 5-20ms
    Thread.sleep(forTimeInterval: serviceCheck)
    
    let response = [
        "status": "healthy",
        "timestamp": Int(Date().timeIntervalSince1970)
    ]
    
    tracer.end()
}

func main() {
    print("🌐 Real-World HTTP API Server with QuickTrace")
    print("=============================================")
    
    // Seed random for more variety in demo
    srand48(Int(Date().timeIntervalSince1970))
    
    // Demo mode - simulate requests
    print("\n🎬 Demo Mode - Simulating API Requests:")
    print("======================================")
    
    // Simulate various API calls
    print("\n1️⃣ User Profile Request (Medium complexity)")
    userProfileHandler(userID: "12345")
    
    Thread.sleep(forTimeInterval: 1.0)
    
    print("\n2️⃣ Analytics Request (High complexity)")
    analyticsHandler()
    
    Thread.sleep(forTimeInterval: 1.0)
    
    print("\n3️⃣ Health Check (Low complexity)")
    healthCheckHandler()
    
    Thread.sleep(forTimeInterval: 1.0)
    
    print("\n4️⃣ Multiple Quick Health Checks")
    for i in 1...3 {
        print("\nHealth check #\(i):")
        healthCheckHandler()
        Thread.sleep(forTimeInterval: 0.5)
    }
    
    print("\n✅ Demo completed!")
    print("\n💡 In a real server, you would integrate QuickTrace with:")
    print("   • HTTP request handlers")
    print("   • Database connection pools")
    print("   • Background job processors")
    print("   • API gateway middleware")
}

main()

