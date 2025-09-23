//go:build ignore
// +build ignore

package main

import (
	"time"

	tracing "github.com/LeDuyViet/quicktrace/go"
)

func main() {
	// Advanced usage với smart filtering
	tracer := tracing.NewSimpleTracer("Advanced Example",
		tracing.WithOutputStyle(tracing.StyleDetailed),
		tracing.WithHideUltraFast(1*time.Millisecond),
		tracing.WithShowSlowOnly(10*time.Millisecond),
		tracing.WithGroupSimilar(5*time.Millisecond),
	)

	// Simulate database operations
	time.Sleep(100 * time.Millisecond)
	tracer.Span("Connect to database")

	time.Sleep(45 * time.Millisecond)
	tracer.Span("Execute query 1")

	time.Sleep(50 * time.Millisecond) // Similar to query 1
	tracer.Span("Execute query 2")

	time.Sleep(5 * time.Millisecond)
	tracer.Span("Cache result")

	time.Sleep(500 * time.Microsecond) // Will be hidden
	tracer.Span("Ultra fast operation")

	time.Sleep(200 * time.Millisecond)
	tracer.Span("Process business logic")

	time.Sleep(30 * time.Millisecond)
	tracer.Span("Send notification")

	tracer.End()
}
