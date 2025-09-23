using QuickTrace;

namespace QuickTrace.Examples;

public static class StylesExample
{
    public static async Task Run()
    {
        Console.WriteLine("🎨 Styles Example");
        Console.WriteLine("=================");
        Console.WriteLine();

        var styles = new[]
        {
            ("Default", OutputStyle.Default),
            ("Colorful", OutputStyle.Colorful),
            ("Minimal", OutputStyle.Minimal),
            ("Detailed", OutputStyle.Detailed),
            ("Table", OutputStyle.Table),
            ("JSON", OutputStyle.Json)
        };

        foreach (var (name, style) in styles)
        {
            Console.WriteLine($"\n================= {name} STYLE =================");

            var tracer = Tracer.NewSimpleTracer($"API Processing - {name} Style",
                TracerOptions.WithOutputStyle(style));

            await SimulateWork(tracer);
            tracer.End();

            await Task.Delay(500); // Brief pause between styles
        }
    }

    private static async Task SimulateWork(Tracer tracer)
    {
        await Task.Delay(25);
        tracer.Span("Load configuration");

        await Task.Delay(75);
        tracer.Span("Connect to database");

        await Task.Delay(120);
        tracer.Span("Execute complex query");

        await Task.Delay(45);
        tracer.Span("Process results");

        await Task.Delay(15);
        tracer.Span("Cache data");

        await Task.Delay(8);
        tracer.Span("Generate response");
    }
}
