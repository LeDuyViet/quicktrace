using System.Diagnostics;

namespace QuickTrace;

/// <summary>
/// Configuration options for Tracer
/// </summary>
public class TracerOptions
{
    public bool Enabled { get; set; } = true;
    public bool Silent { get; set; } = false;
    public OutputStyle OutputStyle { get; set; } = OutputStyle.Default;
    public TimeSpan MinTotalDuration { get; set; } = TimeSpan.FromMilliseconds(100);
    public Func<Tracer, bool>? PrintCondition { get; set; }
    
    // Smart filtering options
    public bool ShowSlowOnly { get; set; } = false;
    public TimeSpan SlowThreshold { get; set; } = TimeSpan.FromMilliseconds(100);
    public bool HideUltraFast { get; set; } = false;
    public TimeSpan UltraFastThreshold { get; set; } = TimeSpan.FromMilliseconds(1);
    public bool GroupSimilar { get; set; } = false;
    public TimeSpan SimilarThreshold { get; set; } = TimeSpan.FromMilliseconds(10);

    /// <summary>
    /// Create options with enabled/disabled setting
    /// </summary>
    public static TracerOptions WithEnabled(bool enabled) => new() { Enabled = enabled };

    /// <summary>
    /// Create options with silent mode setting
    /// </summary>
    public static TracerOptions WithSilent(bool silent) => new() { Silent = silent };

    /// <summary>
    /// Create options with specific output style
    /// </summary>
    public static TracerOptions WithOutputStyle(OutputStyle style) => new() { OutputStyle = style };

    /// <summary>
    /// Create options with minimum total duration filter
    /// </summary>
    public static TracerOptions WithMinTotalDuration(TimeSpan minDuration) => new() 
    { 
        PrintCondition = tracer => tracer.GetTotalDuration() >= minDuration 
    };

    /// <summary>
    /// Create options with minimum span duration filter
    /// </summary>
    public static TracerOptions WithMinSpanDuration(TimeSpan minDuration) => new()
    {
        PrintCondition = tracer => tracer.GetMeasurements().Any(m => m.Duration >= minDuration)
    };

    /// <summary>
    /// Create options with custom print condition
    /// </summary>
    public static TracerOptions WithCustomCondition(Func<Tracer, bool> condition) => new() 
    { 
        PrintCondition = condition 
    };

    /// <summary>
    /// Create options to show only slow operations
    /// </summary>
    public static TracerOptions WithShowSlowOnly(TimeSpan threshold) => new()
    {
        ShowSlowOnly = true,
        SlowThreshold = threshold
    };

    /// <summary>
    /// Create options to hide ultra fast operations
    /// </summary>
    public static TracerOptions WithHideUltraFast(TimeSpan threshold) => new()
    {
        HideUltraFast = true,
        UltraFastThreshold = threshold
    };

    /// <summary>
    /// Create options to group similar duration operations
    /// </summary>
    public static TracerOptions WithGroupSimilar(TimeSpan threshold) => new()
    {
        GroupSimilar = true,
        SimilarThreshold = threshold
    };

    /// <summary>
    /// Create options with combined smart filtering
    /// </summary>
    public static TracerOptions WithSmartFilter(TimeSpan slowThreshold, TimeSpan ultraFastThreshold, TimeSpan similarThreshold) => new()
    {
        ShowSlowOnly = slowThreshold > TimeSpan.Zero,
        SlowThreshold = slowThreshold,
        HideUltraFast = ultraFastThreshold > TimeSpan.Zero,
        UltraFastThreshold = ultraFastThreshold,
        GroupSimilar = similarThreshold > TimeSpan.Zero,
        SimilarThreshold = similarThreshold
    };

    /// <summary>
    /// Combine multiple options using fluent API
    /// </summary>
    public TracerOptions And(Action<TracerOptions> configure)
    {
        configure(this);
        return this;
    }
}
