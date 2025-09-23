using QuickTrace;

namespace QuickTrace.Examples;

public static class FilteringExample
{
    public static async Task Run()
    {
        Console.WriteLine("🎯 Smart Filtering Examples");
        Console.WriteLine("===========================");
        Console.WriteLine();

        // Example 1: No filtering (show all)
        Console.WriteLine("1️⃣ No Filtering (Show All Operations)");
        Console.WriteLine("-------------------------------------");
        var tracer1 = Tracer.NewSimpleTracer("Complete Trace",
            TracerOptions.WithOutputStyle(OutputStyle.Detailed));
        await SimulateVariousOperations(tracer1);
        tracer1.End();

        await Task.Delay(1000);

        // Example 2: Hide ultra fast operations
        Console.WriteLine("\n2️⃣ Hide Ultra Fast Operations (< 2ms)");
        Console.WriteLine("--------------------------------------");
        var tracer2 = Tracer.NewSimpleTracer("Filtered - No Ultra Fast",
            TracerOptions.WithOutputStyle(OutputStyle.Detailed),
            TracerOptions.WithHideUltraFast(TimeSpan.FromMilliseconds(2)));
        await SimulateVariousOperations(tracer2);
        tracer2.End();

        await Task.Delay(1000);

        // Example 3: Show only slow operations
        Console.WriteLine("\n3️⃣ Show Only Slow Operations (>= 100ms)");
        Console.WriteLine("----------------------------------------");
        var tracer3 = Tracer.NewSimpleTracer("Slow Operations Only",
            TracerOptions.WithOutputStyle(OutputStyle.Detailed),
            TracerOptions.WithShowSlowOnly(TimeSpan.FromMilliseconds(100)));
        await SimulateVariousOperations(tracer3);
        tracer3.End();

        await Task.Delay(1000);

        // Example 4: Group similar operations
        Console.WriteLine("\n4️⃣ Group Similar Operations (±10ms threshold)");
        Console.WriteLine("----------------------------------------------");
        var tracer4 = Tracer.NewSimpleTracer("Grouped Similar",
            TracerOptions.WithOutputStyle(OutputStyle.Detailed),
            TracerOptions.WithGroupSimilar(TimeSpan.FromMilliseconds(10)));
        await SimulateVariousOperations(tracer4);
        tracer4.End();

        await Task.Delay(1000);

        // Example 5: Combined smart filtering
        Console.WriteLine("\n5️⃣ Combined Smart Filtering");
        Console.WriteLine("----------------------------");
        var tracer5 = Tracer.NewSimpleTracer("Smart Filtered",
            TracerOptions.WithOutputStyle(OutputStyle.Detailed),
            TracerOptions.WithSmartFilter(
                TimeSpan.FromMilliseconds(50),  // Show slow >= 50ms
                TimeSpan.FromMilliseconds(2),   // Hide ultra fast < 2ms
                TimeSpan.FromMilliseconds(15))); // Group similar ±15ms
        await SimulateVariousOperations(tracer5);
        tracer5.End();
    }

    private static async Task SimulateVariousOperations(Tracer tracer)
    {
        // Ultra fast operations
        await Task.Delay(TimeSpan.FromMicroseconds(500));
        tracer.Span("Ultra fast operation 1");

        await Task.Delay(TimeSpan.FromMicroseconds(800));
        tracer.Span("Ultra fast operation 2");

        // Fast operations
        await Task.Delay(5);
        tracer.Span("Fast validation");

        await Task.Delay(8);
        tracer.Span("Quick lookup");

        // Medium operations
        await Task.Delay(45);
        tracer.Span("Medium processing");

        await Task.Delay(48); // Similar to above
        tracer.Span("Similar processing");

        await Task.Delay(44); // Also similar
        tracer.Span("Another similar task");

        // Slow operations
        await Task.Delay(150);
        tracer.Span("Slow database query");

        await Task.Delay(200);
        tracer.Span("Complex computation");

        // Very slow operation
        await Task.Delay(800);
        tracer.Span("Very slow external API call");
    }
}
