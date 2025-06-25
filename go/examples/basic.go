//go:build ignore
// +build ignore

package main

import (
	"time"

	tracing "github.com/LeDuyViet/quicktrace/go"
)

func main() {
	// Basic usage với default style
	tracer := tracing.NewSimpleTracer("Basic Example")

	tracer.Span("Initialize database")
	time.Sleep(30 * time.Millisecond)

	tracer.Span("Load user data")
	time.Sleep(50 * time.Millisecond)

	tracer.Span("Process data")
	time.Sleep(20 * time.Millisecond)

	tracer.Span("Generate response")
	time.Sleep(10 * time.Millisecond)

	tracer.End()
}
