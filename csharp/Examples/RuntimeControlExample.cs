using QuickTrace;

namespace QuickTrace.Examples;

public static class RuntimeControlExample
{
    public static async Task Run()
    {
        Console.WriteLine("🔧 Runtime Control Examples");
        Console.WriteLine("============================");
        Console.WriteLine();

        // Example 1: Enable/Disable tracing
        Console.WriteLine("1️⃣ Enable/Disable Tracing");
        Console.WriteLine("--------------------------");

        var tracer1 = Tracer.NewSimpleTracer("Runtime Control Demo");

        Console.WriteLine("✅ Tracing enabled:");
        await DoSomeWork(tracer1, "Enabled");
        tracer1.End();

        Console.WriteLine("\n❌ Tracing disabled:");
        tracer1.Enabled = false;
        await DoSomeWork(tracer1, "Disabled"); // Won't collect data
        tracer1.End(); // Won't print anything

        // Example 2: Silent mode
        Console.WriteLine("\n2️⃣ Silent Mode (Data Collection Only)");
        Console.WriteLine("--------------------------------------");

        var tracer2 = Tracer.NewSimpleTracer("Silent Mode Demo",
            TracerOptions.WithOutputStyle(OutputStyle.Colorful));

        tracer2.Silent = true; // Collect data but don't print

        Console.WriteLine("🔇 Silent mode - collecting data...");
        await DoSomeWork(tracer2, "Silent");
        tracer2.End(); // Won't print

        // Access collected data programmatically
        var measurements = tracer2.GetMeasurements();
        var totalDuration = tracer2.GetTotalDuration();

        Console.WriteLine($"📊 Collected {measurements.Count} measurements");
        Console.WriteLine($"⏱️  Total duration: {totalDuration}");

        for (int i = 0; i < measurements.Count; i++)
        {
            var m = measurements[i];
            Console.WriteLine($"   {i + 1}. {m.Statement}: {m.Duration}");
        }

        // Example 3: Dynamic style changes
        Console.WriteLine("\n3️⃣ Dynamic Style Changes");
        Console.WriteLine("-------------------------");

        var tracer3 = Tracer.NewSimpleTracer("Style Change Demo");

        Console.WriteLine("🎨 Starting with default style:");
        await DoSomeWork(tracer3, "Default Style");
        tracer3.End();

        // Change to colorful style
        tracer3 = Tracer.NewSimpleTracer("Style Change Demo",
            TracerOptions.WithOutputStyle(OutputStyle.Colorful));

        Console.WriteLine("\n🌈 Changed to colorful style:");
        await DoSomeWork(tracer3, "Colorful Style");
        tracer3.End();

        // Change to minimal style
        tracer3 = Tracer.NewSimpleTracer("Style Change Demo");
        tracer3.OutputStyle = OutputStyle.Minimal;

        Console.WriteLine("\n📝 Changed to minimal style:");
        await DoSomeWork(tracer3, "Minimal Style");
        tracer3.End();

        // Example 4: Custom print conditions
        Console.WriteLine("\n4️⃣ Custom Print Conditions");
        Console.WriteLine("---------------------------");

        var tracer4 = Tracer.NewSimpleTracer("Conditional Printing");

        // Set custom condition: only print if total > 50ms
        tracer4.PrintCondition = t => t.GetTotalDuration() > TimeSpan.FromMilliseconds(50);

        Console.WriteLine("⚡ Fast execution (won't print):");
        await Task.Delay(10);
        tracer4.Span("Quick task");
        tracer4.End(); // Won't print because < 50ms

        Console.WriteLine("🐌 Slow execution (will print):");
        var tracer5 = Tracer.NewSimpleTracer("Conditional Printing");
        tracer5.PrintCondition = t => t.GetTotalDuration() > TimeSpan.FromMilliseconds(50);

        await DoSomeWork(tracer5, "Slow enough"); // Will print because > 50ms
        tracer5.End();

        // Example 5: Inspection without printing
        Console.WriteLine("\n5️⃣ Data Inspection");
        Console.WriteLine("-------------------");

        var tracer6 = Tracer.NewSimpleTracer("Data Inspection",
            TracerOptions.WithSilent(true)); // Silent to avoid printing

        await Task.Delay(25);
        tracer6.Span("Database connection");

        await Task.Delay(75);
        tracer6.Span("Query execution");

        await Task.Delay(40);
        tracer6.Span("Result processing");

        tracer6.End();

        // Inspect collected data
        Console.WriteLine($"📈 Total measurements: {tracer6.GetMeasurements().Count}");
        Console.WriteLine($"⏱️  Total execution time: {tracer6.GetTotalDuration()}");
        Console.WriteLine($"🔧 Tracer enabled: {tracer6.Enabled}");
        Console.WriteLine($"🔇 Tracer silent: {tracer6.Silent}");
        Console.WriteLine($"🎨 Output style: {tracer6.OutputStyle}");
    }

    private static async Task DoSomeWork(Tracer tracer, string label)
    {
        await Task.Delay(20);
        tracer.Span($"Step 1: {label}");

        await Task.Delay(30);
        tracer.Span($"Step 2: {label}");

        await Task.Delay(15);
        tracer.Span($"Step 3: {label}");
    }
}
