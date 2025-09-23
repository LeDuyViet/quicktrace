namespace QuickTrace;

/// <summary>
/// Represents a single measurement with statement and duration
/// </summary>
public readonly struct Measurement
{
    public string Statement { get; }
    public TimeSpan Duration { get; }

    public Measurement(string statement, TimeSpan duration)
    {
        Statement = statement;
        Duration = duration;
    }

    public override string ToString()
    {
        return $"{Statement}: {Duration}";
    }
}
