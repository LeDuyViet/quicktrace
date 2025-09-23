using System.Diagnostics;
using System.Text;
using System.Text.Json;

namespace QuickTrace;

/// <summary>
/// Extension methods for TimeSpan formatting
/// </summary>
public static class TimeSpanExtensions
{
    /// <summary>
    /// Format TimeSpan in a human-readable way similar to Go's Duration.String()
    /// </summary>
    public static string ToHumanString(this TimeSpan timeSpan)
    {
        if (timeSpan.TotalSeconds >= 1)
        {
            return $"{timeSpan.TotalSeconds:F4}s";
        }
        else if (timeSpan.TotalMilliseconds >= 1)
        {
            return $"{timeSpan.TotalMilliseconds:F4}ms";
        }
        else if (timeSpan.TotalMicroseconds >= 1)
        {
            return $"{timeSpan.TotalMicroseconds:F1}µs";
        }
        else
        {
            return $"{timeSpan.Ticks * 100}ns";
        }
    }
}

/// <summary>
/// Main tracer class for performance measurement and tracing
/// </summary>
public class Tracer
{
    private readonly string _name;
    private readonly List<Measurement> _measurements;
    private readonly Stopwatch _totalStopwatch;
    private readonly Stopwatch _spanStopwatch;
    private readonly TracerOptions _options;
    private readonly CallerInfo _callerInfo;

    // Runtime control properties
    public bool Enabled { get; set; }
    public bool Silent { get; set; }
    public OutputStyle OutputStyle { get; set; }
    public Func<Tracer, bool>? PrintCondition { get; set; }

    /// <summary>
    /// Create a new tracer with specified name and options
    /// </summary>
    public Tracer(string name, TracerOptions? options = null)
    {
        _name = name;
        _measurements = new List<Measurement>();
        _totalStopwatch = Stopwatch.StartNew();
        _spanStopwatch = Stopwatch.StartNew();
        _options = options ?? new TracerOptions();
        _callerInfo = CaptureCallerInfo();

        // Initialize runtime properties from options
        Enabled = _options.Enabled;
        Silent = _options.Silent;
        OutputStyle = _options.OutputStyle;
        PrintCondition = _options.PrintCondition ?? (tracer => tracer.GetTotalDuration() >= _options.MinTotalDuration);
    }

    /// <summary>
    /// Factory method to create a simple tracer
    /// </summary>
    public static Tracer NewSimpleTracer(string name, params TracerOptions[] options)
    {
        var combinedOptions = new TracerOptions();
        
        foreach (var option in options)
        {
            // Merge options - later options override earlier ones
            if (option.Enabled != true) combinedOptions.Enabled = option.Enabled;
            if (option.Silent != false) combinedOptions.Silent = option.Silent;
            if (option.OutputStyle != OutputStyle.Default) combinedOptions.OutputStyle = option.OutputStyle;
            if (option.MinTotalDuration != TimeSpan.FromMilliseconds(100)) combinedOptions.MinTotalDuration = option.MinTotalDuration;
            if (option.PrintCondition != null) combinedOptions.PrintCondition = option.PrintCondition;
            
            // Smart filtering options
            if (option.ShowSlowOnly) 
            {
                combinedOptions.ShowSlowOnly = true;
                combinedOptions.SlowThreshold = option.SlowThreshold;
            }
            if (option.HideUltraFast)
            {
                combinedOptions.HideUltraFast = true;
                combinedOptions.UltraFastThreshold = option.UltraFastThreshold;
            }
            if (option.GroupSimilar)
            {
                combinedOptions.GroupSimilar = true;
                combinedOptions.SimilarThreshold = option.SimilarThreshold;
            }
        }

        return new Tracer(name, combinedOptions);
    }

    /// <summary>
    /// Record a span with specified statement
    /// </summary>
    public void Span(string statement)
    {
        if (!Enabled) return;

        var duration = _spanStopwatch.Elapsed;
        _measurements.Add(new Measurement(statement, duration));
        _spanStopwatch.Restart();
    }

