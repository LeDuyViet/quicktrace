using System.Runtime.InteropServices;

namespace QuickTrace;

/// <summary>
/// Helper class for cross-platform console color management
/// </summary>
public static class ColorHelper
{
    private static readonly bool _supportsColor;
    private static readonly ConsoleColor _originalForeground;
    
    static ColorHelper()
    {
        _originalForeground = Console.ForegroundColor;
        _supportsColor = !Console.IsOutputRedirected && Environment.UserInteractive;
        
        // Try to enable virtual terminal processing on Windows
        if (RuntimeInformation.IsOSPlatform(OSPlatform.Windows))
        {
            try
            {
                EnableVirtualTerminalProcessing();
            }
            catch
            {
                // Ignore errors - fallback to basic color support
            }
        }
    }

    /// <summary>
    /// Color rules for different time ranges (optimized for cross-platform compatibility)
    /// </summary>
    public static readonly (TimeSpan Threshold, ConsoleColor Color, string Name)[] DurationColorRules = 
    {
        (TimeSpan.FromSeconds(3), ConsoleColor.Red, "Very Slow"),         // > 3s - red
        (TimeSpan.FromSeconds(1), ConsoleColor.DarkRed, "Slow"),          // 1s-3s - dark red  
        (TimeSpan.FromMilliseconds(500), ConsoleColor.Yellow, "Medium-Slow"), // 500ms-1s - yellow
        (TimeSpan.FromMilliseconds(200), ConsoleColor.Blue, "Medium"),    // 200ms-500ms - blue
        (TimeSpan.FromMilliseconds(100), ConsoleColor.Cyan, "Normal"),    // 100ms-200ms - cyan
        (TimeSpan.FromMilliseconds(50), ConsoleColor.Green, "Fast"),      // 50ms-100ms - green
        (TimeSpan.FromMilliseconds(10), ConsoleColor.DarkGreen, "Very Fast"), // 10ms-50ms - dark green
        (TimeSpan.Zero, ConsoleColor.DarkGray, "Ultra Fast")              // < 10ms - dark gray
    };

    /// <summary>
    /// Get color for a duration based on predefined rules
    /// </summary>
    public static ConsoleColor GetDurationColor(TimeSpan duration)
    {
        foreach (var (threshold, color, _) in DurationColorRules)
        {
            if (duration >= threshold)
                return color;
        }
        return ConsoleColor.White;
    }

    /// <summary>
    /// Get color name/category for a duration
    /// </summary>
    public static string GetDurationColorName(TimeSpan duration)
    {
        foreach (var (threshold, _, name) in DurationColorRules)
        {
            if (duration >= threshold)
                return name;
        }
        return "Unknown";
    }

    /// <summary>
    /// Write colored text to console
    /// </summary>
    public static void WriteColor(string text, ConsoleColor color)
    {
        if (_supportsColor)
        {
            var original = Console.ForegroundColor;
            Console.ForegroundColor = color;
            Console.Write(text);
            Console.ForegroundColor = original;
        }
        else
        {
            Console.Write(text);
        }
    }

    /// <summary>
    /// Write colored line to console
    /// </summary>
    public static void WriteLineColor(string text, ConsoleColor color)
    {
        if (_supportsColor)
        {
            var original = Console.ForegroundColor;
            Console.ForegroundColor = color;
            Console.WriteLine(text);
            Console.ForegroundColor = original;
        }
        else
        {
            Console.WriteLine(text);
        }
    }

    /// <summary>
    /// Check if colors are supported
    /// </summary>
    public static bool SupportsColor => _supportsColor;

    /// <summary>
    /// Reset console colors to original
    /// </summary>
    public static void ResetColors()
    {
        if (_supportsColor)
        {
            Console.ForegroundColor = _originalForeground;
        }
    }

    /// <summary>
    /// Create a progress bar string
    /// </summary>
    public static string CreateProgressBar(double percentage, int width = 10)
    {
        var filled = (int)Math.Round(percentage / 100.0 * width);
        filled = Math.Max(0, Math.Min(width, filled));
        
        return new string('█', filled) + new string('░', width - filled);
    }

    private static void EnableVirtualTerminalProcessing()
    {
        // Windows-specific code to enable ANSI escape sequences
        if (!RuntimeInformation.IsOSPlatform(OSPlatform.Windows))
            return;

        try
        {
            var handle = GetStdHandle(-11); // STD_OUTPUT_HANDLE
            if (GetConsoleMode(handle, out uint mode))
            {
                mode |= 0x0004; // ENABLE_VIRTUAL_TERMINAL_PROCESSING
                SetConsoleMode(handle, mode);
            }
        }
        catch
        {
            // Ignore errors - not critical
        }
    }

    [DllImport("kernel32.dll", SetLastError = true)]
    private static extern IntPtr GetStdHandle(int nStdHandle);

    [DllImport("kernel32.dll")]
    private static extern bool GetConsoleMode(IntPtr hConsoleHandle, out uint lpMode);

    [DllImport("kernel32.dll")]
    private static extern bool SetConsoleMode(IntPtr hConsoleHandle, uint dwMode);
}
