using QuickTrace;

namespace QuickTrace.Examples;

public static class BasicExample
{
    public static async Task Run()
    {
        Console.WriteLine("📝 Basic Example");
        Console.WriteLine("================");
        Console.WriteLine();

        // Basic usage với default style
        var tracer = Tracer.NewSimpleTracer("Basic Example");

        await Task.Delay(30);
        tracer.Span("Initialize database");

        await Task.Delay(50);
        tracer.Span("Load user data");

        await Task.Delay(20);
        tracer.Span("Process data");

        await Task.Delay(10);
        tracer.Span("Generate response");

        tracer.End();
    }
}
