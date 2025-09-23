using QuickTrace;
using System.Text.Json;

namespace QuickTrace.Examples;

public static class RealWorldExample
{
    private static readonly Random _random = new();

    public static async Task Run()
    {
        Console.WriteLine("🌐 Real-World HTTP API Server với QuickTrace");
        Console.WriteLine("=============================================");
        Console.WriteLine();

        // Demo mode - simulate requests instead of starting server
        Console.WriteLine("🎬 Demo Mode - Simulating API Requests:");
        Console.WriteLine("======================================");

        // Simulate various API calls
        Console.WriteLine("\n1️⃣ User Profile Request (Medium complexity)");
        await UserProfileHandler("12345");

        await Task.Delay(1000);

        Console.WriteLine("\n2️⃣ Analytics Request (High complexity)");
        await AnalyticsHandler();

        await Task.Delay(1000);

        Console.WriteLine("\n3️⃣ Health Check (Low complexity)");
        await HealthCheckHandler();

        await Task.Delay(1000);

        Console.WriteLine("\n4️⃣ Multiple Quick Health Checks");
        for (int i = 1; i <= 3; i++)
        {
            Console.WriteLine($"\nHealth check #{i}:");
            await HealthCheckHandler();
            await Task.Delay(500);
        }

        Console.WriteLine("\n✅ Demo completed!");
        Console.WriteLine("\n💡 In a real server, you would integrate this with ASP.NET Core:");
        Console.WriteLine("   app.UseMiddleware<TracingMiddleware>();");
    }

    // HTTP Handlers with tracing
    private static async Task UserProfileHandler(string userId)
    {
        var tracer = Tracer.NewSimpleTracer("GET /api/user/profile",
            TracerOptions.WithOutputStyle(OutputStyle.Detailed),
            TracerOptions.WithHideUltraFast(TimeSpan.FromMilliseconds(2)));

        // Check cache first
        var cacheHit = await SimulateCache(tracer, $"user:{userId}");

        Dictionary<string, object> userData;
        if (!cacheHit)
        {
            // Cache miss - query database
            userData = await SimulateDatabase(tracer, $"SELECT * FROM users WHERE id = {userId}");

            // Cache the result
            await Task.Delay(2);
            tracer.Span("Cache store");
        }
        else
        {
            await Task.Delay(1);
            tracer.Span("Cache hit");
            userData = new Dictionary<string, object>
            {
                ["id"] = userId,
                ["name"] = "John Doe",
                ["cached"] = true
            };
        }

        // Process business logic
        await SimulateBusinessLogic(tracer, "medium");

        // Enrich with additional data
        var enrichData = await SimulateExternalAPI(tracer, "user-enrichment-service");

        // Final response preparation
        tracer.Span("Response serialization");
        await Task.Delay(3);

        var response = new Dictionary<string, object>
        {
            ["user"] = userData,
            ["enrichment"] = enrichData,
            ["timestamp"] = DateTimeOffset.UtcNow.ToUnixTimeSeconds()
        };

        tracer.End();
    }

    private static async Task AnalyticsHandler()
    {
        var tracer = Tracer.NewSimpleTracer("POST /api/analytics",
            TracerOptions.WithOutputStyle(OutputStyle.Colorful),
            TracerOptions.WithShowSlowOnly(TimeSpan.FromMilliseconds(50)),
            TracerOptions.WithGroupSimilar(TimeSpan.FromMilliseconds(20)));

        // Validate request
        await Task.Delay(5);
        tracer.Span("Request validation");

        // Multiple database queries for analytics
        for (int i = 1; i <= 3; i++)
        {
            var query = $"analytics_query_{i}";
            await SimulateDatabase(tracer, query);
        }

        // Complex data processing
        await SimulateBusinessLogic(tracer, "complex");

        // Generate multiple reports
        for (int i = 1; i <= 4; i++)
        {
            await Task.Delay(30 + _random.Next(40));
            tracer.Span($"Generate report {i}");
        }

        // Store results
        await SimulateDatabase(tracer, "INSERT INTO analytics_results");

        var response = new Dictionary<string, object>
        {
            ["status"] = "completed",
            ["reports_generated"] = 4,
            ["timestamp"] = DateTimeOffset.UtcNow.ToUnixTimeSeconds()
        };

        tracer.End();
    }

    private static async Task HealthCheckHandler()
    {
        var tracer = Tracer.NewSimpleTracer("GET /health",
            TracerOptions.WithOutputStyle(OutputStyle.Minimal),
            TracerOptions.WithMinTotalDuration(TimeSpan.FromMilliseconds(10))); // Only show if > 10ms

        // Quick database ping
        await Task.Delay(2 + _random.Next(8));
        tracer.Span("Database ping");

        // Quick cache ping
        await Task.Delay(1 + _random.Next(3));
        tracer.Span("Cache ping");

        // External service check
        await Task.Delay(5 + _random.Next(15));
        tracer.Span("External service check");

        var response = new Dictionary<string, object>
        {
            ["status"] = "healthy",
            ["timestamp"] = DateTimeOffset.UtcNow.ToUnixTimeSeconds()
        };

        tracer.End();
    }

    // Simulate different types of operations with realistic timing
    private static async Task<Dictionary<string, object>> SimulateDatabase(Tracer tracer, string query)
    {
        // Simulate database query time (realistic variability)
        var baseTime = 50 + _random.Next(100); // 50-150ms
        await Task.Delay(baseTime);
        tracer.Span($"Database: {query}");

        return new Dictionary<string, object>
        {
            ["query"] = query,
            ["results"] = _random.Next(100),
            ["time"] = baseTime
        };
    }

    private static async Task<bool> SimulateCache(Tracer tracer, string key)
    {
        // Cache operations are usually very fast
        await Task.Delay(1 + _random.Next(5));
        tracer.Span($"Cache lookup: {key}");

        // 70% cache hit rate
        return _random.NextDouble() < 0.7;
    }

    private static async Task<Dictionary<string, object>> SimulateExternalAPI(Tracer tracer, string service)
    {
        // External APIs can be slow and variable
        var baseTime = 200 + _random.Next(800); // 200ms-1s
        await Task.Delay(baseTime);
        tracer.Span($"External API: {service}");

        return new Dictionary<string, object>
        {
            ["service"] = service,
            ["status"] = "success",
            ["latency"] = baseTime
        };
    }

    private static async Task SimulateBusinessLogic(Tracer tracer, string complexity)
    {
        var duration = complexity switch
        {
            "simple" => 5 + _random.Next(15), // 5-20ms
            "medium" => 20 + _random.Next(50), // 20-70ms
            "complex" => 100 + _random.Next(200), // 100-300ms
            _ => 10
        };

        await Task.Delay(duration);
        tracer.Span($"Business logic: {complexity}");
    }
}