    /// <summary>
    /// End tracing and print results
    /// </summary>
    public void End()
    {
        if (!Enabled) return;

        Span("End");
        _totalStopwatch.Stop();

        if (Silent) return;

        // Check custom condition
        if (PrintCondition != null && !PrintCondition(this)) return;

        var output = OutputStyle switch
        {
            OutputStyle.Colorful => GetColorfulOutput(),
            OutputStyle.Minimal => GetMinimalOutput(),
            OutputStyle.Detailed => GetDetailedOutput(),
            OutputStyle.Table => GetTableOutput(),
            OutputStyle.Json => GetJsonOutput(),
            _ => GetDetailedOutput()
        };

        Console.Write(output);
    }

    /// <summary>
    /// Get total duration since tracer creation
    /// </summary>
    public TimeSpan GetTotalDuration() => _totalStopwatch.Elapsed;

    /// <summary>
    /// Get all measurements (excluding the final "End" measurement)
    /// </summary>
    public IReadOnlyList<Measurement> GetMeasurements()
    {
        var measurements = _measurements.ToList();
        if (measurements.Count > 0 && measurements[^1].Statement == "End")
        {
            measurements.RemoveAt(measurements.Count - 1);
        }
        return measurements.AsReadOnly();
    }

    /// <summary>
    /// Get all measurements including "End"
    /// </summary>
    public IReadOnlyList<Measurement> GetAllMeasurements() => _measurements.AsReadOnly();

    #region Output Formatters

    private string GetColorfulOutput()
    {
        var output = new StringBuilder();
        var totalDuration = GetTotalDuration();
        var measurements = GetMeasurements();

        const int nameWidth = 35;
        const int durationWidth = 25;
        var totalTableWidth = nameWidth + durationWidth + 4;

        // Modern Unicode borders
        var topBorder = "┌" + new string('─', totalTableWidth - 2) + "┐";
        var separator = "├" + new string('─', totalTableWidth - 2) + "┤";
        var bottomBorder = "└" + new string('─', totalTableWidth - 2) + "┘";

        output.AppendLine(topBorder);

        // Title row
        var titleText = "🚀 " + _name;
        var titlePadding = Math.Max(1, (totalTableWidth - titleText.Length - 2) / 2);
        var remainingPadding = Math.Max(1, totalTableWidth - titleText.Length - titlePadding - 2);

        output.AppendLine($"│{new string(' ', titlePadding)}{titleText}{new string(' ', remainingPadding)}│");

        // Caller info
        if (!string.IsNullOrEmpty(_callerInfo.FileName))
        {
            var callerInfo = $"📍 File: {_callerInfo.FileName}:{_callerInfo.LineNumber}";
            var callerPadding = Math.Max(1, (totalTableWidth - callerInfo.Length - 2) / 2);
            var remainingCallerPadding = Math.Max(1, totalTableWidth - callerInfo.Length - callerPadding - 2);
            output.AppendLine($"│{new string(' ', callerPadding)}{callerInfo}{new string(' ', remainingCallerPadding)}│");
        }

        output.AppendLine(separator);

        // Total time row
        var totalLine = $"│ ⏱️  Total Time: {new string(' ', nameWidth - 16)} │ {totalDuration.ToHumanString()}";
        output.AppendLine(totalLine);

        output.AppendLine(separator);

        // Column headers
        var headerLine = $"│ {"📋 Span",-nameWidth} │ ⏰ Duration";
        output.AppendLine(headerLine);

        output.AppendLine(separator);

        // Apply smart filtering
        var filteredData = ApplySmartFiltering(measurements);

        // Spans
        foreach (var item in filteredData)
        {
            string operationName;
            TimeSpan duration;

            switch (item)
            {
                case GroupedMeasurement grouped:
                    operationName = "📦 " + grouped.Name;
                    duration = grouped.AvgTime;
                    break;
                case Measurement measurement:
                    operationName = measurement.Statement;
                    duration = measurement.Duration;
                    break;
                default:
                    continue;
            }

            if (operationName.Length > nameWidth)
                operationName = operationName[..(nameWidth - 3)] + "...";

            output.AppendLine($"│ {operationName,-nameWidth} │ {duration.ToHumanString()}");
        }

        output.AppendLine(bottomBorder);

        return output.ToString();
    }

