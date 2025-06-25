//go:build ignore
// +build ignore

package main

import (
	"encoding/json"
	"fmt"
	"math/rand"
	"net/http"
	"time"

	tracing "github.com/LeDuyViet/quicktrace/go"
)

// Simulate different types of operations with realistic timing
func simulateDatabase(tracer *tracing.Tracer, query string) map[string]interface{} {
	tracer.Span("Database: " + query)

	// Simulate database query time (realistic variability)
	baseTime := 50 + rand.Intn(100) // 50-150ms
	time.Sleep(time.Duration(baseTime) * time.Millisecond)

	return map[string]interface{}{
		"query":   query,
		"results": rand.Intn(100),
		"time":    baseTime,
	}
}

func simulateCache(tracer *tracing.Tracer, key string) bool {
	tracer.Span("Cache lookup: " + key)

	// Cache operations are usually very fast
	time.Sleep(time.Duration(1+rand.Intn(5)) * time.Millisecond)

	// 70% cache hit rate
	return rand.Float32() < 0.7
}

func simulateExternalAPI(tracer *tracing.Tracer, service string) map[string]interface{} {
	tracer.Span("External API: " + service)

	// External APIs can be slow and variable
	baseTime := 200 + rand.Intn(800) // 200ms-1s
	time.Sleep(time.Duration(baseTime) * time.Millisecond)

	return map[string]interface{}{
		"service": service,
		"status":  "success",
		"latency": baseTime,
	}
}

func simulateBusinessLogic(tracer *tracing.Tracer, complexity string) {
	tracer.Span("Business logic: " + complexity)

	var duration int
	switch complexity {
	case "simple":
		duration = 5 + rand.Intn(15) // 5-20ms
	case "medium":
		duration = 20 + rand.Intn(50) // 20-70ms
	case "complex":
		duration = 100 + rand.Intn(200) // 100-300ms
	}

	time.Sleep(time.Duration(duration) * time.Millisecond)
}

// HTTP Handlers with tracing
func userProfileHandler(w http.ResponseWriter, r *http.Request) {
	tracer := tracing.NewSimpleTracer("GET /api/user/profile",
		tracing.WithOutputStyle(tracing.StyleDetailed),
		tracing.WithHideUltraFast(2*time.Millisecond))

	userID := r.URL.Query().Get("id")
	if userID == "" {
		userID = "12345"
	}

	// Check cache first
	cacheHit := simulateCache(tracer, "user:"+userID)

	var userData map[string]interface{}
	if !cacheHit {
		// Cache miss - query database
		userData = simulateDatabase(tracer, "SELECT * FROM users WHERE id = "+userID)

		// Cache the result
		tracer.Span("Cache store")
		time.Sleep(2 * time.Millisecond)
	} else {
		tracer.Span("Cache hit")
		time.Sleep(1 * time.Millisecond)
		userData = map[string]interface{}{
			"id":     userID,
			"name":   "John Doe",
			"cached": true,
		}
	}

	// Process business logic
	simulateBusinessLogic(tracer, "medium")

	// Enrich with additional data
	enrichData := simulateExternalAPI(tracer, "user-enrichment-service")

	// Final response preparation
	tracer.Span("Response serialization")
	time.Sleep(3 * time.Millisecond)

	response := map[string]interface{}{
		"user":       userData,
		"enrichment": enrichData,
		"timestamp":  time.Now().Unix(),
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)

	tracer.End()
}

func analyticsHandler(w http.ResponseWriter, r *http.Request) {
	tracer := tracing.NewSimpleTracer("POST /api/analytics",
		tracing.WithOutputStyle(tracing.StyleColorful),
		tracing.WithShowSlowOnly(50*time.Millisecond),
		tracing.WithGroupSimilar(20*time.Millisecond))

	// Validate request
	tracer.Span("Request validation")
	time.Sleep(5 * time.Millisecond)

	// Multiple database queries for analytics
	for i := 1; i <= 3; i++ {
		query := fmt.Sprintf("analytics_query_%d", i)
		simulateDatabase(tracer, query)
	}

	// Complex data processing
	simulateBusinessLogic(tracer, "complex")

	// Generate multiple reports
	for i := 1; i <= 4; i++ {
		tracer.Span(fmt.Sprintf("Generate report %d", i))
		time.Sleep(time.Duration(30+rand.Intn(40)) * time.Millisecond)
	}

	// Store results
	simulateDatabase(tracer, "INSERT INTO analytics_results")

	response := map[string]interface{}{
		"status":            "completed",
		"reports_generated": 4,
		"timestamp":         time.Now().Unix(),
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)

	tracer.End()
}

func healthCheckHandler(w http.ResponseWriter, r *http.Request) {
	tracer := tracing.NewSimpleTracer("GET /health",
		tracing.WithOutputStyle(tracing.StyleMinimal),
		tracing.WithMinTotalDuration(10*time.Millisecond)) // Only show if > 10ms

	// Quick database ping
	tracer.Span("Database ping")
	time.Sleep(time.Duration(2+rand.Intn(8)) * time.Millisecond)

	// Quick cache ping
	tracer.Span("Cache ping")
	time.Sleep(time.Duration(1+rand.Intn(3)) * time.Millisecond)

	// External service check
	tracer.Span("External service check")
	time.Sleep(time.Duration(5+rand.Intn(15)) * time.Millisecond)

	response := map[string]interface{}{
		"status":    "healthy",
		"timestamp": time.Now().Unix(),
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)

	tracer.End()
}

func main() {
	fmt.Println("🌐 Real-World HTTP API Server with QuickTrace")
	fmt.Println("=============================================")

	// Seed random for consistent demo
	rand.Seed(time.Now().UnixNano())

	// Setup routes
	http.HandleFunc("/api/user/profile", userProfileHandler)
	http.HandleFunc("/api/analytics", analyticsHandler)
	http.HandleFunc("/health", healthCheckHandler)

	// Demo mode - simulate requests instead of starting server
	fmt.Println("\n🎬 Demo Mode - Simulating API Requests:")
	fmt.Println("======================================")

	// Simulate various API calls
	fmt.Println("\n1️⃣ User Profile Request (Medium complexity)")
	req1, _ := http.NewRequest("GET", "/api/user/profile?id=12345", nil)
	userProfileHandler(nil, req1)

	time.Sleep(1 * time.Second)

	fmt.Println("\n2️⃣ Analytics Request (High complexity)")
	req2, _ := http.NewRequest("POST", "/api/analytics", nil)
	analyticsHandler(nil, req2)

	time.Sleep(1 * time.Second)

	fmt.Println("\n3️⃣ Health Check (Low complexity)")
	req3, _ := http.NewRequest("GET", "/health", nil)
	healthCheckHandler(nil, req3)

	time.Sleep(1 * time.Second)

	fmt.Println("\n4️⃣ Multiple Quick Health Checks")
	for i := 1; i <= 3; i++ {
		fmt.Printf("\nHealth check #%d:\n", i)
		req, _ := http.NewRequest("GET", "/health", nil)
		healthCheckHandler(nil, req)
		time.Sleep(500 * time.Millisecond)
	}

	fmt.Println("\n✅ Demo completed!")
	fmt.Println("\n💡 In a real server, uncomment the lines below:")
	fmt.Println("   // fmt.Println(\"Server starting on :8080\")")
	fmt.Println("   // log.Fatal(http.ListenAndServe(\":8080\", nil))")

	// Uncomment to run as real server
	// fmt.Println("🚀 Server starting on :8080")
	// log.Fatal(http.ListenAndServe(":8080", nil))
}
