package com.leduy.quicktrace.examples;

import com.leduy.quicktrace.OutputStyle;
import com.leduy.quicktrace.Tracer;

/**
 * Quick demo để test JSON output và Colorful style
 */
public class QuickDemo {
    
    public static void main(String[] args) throws InterruptedException {
        OutputStyle style = args.length > 0 ? 
            OutputStyle.valueOf(args[0].toUpperCase()) : OutputStyle.JSON;
            
        System.out.println("🎯 QuickTrace Java Demo - " + style + " Style");
        System.out.println("===============================================");
        
        Tracer tracer = Tracer.builder("Demo Application")
                .outputStyle(style)
                .build();
        
        tracer.span("Initialize system");
        Thread.sleep(25);
        
        tracer.span("Connect to database");
        Thread.sleep(75);
        
        tracer.span("Load user preferences");
        Thread.sleep(45);
        
        tracer.span("Process request");
        Thread.sleep(120);
        
        tracer.span("Generate response");
        Thread.sleep(30);
        
        tracer.end();
    }
}