    private string GetMinimalOutput()
    {
        var output = new StringBuilder();
        var totalDuration = GetTotalDuration();
        var measurements = GetMeasurements();

        const int nameWidth = 35;
        const int durationWidth = 25;
        var totalWidth = nameWidth + durationWidth + 4;

        var topBorder = "┌" + new string('─', totalWidth - 2) + "┐";
        var separator = "├" + new string('─', totalWidth - 2) + "┤";
        var bottomBorder = "└" + new string('─', totalWidth - 2) + "┘";

        output.AppendLine(topBorder);

        var titleText = "⚡ " + _name;
        if (titleText.Length > nameWidth)
            titleText = titleText[..(nameWidth - 3)] + "...";

        var titleLine = $"│ {titleText,-nameWidth} │ {totalDuration.ToHumanString()}";
        output.AppendLine(titleLine);

        if (!string.IsNullOrEmpty(_callerInfo.FileName))
        {
            var callerInfo = $"📍 File: {_callerInfo.FileName}:{_callerInfo.LineNumber}";
            if (callerInfo.Length > nameWidth)
                callerInfo = callerInfo[..(nameWidth - 3)] + "...";

            var callerLine = $"│ {callerInfo,-nameWidth} │ ";
            output.AppendLine(callerLine);
        }

        output.AppendLine(separator);

        foreach (var m in measurements)
        {
            var spanName = "  └─ " + m.Statement;
            if (spanName.Length > nameWidth)
                spanName = spanName[..(nameWidth - 3)] + "...";

            output.AppendLine($"│ {spanName,-nameWidth} │ {m.Duration.ToHumanString()}");
        }

        output.AppendLine(bottomBorder);

        return output.ToString();
    }

