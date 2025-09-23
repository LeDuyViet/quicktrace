package com.leduy.quicktrace.examples;

import com.leduy.quicktrace.OutputStyle;
import com.leduy.quicktrace.Tracer;

/**
 * Basic usage với default style
 */
public class BasicExample {
    
    public static void main(String[] args) throws InterruptedException {
        // Basic usage với detailed style (tương tự Go version)
        Tracer tracer = Tracer.builder("Basic Example")
                .outputStyle(OutputStyle.DETAILED)
                .build();
        
        Thread.sleep(30);
        tracer.span("Initialize database");

        Thread.sleep(50);
        tracer.span("Load user data");

        Thread.sleep(20);
        tracer.span("Process data");

        Thread.sleep(10);
        tracer.span("Generate response");
        
        tracer.end();
    }
}
