package com.leduy.quicktrace.examples;

import com.leduy.quicktrace.ColorRules;
import com.leduy.quicktrace.OutputStyle;
import com.leduy.quicktrace.Tracer;

/**
 * Ví dụ về các style output khác nhau
 */
public class StylesExample {
    
    private static void simulateWork(Tracer tracer) throws InterruptedException {
        Thread.sleep(25);
        tracer.span("Load configuration");

        Thread.sleep(75);
        tracer.span("Connect to database");

        Thread.sleep(120);
        tracer.span("Execute complex query");

        Thread.sleep(45);
        tracer.span("Process results");

        Thread.sleep(15);
        tracer.span("Cache data");

        Thread.sleep(8);
        tracer.span("Generate response");
    }
    
    public static void main(String[] args) throws InterruptedException {
        OutputStyle[] styles = {
            OutputStyle.DEFAULT,
            OutputStyle.COLORFUL,
            OutputStyle.MINIMAL,
            OutputStyle.DETAILED,
            OutputStyle.TABLE,
            OutputStyle.JSON
        };
        
        String[] styleNames = {
            "Default",
            "Colorful", 
            "Minimal",
            "Detailed",
            "Table",
            "JSON"
        };
        
        for (int i = 0; i < styles.length; i++) {
            System.out.printf("\n%s=================== %s STYLE ===================%s\n",
                    ColorRules.colorizeWithStyle("", ColorRules.BRIGHT_CYAN, ColorRules.BOLD),
                    styleNames[i].toUpperCase(),
                    ColorRules.RESET);
            
            Tracer tracer = Tracer.builder("API Processing - " + styleNames[i] + " Style")
                    .outputStyle(styles[i])
                    .build();
            
            simulateWork(tracer);
            tracer.end();
            
            Thread.sleep(500); // Brief pause between styles
        }
    }
}