    private string GetDetailedOutput()
    {
        var output = new StringBuilder();
        var totalDuration = GetTotalDuration();
        var measurements = GetMeasurements();

        const int indexWidth = 3;
        const int nameWidth = 30;
        const int durationWidth = 15;
        const int percentWidth = 8;
        const int barWidth = 12;

        var totalWidth = indexWidth + nameWidth + durationWidth + percentWidth + barWidth + 12;

        var topBorder = "╔" + new string('═', totalWidth - 2) + "╗";
        var separator = "╠" + new string('═', totalWidth - 2) + "╣";
        var thinSeparator = "╟" + new string('─', totalWidth - 2) + "╢";
        var bottomBorder = "╚" + new string('═', totalWidth - 2) + "╝";

        output.AppendLine(topBorder);

        // Title
        var titleText = "🎯 TRACE: " + _name;
        var titlePadding = Math.Max(1, (totalWidth - titleText.Length - 2) / 2);
        var remainingPadding = Math.Max(1, totalWidth - titleText.Length - titlePadding - 2);
        
        output.AppendLine($"║{new string(' ', titlePadding)}{titleText}{new string(' ', remainingPadding)}║");

        output.AppendLine(separator);

        // Summary section
        output.AppendLine($"║ 📊 SUMMARY{new string(' ', totalWidth - 13)}║");
        output.AppendLine($"║ • Total Execution Time: {totalDuration.ToHumanString()}{new string(' ', totalWidth - $"║ • Total Execution Time: {totalDuration.ToHumanString()}".Length - 1)}║");
        output.AppendLine($"║ • Number of Spans: {measurements.Count}{new string(' ', totalWidth - $"║ • Number of Spans: {measurements.Count}".Length - 1)}║");

        // Find slowest operation
        var slowest = measurements.OrderByDescending(m => m.Duration).FirstOrDefault();
        if (slowest.Statement != null)
        {
            var slowestName = slowest.Statement.Length > 25 ? slowest.Statement[..22] + "..." : slowest.Statement;
            output.AppendLine($"║ • Slowest Operation: {slowestName}{new string(' ', totalWidth - $"║ • Slowest Operation: {slowestName}".Length - 1)}║");
            output.AppendLine($"║ • Slowest Duration: {slowest.Duration.ToHumanString()}{new string(' ', totalWidth - $"║ • Slowest Duration: {slowest.Duration.ToHumanString()}".Length - 1)}║");
        }

        if (!string.IsNullOrEmpty(_callerInfo.FileName))
        {
            var callerInfoStr = $"{_callerInfo.FileName}:{_callerInfo.LineNumber}";
            output.AppendLine($"║ • File: {callerInfoStr}{new string(' ', totalWidth - $"║ • File: {callerInfoStr}".Length - 1)}║");
        }

        output.AppendLine(separator);

        // Detailed breakdown
        output.AppendLine($"║ 🔍 DETAILED BREAKDOWN{new string(' ', totalWidth - 23)}║");
        output.AppendLine(thinSeparator);

        // Headers
        output.AppendLine($"║ {"#",indexWidth} │ {"Operation",-nameWidth + 1} │ {"Duration",durationWidth - 1} │ {"Percent",percentWidth - 1} │ {"Progress",-barWidth + 1} ║");
        output.AppendLine(thinSeparator);

        // Apply smart filtering
        var filteredData = ApplySmartFiltering(measurements);

        // Data rows
        for (int i = 0; i < filteredData.Count; i++)
        {
            string operationName;
            TimeSpan duration;
            bool isGrouped = false;

            switch (filteredData[i])
            {
                case GroupedMeasurement grouped:
                    operationName = grouped.Name;
                    duration = grouped.AvgTime;
                    isGrouped = true;
                    break;
                case Measurement measurement:
                    operationName = measurement.Statement;
                    duration = measurement.Duration;
                    break;
                default:
                    continue;
            }

            var percentage = (double)duration.Ticks / totalDuration.Ticks * 100;
            var progressBar = ColorHelper.CreateProgressBar(percentage, barWidth - 1);
            var percentStr = $"{percentage:F1}%";

            if (operationName.Length > nameWidth - 1)
                operationName = operationName[..(nameWidth - 4)] + "...";

            var displayName = isGrouped ? "📦 " + operationName : operationName;

            output.AppendLine($"║ {i + 1,indexWidth} │ {displayName,-nameWidth + 1} │ {duration.ToHumanString(),durationWidth - 2} │ {percentStr,percentWidth - 2} │ {progressBar,-barWidth + 1} ║");
        }

        // Show filtering summary if any filters are applied
        if (_options.ShowSlowOnly || _options.HideUltraFast || _options.GroupSimilar)
        {
            output.AppendLine(thinSeparator);

            var originalCount = measurements.Count;
            var filteredCount = filteredData.Count;

            var activeFilters = new List<string>();
            if (_options.ShowSlowOnly) activeFilters.Add($"slow>{_options.SlowThreshold.TotalMilliseconds}ms");
            if (_options.HideUltraFast) activeFilters.Add($"hide<{_options.UltraFastThreshold.TotalMilliseconds}ms");
            if (_options.GroupSimilar) activeFilters.Add($"group±{_options.SimilarThreshold.TotalMilliseconds}ms");

            var filterInfo = $"🔍 Filtered: {filteredCount}/{originalCount} spans | Active: {string.Join(", ", activeFilters)}";
            output.AppendLine($"║ {filterInfo}{new string(' ', totalWidth - filterInfo.Length - 3)}║");
        }

        output.AppendLine(bottomBorder);

        return output.ToString();
    }

    private string GetTableOutput()
    {
        var output = new StringBuilder();
        var totalDuration = GetTotalDuration();
        var measurements = GetMeasurements();

        const int indexWidth = 4;
        const int nameWidth = 45;
        const int durationWidth = 20;

        var totalTableWidth = indexWidth + nameWidth + durationWidth + 3;

        var topBorder = "┌" + new string('─', indexWidth) + "┬" + new string('─', nameWidth) + "┬" + new string('─', durationWidth) + "┐";
        var headerSeparator = "├" + new string('─', indexWidth) + "┼" + new string('─', nameWidth) + "┼" + new string('─', durationWidth) + "┤";
        var bottomBorder = "└" + new string('─', indexWidth) + "┴" + new string('─', nameWidth) + "┴" + new string('─', durationWidth) + "┘";

        output.AppendLine(topBorder);

        // Title
        var titlePadding = Math.Max(1, (totalTableWidth - _name.Length - 4) / 2);
        var remainingPadding = Math.Max(1, totalTableWidth - _name.Length - titlePadding - 4);
        output.AppendLine($"│{new string(' ', titlePadding)}🚀 {_name}{new string(' ', remainingPadding)}│");

        if (!string.IsNullOrEmpty(_callerInfo.FileName))
        {
            var callerInfo = $"📍 File: {_callerInfo.FileName}:{_callerInfo.LineNumber}";
            var callerPadding = Math.Max(1, (totalTableWidth - callerInfo.Length - 2) / 2);
            var remainingCallerPadding = Math.Max(1, totalTableWidth - callerInfo.Length - callerPadding - 2);
            output.AppendLine($"│{new string(' ', callerPadding)}{callerInfo}{new string(' ', remainingCallerPadding)}│");
        }

        output.AppendLine(headerSeparator);

        // Headers
        output.AppendLine($"│ {"No",-2} │ {"Span Name",-nameWidth + 1}│ Duration");
        output.AppendLine(headerSeparator);

        // Total time row
        output.AppendLine($"│ {"",2} │ {"📊 TOTAL EXECUTION TIME",-nameWidth + 1}│ {totalDuration.ToHumanString()}");
        output.AppendLine(headerSeparator);

        // Data rows
        for (int i = 0; i < measurements.Count; i++)
        {
            var m = measurements[i];
            var spanName = m.Statement;
            if (spanName.Length > nameWidth - 2)
                spanName = spanName[..(nameWidth - 5)] + "...";

            output.AppendLine($"│ {i + 1,indexWidth - 2} │ {spanName,-nameWidth + 1}│ {m.Duration.ToHumanString()}");
        }

        output.AppendLine(bottomBorder);

        // Summary statistics
        output.AppendLine();
        var slowest = measurements.OrderByDescending(m => m.Duration).FirstOrDefault();
        output.AppendLine($"📈 Spans: {measurements.Count} | 🐌 Slowest: {slowest.Statement} ({slowest.Duration.ToHumanString()})");

        return output.ToString();
    }

    private string GetJsonOutput()
    {
        var output = new StringBuilder();
        var totalDuration = GetTotalDuration();
        var measurements = GetMeasurements();

        output.AppendLine("📄 JSON Output:");

        var data = new
        {
            tracer_name = _name,
            total_duration = totalDuration.ToHumanString(),
            total_ms = totalDuration.TotalMilliseconds,
            total_ns = totalDuration.Ticks * 100, // Convert to nanoseconds
            caller_info = string.IsNullOrEmpty(_callerInfo.FileName) ? null : new
            {
                file = $"{_callerInfo.FileName}:{_callerInfo.LineNumber}",
                full_path = _callerInfo.FullPath,
                line = _callerInfo.LineNumber
            },
            spans = measurements.Select(m => new
            {
                name = m.Statement,
                duration = m.Duration.ToHumanString(),
                ms = m.Duration.TotalMilliseconds,
                ns = m.Duration.Ticks * 100,
                percent = (double)m.Duration.Ticks / totalDuration.Ticks * 100,
                color_class = GetColorClass(m.Duration)
            }).ToArray()
        };

        var json = JsonSerializer.Serialize(data, new JsonSerializerOptions 
        { 
            WriteIndented = true,
            PropertyNamingPolicy = JsonNamingPolicy.SnakeCaseLower
        });

        output.AppendLine(json);

        return output.ToString();
    }

    #endregion

    #region Smart Filtering

    private List<object> ApplySmartFiltering(IReadOnlyList<Measurement> measurements)
    {
        if (measurements.Count == 0)
            return new List<object>();

        // Step 1: Filter by slow threshold
        var filtered = measurements.AsEnumerable();
        if (_options.ShowSlowOnly)
        {
            filtered = filtered.Where(m => m.Duration >= _options.SlowThreshold);
        }

        // Step 2: Filter out ultra fast
        if (_options.HideUltraFast)
        {
            filtered = filtered.Where(m => m.Duration >= _options.UltraFastThreshold);
        }

        var filteredList = filtered.ToList();

        // Step 3: Group similar if needed
        var result = new List<object>();
        if (_options.GroupSimilar && filteredList.Count > 0)
        {
            var groups = GroupSimilarMeasurements(filteredList);
            result.AddRange(groups);
        }
        else
        {
            result.AddRange(filteredList.Cast<object>());
        }

        return result;
    }

    private List<GroupedMeasurement> GroupSimilarMeasurements(List<Measurement> measurements)
    {
        if (measurements.Count == 0)
            return new List<GroupedMeasurement>();

        var groups = new List<GroupedMeasurement>();
        var processed = new HashSet<int>();

        for (int i = 0; i < measurements.Count; i++)
        {
            if (processed.Contains(i))
                continue;

            var m1 = measurements[i];
            var group = new GroupedMeasurement
            {
                Name = m1.Statement,
                Count = 1,
                TotalTime = m1.Duration,
                MinTime = m1.Duration,
                MaxTime = m1.Duration
            };
            processed.Add(i);

            var similarNames = new List<string>();
            for (int j = i + 1; j < measurements.Count; j++)
            {
                if (processed.Contains(j))
                    continue;

                var m2 = measurements[j];
                var diff = Math.Abs((m1.Duration - m2.Duration).Ticks);

                if (TimeSpan.FromTicks(diff) <= _options.SimilarThreshold)
                {
                    group.Count++;
                    group.TotalTime = TimeSpan.FromTicks(group.TotalTime.Ticks + m2.Duration.Ticks);
                    if (m2.Duration < group.MinTime) group.MinTime = m2.Duration;
                    if (m2.Duration > group.MaxTime) group.MaxTime = m2.Duration;
                    similarNames.Add(m2.Statement);
                    processed.Add(j);
                }
            }

            group.AvgTime = TimeSpan.FromTicks(group.TotalTime.Ticks / group.Count);

            if (similarNames.Count > 0)
            {
                group.Name = similarNames.Count <= 2 
                    ? $"{group.Name} + {similarNames.Count} similar"
                    : $"{group.Name} + {similarNames.Count} others";
            }

            groups.Add(group);
        }

        return groups;
    }

    #endregion

    #region Helper Methods

    private static string GetColorClass(TimeSpan duration)
    {
        return duration.TotalMilliseconds switch
        {
            > 1000 => "slow",
            > 100 => "medium",
            > 10 => "fast",
            _ => "very_fast"
        };
    }

    private static CallerInfo CaptureCallerInfo()
    {
        var stackTrace = new StackTrace(3, true); // Skip 3 frames: CaptureCallerInfo -> Tracer constructor -> NewSimpleTracer
        var frame = stackTrace.GetFrame(0);
        
        if (frame != null)
        {
            var fileName = frame.GetFileName();
            if (!string.IsNullOrEmpty(fileName))
            {
                return new CallerInfo
                {
                    FullPath = fileName,
                    FileName = Path.GetFileName(fileName),
                    LineNumber = frame.GetFileLineNumber()
                };
            }
        }

        return new CallerInfo();
    }

    #endregion

    private record CallerInfo
    {
        public string FullPath { get; init; } = "";
        public string FileName { get; init; } = "";
        public int LineNumber { get; init; } = 0;
    }
}

/// <summary>
/// Represents a group of similar measurements
/// </summary>
public class GroupedMeasurement
{
    public string Name { get; set; } = "";
    public int Count { get; set; }
    public TimeSpan TotalTime { get; set; }
    public TimeSpan AvgTime { get; set; }
    public TimeSpan MinTime { get; set; }
    public TimeSpan MaxTime { get; set; }
}
