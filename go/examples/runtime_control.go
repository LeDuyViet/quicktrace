//go:build ignore
// +build ignore

package main

import (
	"fmt"
	"time"

	tracing "github.com/LeDuyViet/quicktrace/go"
)

func doSomeWork(tracer *tracing.Tracer, label string) {
	time.Sleep(20 * time.Millisecond)
	tracer.Span("Step 1: " + label)

	time.Sleep(30 * time.Millisecond)
	tracer.Span("Step 2: " + label)

	time.Sleep(15 * time.Millisecond)
	tracer.Span("Step 3: " + label)
}

func main() {
	fmt.Println("🔧 Runtime Control Examples")
	fmt.Println("============================")

	// Example 1: Enable/Disable tracing
	fmt.Println("\n1️⃣ Enable/Disable Tracing")
	fmt.Println("--------------------------")

	tracer1 := tracing.NewSimpleTracer("Runtime Control Demo")

	fmt.Println("✅ Tracing enabled:")
	doSomeWork(tracer1, "Enabled")
	tracer1.End()

	fmt.Println("\n❌ Tracing disabled:")
	tracer1.SetEnabled(false)
	doSomeWork(tracer1, "Disabled") // Won't collect data
	tracer1.End()                   // Won't print anything

	// Example 2: Silent mode
	fmt.Println("\n2️⃣ Silent Mode (Data Collection Only)")
	fmt.Println("--------------------------------------")

	tracer2 := tracing.NewSimpleTracer("Silent Mode Demo",
		tracing.WithOutputStyle(tracing.StyleColorful))

	tracer2.SetSilent(true) // Collect data but don't print

	fmt.Println("🔇 Silent mode - collecting data...")
	doSomeWork(tracer2, "Silent")
	tracer2.End() // Won't print

	// Access collected data programmatically
	measurements := tracer2.GetMeasurements()
	totalDuration := tracer2.GetTotalDuration()

	fmt.Printf("📊 Collected %d measurements\n", len(measurements))
	fmt.Printf("⏱️  Total duration: %v\n", totalDuration)

	for i, m := range measurements[:len(measurements)-1] { // Exclude "End"
		fmt.Printf("   %d. %s: %v\n", i+1, m.Statement, m.Duration)
	}

	// Example 3: Dynamic style changes
	fmt.Println("\n3️⃣ Dynamic Style Changes")
	fmt.Println("-------------------------")

	tracer3 := tracing.NewSimpleTracer("Style Change Demo")

	fmt.Println("🎨 Starting with default style:")
	doSomeWork(tracer3, "Default Style")
	tracer3.End()

	// Change to colorful style
	tracer3 = tracing.NewSimpleTracer("Style Change Demo",
		tracing.WithOutputStyle(tracing.StyleColorful))

	fmt.Println("\n🌈 Changed to colorful style:")
	doSomeWork(tracer3, "Colorful Style")
	tracer3.End()

	// Change to minimal style
	tracer3 = tracing.NewSimpleTracer("Style Change Demo")
	tracer3.SetOutputStyle(tracing.StyleMinimal)

	fmt.Println("\n📝 Changed to minimal style:")
	doSomeWork(tracer3, "Minimal Style")
	tracer3.End()

	// Example 4: Custom print conditions
	fmt.Println("\n4️⃣ Custom Print Conditions")
	fmt.Println("---------------------------")

	tracer4 := tracing.NewSimpleTracer("Conditional Printing")

	// Set custom condition: only print if total > 50ms
	tracer4.SetPrintCondition(func(t *tracing.Tracer) bool {
		return t.GetTotalDuration() > 50*time.Millisecond
	})

	fmt.Println("⚡ Fast execution (won't print):")
	time.Sleep(10 * time.Millisecond)
	tracer4.Span("Quick task")
	tracer4.End() // Won't print because < 50ms

	fmt.Println("🐌 Slow execution (will print):")
	tracer5 := tracing.NewSimpleTracer("Conditional Printing")
	tracer5.SetPrintCondition(func(t *tracing.Tracer) bool {
		return t.GetTotalDuration() > 50*time.Millisecond
	})

	doSomeWork(tracer5, "Slow enough") // Will print because > 50ms
	tracer5.End()

	// Example 5: Inspection without printing
	fmt.Println("\n5️⃣ Data Inspection")
	fmt.Println("-------------------")

	tracer6 := tracing.NewSimpleTracer("Data Inspection",
		tracing.WithSilent(true)) // Silent to avoid printing

	time.Sleep(25 * time.Millisecond)
	tracer6.Span("Database connection")

	time.Sleep(75 * time.Millisecond)
	tracer6.Span("Query execution")

	time.Sleep(40 * time.Millisecond)
	tracer6.Span("Result processing")

	tracer6.End()

	// Inspect collected data
	fmt.Printf("📈 Total measurements: %d\n", len(tracer6.GetMeasurements()))
	fmt.Printf("⏱️  Total execution time: %v\n", tracer6.GetTotalDuration())
	fmt.Printf("🔧 Tracer enabled: %v\n", tracer6.IsEnabled())
	fmt.Printf("🔇 Tracer silent: %v\n", tracer6.IsSilent())
	fmt.Printf("🎨 Output style: %d\n", tracer6.GetOutputStyle())
}
