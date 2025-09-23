using QuickTrace;

namespace QuickTrace.Examples;

public class Program
{
    public static async Task Main(string[] args)
    {
        Console.WriteLine("🚀 QuickTrace for C# - Examples");
        Console.WriteLine("================================");
        Console.WriteLine();

        if (args.Length == 0)
        {
            ShowMenu();
            return;
        }

        var exampleName = args[0].ToLower();
        
        await (exampleName switch
        {
            "basic" => BasicExample.Run(),
            "advanced" => AdvancedExample.Run(),
            "styles" => StylesExample.Run(),
            "filtering" => FilteringExample.Run(),
            "runtime" => RuntimeControlExample.Run(),
            "realworld" => RealWorldExample.Run(),
            "all" => RunAllExamples(),
            _ => ShowInvalidExample(exampleName)
        });
    }

    private static void ShowMenu()
    {
        Console.WriteLine("Available examples:");
        Console.WriteLine("  basic      - Basic usage với default style");
        Console.WriteLine("  advanced   - Advanced usage với smart filtering");
        Console.WriteLine("  styles     - Demo tất cả output styles");
        Console.WriteLine("  filtering  - Demo smart filtering features");
        Console.WriteLine("  runtime    - Demo runtime control");
        Console.WriteLine("  realworld  - Real-world HTTP API simulation");
        Console.WriteLine("  all        - Run tất cả examples");
        Console.WriteLine();
        Console.WriteLine("Usage: dotnet run <example_name>");
        Console.WriteLine("Example: dotnet run basic");
    }

    private static async Task ShowInvalidExample(string exampleName)
    {
        Console.WriteLine($"❌ Unknown example: {exampleName}");
        Console.WriteLine();
        ShowMenu();
        await Task.CompletedTask;
    }

    private static async Task RunAllExamples()
    {
        var examples = new (string Name, Func<Task> Runner)[]
        {
            ("Basic Example", BasicExample.Run),
            ("Advanced Example", AdvancedExample.Run),
            ("Styles Example", StylesExample.Run),
            ("Filtering Example", FilteringExample.Run),
            ("Runtime Control Example", RuntimeControlExample.Run),
            ("Real World Example", RealWorldExample.Run)
        };

        for (int i = 0; i < examples.Length; i++)
        {
            var (name, runner) = examples[i];
            
            Console.WriteLine($"\n🔸 Running {name} ({i + 1}/{examples.Length})");
            Console.WriteLine(new string('=', 50));
            
            await runner();
            
            if (i < examples.Length - 1)
            {
                Console.WriteLine("\nPress any key to continue to next example...");
                Console.ReadKey(true);
                Console.Clear();
            }
        }

        Console.WriteLine("\n✅ All examples completed!");
    }
}
