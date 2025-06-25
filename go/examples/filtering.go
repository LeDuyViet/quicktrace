//go:build ignore
// +build ignore

package main

import (
	"fmt"
	"time"

	tracing "github.com/LeDuyViet/quicktrace/go"
)

func simulateVariousOperations(tracer *tracing.Tracer) {
	// Ultra fast operations
	tracer.Span("Ultra fast operation 1")
	time.Sleep(500 * time.Microsecond)

	tracer.Span("Ultra fast operation 2")
	time.Sleep(800 * time.Microsecond)

	// Fast operations
	tracer.Span("Fast validation")
	time.Sleep(5 * time.Millisecond)

	tracer.Span("Quick lookup")
	time.Sleep(8 * time.Millisecond)

	// Medium operations
	tracer.Span("Medium processing")
	time.Sleep(45 * time.Millisecond)

	tracer.Span("Similar processing")
	time.Sleep(48 * time.Millisecond) // Similar to above

	tracer.Span("Another similar task")
	time.Sleep(44 * time.Millisecond) // Also similar

	// Slow operations
	tracer.Span("Slow database query")
	time.Sleep(150 * time.Millisecond)

	tracer.Span("Complex computation")
	time.Sleep(200 * time.Millisecond)

	// Very slow operation
	tracer.Span("Very slow external API call")
	time.Sleep(800 * time.Millisecond)
}

func main() {
	fmt.Println("🎯 Smart Filtering Examples")
	fmt.Println("===========================")

	// Example 1: No filtering (show all)
	fmt.Println("\n1️⃣ No Filtering (Show All Operations)")
	fmt.Println("-------------------------------------")
	tracer1 := tracing.NewSimpleTracer("Complete Trace",
		tracing.WithOutputStyle(tracing.StyleDetailed))
	simulateVariousOperations(tracer1)
	tracer1.End()

	time.Sleep(1 * time.Second)

	// Example 2: Hide ultra fast operations
	fmt.Println("\n2️⃣ Hide Ultra Fast Operations (< 2ms)")
	fmt.Println("--------------------------------------")
	tracer2 := tracing.NewSimpleTracer("Filtered - No Ultra Fast",
		tracing.WithOutputStyle(tracing.StyleDetailed),
		tracing.WithHideUltraFast(2*time.Millisecond))
	simulateVariousOperations(tracer2)
	tracer2.End()

	time.Sleep(1 * time.Second)

	// Example 3: Show only slow operations
	fmt.Println("\n3️⃣ Show Only Slow Operations (>= 100ms)")
	fmt.Println("----------------------------------------")
	tracer3 := tracing.NewSimpleTracer("Slow Operations Only",
		tracing.WithOutputStyle(tracing.StyleDetailed),
		tracing.WithShowSlowOnly(100*time.Millisecond))
	simulateVariousOperations(tracer3)
	tracer3.End()

	time.Sleep(1 * time.Second)

	// Example 4: Group similar operations
	fmt.Println("\n4️⃣ Group Similar Operations (±10ms threshold)")
	fmt.Println("----------------------------------------------")
	tracer4 := tracing.NewSimpleTracer("Grouped Similar",
		tracing.WithOutputStyle(tracing.StyleDetailed),
		tracing.WithGroupSimilar(10*time.Millisecond))
	simulateVariousOperations(tracer4)
	tracer4.End()

	time.Sleep(1 * time.Second)

	// Example 5: Combined smart filtering
	fmt.Println("\n5️⃣ Combined Smart Filtering")
	fmt.Println("----------------------------")
	tracer5 := tracing.NewSimpleTracer("Smart Filtered",
		tracing.WithOutputStyle(tracing.StyleDetailed),
		tracing.WithSmartFilter(
			50*time.Millisecond,  // Show slow >= 50ms
			2*time.Millisecond,   // Hide ultra fast < 2ms
			15*time.Millisecond)) // Group similar ±15ms
	simulateVariousOperations(tracer5)
	tracer5.End()
}
