using QuickTrace;

namespace QuickTrace.Examples;

public static class AdvancedExample
{
    public static async Task Run()
    {
        Console.WriteLine("⚙️ Advanced Example");
        Console.WriteLine("===================");
        Console.WriteLine();

        // Advanced usage với smart filtering
        var tracer = Tracer.NewSimpleTracer("Advanced Example",
            TracerOptions.WithOutputStyle(OutputStyle.Detailed),
            TracerOptions.WithHideUltraFast(TimeSpan.FromMilliseconds(1)),
            TracerOptions.WithShowSlowOnly(TimeSpan.FromMilliseconds(10)),
            TracerOptions.WithGroupSimilar(TimeSpan.FromMilliseconds(5))
        );

        // Simulate database operations
        await Task.Delay(100);
        tracer.Span("Connect to database");

        await Task.Delay(45);
        tracer.Span("Execute query 1");

        await Task.Delay(50); // Similar to query 1
        tracer.Span("Execute query 2");

        await Task.Delay(5);
        tracer.Span("Cache result");

        await Task.Delay(TimeSpan.FromMicroseconds(500)); // Will be hidden
        tracer.Span("Ultra fast operation");

        await Task.Delay(200);
        tracer.Span("Process business logic");

        await Task.Delay(30);
        tracer.Span("Send notification");

        tracer.End();
    }
}
