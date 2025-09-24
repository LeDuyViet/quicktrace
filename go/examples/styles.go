//go:build ignore
// +build ignore

package main

import (
	"fmt"
	"time"

	tracing "github.com/LeDuyViet/quicktrace/go"
)

func simulateWork(tracer *tracing.Tracer) {
	time.Sleep(25 * time.Millisecond)
	tracer.Span("Load configuration")

	time.Sleep(300 * time.Millisecond)
	tracer.Span("Connect to database")

	time.Sleep(1000 * time.Millisecond)
	tracer.Span("Execute complex query")

	time.Sleep(100 * time.Millisecond)
	tracer.Span("Process results")

	time.Sleep(150 * time.Millisecond)
	tracer.Span("Cache data")

	time.Sleep(1000 * time.Millisecond)
	tracer.Span("Execute complex query 2")

	time.Sleep(50 * time.Millisecond)
	tracer.Span("Generate response")
}

func main() {
	styles := []struct {
		name  string
		style tracing.OutputStyle
	}{
		{"Default", tracing.StyleDefault},
		{"Colorful", tracing.StyleColorful},
		{"Minimal", tracing.StyleMinimal},
		{"Detailed", tracing.StyleDetailed},
		{"Table", tracing.StyleTable},
		{"JSON", tracing.StyleJSON},
	}

	for _, s := range styles {
		fmt.Printf("\n%s=================== %s STYLE ===================%s\n",
			"\033[1;36m", s.name, "\033[0m")

		tracer := tracing.NewSimpleTracer("API Processing - "+s.name+" Style",
			tracing.WithOutputStyle(s.style))

		simulateWork(tracer)
		tracer.End()

		time.Sleep(500 * time.Millisecond) // Brief pause between styles
	}
}
